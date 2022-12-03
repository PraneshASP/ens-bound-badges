// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC721Initializable} from "./ERC721Initializable.sol";
import {IENS} from "./interfaces/IENS.sol";
import {IENSBoundBadge} from "./interfaces/IENSBoundBadge.sol";

error NotPermitted(); // ENSBound
error OnlyIssuer(); // Can be called only by issuer
error Initialized(); // Already initialized
error NotIssued(); // Badge not yet issed
error SupplyLimitReached(); // Total supply is minted
error AlreadyIssued(); // The Badge is already minted to the ENS domain

/// @title ENSBoundBadge contract
/// @notice This is a ERC721 compatible non-transferrable token contract
/// @notice All the minted tokens will be tied with the ENS domain
/// @notice This contract integrates with Push protocol and ENS contracts
contract ENSBoundBadge is IENSBoundBadge, ERC721Initializable {
    /*//////////////////////////////////////////////////////////////
                                 STORAGE
    //////////////////////////////////////////////////////////////*/

    ///@notice Address of ENS contract to resolve underlying address
    IENS public ensAddress;

    ///@notice Address of the badge issuer
    address public issuer;

    ///@notice Latest BadgeID
    uint256 public badgeId;

    ///@notice Max supply for the badge
    uint256 public supply;

    ///@notice Maps badgeId with BadgeInfo
    mapping(uint256 => BadgeInfo) public badgeInfo;

    ///@notice Used to specify if one ENS domain can hold multiple badges
    bool public canHoldMultiple;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Issued(
        string _recipient,
        address indexed _recipientAddress,
        uint256 _badgeId
    );
    event Revoked(address indexed _revokedFrom, uint256 _badgeId);

    /*//////////////////////////////////////////////////////////////
                                 INITIALIZER
    //////////////////////////////////////////////////////////////*/

    /// @notice Initializer
    /// @param _name Name of the badge
    /// @param _symbol Symbol for the badge
    /// @param _ensAddress Address of ENS contract
    /// @param _issuer Address of the Badge issuer
    /// @param _supply Max supply for the badge
    /// @param _canHoldMultiple Used to specify if an ENS domain can hold multiple badges
    function initialize(
        string memory _name,
        string memory _symbol,
        address _ensAddress,
        address _issuer,
        uint256 _supply,
        bool _canHoldMultiple
    ) public {
        if (address(ensAddress) != address(0)) revert Initialized();
        name = _name;
        symbol = _symbol;
        issuer = _issuer;
        ensAddress = IENS(_ensAddress);
        supply = _supply;
        canHoldMultiple = _canHoldMultiple;
    }

    /*//////////////////////////////////////////////////////////////
                                 PUBLIC METHODS
    //////////////////////////////////////////////////////////////*/
    /// @notice Returns the metadata uri for the given `_badgeId`
    function tokenURI(uint256 _badgeId)
        public
        view
        override
        returns (string memory)
    {
        return badgeInfo[_badgeId].metadataURI;
    }

    /// @notice Used to issue a new badge
    /// @dev Here we are making an assumption that the given nodeHash is the nodehash of the _ensName
    /// @param _ensName ENS name of the recipient
    /// @param _ensNodeHash NodeHash of the ENS name
    /// @param _badgeInfo Additional info for the Badge
    function issueBadge(
        string memory _ensName,
        bytes32 _ensNodeHash,
        BadgeInfo memory _badgeInfo
    ) external {
        if (msg.sender != issuer) revert OnlyIssuer();
        uint256 _badgeId = badgeId++;
        if (_badgeId > supply) revert SupplyLimitReached();
        address _resolvedAddress = resolveENS(_ensNodeHash);
        if (!canHoldMultiple && _balanceOf[_resolvedAddress] > 0)
            revert AlreadyIssued();

        /// TODO: Verify if `nodeHash(_ensName) == _ensNodeHash`

        _mint(_resolvedAddress, _badgeId);
        badgeInfo[_badgeId] = _badgeInfo;
        emit Issued(_ensName, _resolvedAddress, _badgeId);
    }

    /// @notice Used to revoke any issued badge
    /// @dev Issuer can revoke if the ENS is expired or so
    /// @param _badgeId Id of the badge to revoke
    function revokeBadge(uint256 _badgeId) external {
        if (msg.sender != issuer) revert OnlyIssuer();
        _burn(_badgeId);
    }

    /// @notice Used to get the underlying address for a given ENS domain
    /// @param _ensNodeHash Nodehash for the ens domain
    /// @return The associated address for the given Nodehash
    function resolveENS(bytes32 _ensNodeHash) public view returns (address) {
        address resolver = ensAddress.resolver(_ensNodeHash);
        return IENS(resolver).addr(_ensNodeHash);
    }

    /*//////////////////////////////////////////////////////////////
                                 INTERNAL METHODS
    //////////////////////////////////////////////////////////////*/
    function _mint(address to, uint256 id) internal virtual {
        _balanceOf[to] += 1;
        _ownerOf[id] = to;
        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        if (id > badgeId) revert NotIssued();
        address holder = _ownerOf[id];
        if (holder == address(0)) revert NotIssued();

        _balanceOf[holder] -= 1;
        _ownerOf[id] = address(0);

        emit Revoked(holder, id);

        emit Transfer(holder, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                                 RESTRICTED METHODS
    //////////////////////////////////////////////////////////////*/
    function approve(address spender, uint256 id) public virtual override {
        revert NotPermitted();
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        revert NotPermitted();
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        revert NotPermitted();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        revert NotPermitted();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual override {
        revert NotPermitted();
    }
}
