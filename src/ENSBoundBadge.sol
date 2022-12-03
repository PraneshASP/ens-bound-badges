// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC721Initializable} from "./ERC721Initializable.sol";
import {IENS} from "./interfaces/IENS.sol";

error NotPermitted(); // ENSBound
error OnlyIssuer(); // Can be called only by issuer
error Initialized(); // Already initialized
error NotIssued(); // Badge not yet issed
error SupplyLimitReached(); // Total supply is minted

contract ENSBoundBadge is ERC721Initializable {
    string internal URI;
    IENS public ensAddress;
    address public issuer;
    uint256 public badgeId;
    uint256 public supply;

    event Issued(
        string _recipient,
        address indexed recipientAddress,
        uint256 _badgeId
    );
    event Revoked(address indexed revokedFrom, uint256 _badgeId);

    function initialize(
        string memory _name,
        string memory _symbol,
        address _ensAddress,
        address _issuer,
        uint256 _supply
    ) public {
        if (address(ensAddress) != address(0)) revert Initialized();
        name = _name;
        symbol = _symbol;
        issuer = _issuer;
        ensAddress = IENS(_ensAddress);
        supply = _supply;
    }

    // TODO:
    function tokenURI(uint256) public view override returns (string memory) {}

    /// PUBLIC methods

    function issueBadge(string memory _ensName, bytes32 _ensNodeHash) external {
        if (msg.sender != issuer) revert OnlyIssuer();
        uint256 _badgeId = badgeId++;
        if (_badgeId > supply) revert SupplyLimitReached();
        address _resolvedAddress = resolveENS(_ensNodeHash);
        _mint(_resolvedAddress, _badgeId);
        emit Issued(_ensName, _resolvedAddress, _badgeId);
    }

    function revokeBadge(uint256 _badgeId) external {
        if (msg.sender != issuer) revert OnlyIssuer();
        _burn(_badgeId);
    }

    /// Internal methods
    function _mint(address to, uint256 id) internal virtual {
        _balanceOf[to] = 1;
        _ownerOf[id] = to;
        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        if (id > badgeId) revert NotIssued();
        address holder = _ownerOf[id];
        if (holder == address(0)) revert NotIssued();

        _balanceOf[holder] = 0;
        _ownerOf[id] = address(0);

        emit Revoked(holder, id);

        emit Transfer(holder, address(0), id);
    }

    function resolveENS(bytes32 _ensNodeHash) public view returns (address) {
        address resolver = ensAddress.resolver(_ensNodeHash);
        return IENS(resolver).addr(_ensNodeHash);
    }

    /// Restricted methods

    // function approve(address spender, uint256 id) public virtual override {
    //     revert NotPermitted();
    // }

    // function setApprovalForAll(address operator, bool approved)
    //     public
    //     virtual
    //     override
    // {
    //     revert NotPermitted();
    // }

    // function transferFrom(
    //     address from,
    //     address to,
    //     uint256 id
    // ) public virtual override {
    //     revert NotPermitted();
    // }

    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint256 id
    // ) public virtual override {
    //     revert NotPermitted();
    // }

    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint256 id,
    //     bytes calldata data
    // ) public virtual override {
    //     revert NotPermitted();
    // }
}
