// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Clones} from "./helpers/Clones.sol";
import {IENSBoundBadge} from "./interfaces/IENSBoundBadge.sol";

error OnlyOwner(); // Caller is not owner

/// @title ENSBoundBadgeFactory
/// @notice A simple factory contract used to clone the ENSBoundBadge contracts

contract ENSBoundBadgeFactory {
    /*//////////////////////////////////////////////////////////////
                                 STORAGE
    //////////////////////////////////////////////////////////////*/
    address public implementation;
    address public immutable owner;
    address public immutable ensAddress;

    mapping(uint256 => address) public ensBoundBadgeAddresses;
    uint256 public count;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event NewENSBoundBadgeCreated(
        address indexed _ensBoundBadgeAddress,
        string _name,
        string _symbol,
        uint256 _supply
    );

    /*//////////////////////////////////////////////////////////////
                                 CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address _implementation, address _ensAddress) {
        implementation = _implementation;
        owner = msg.sender;
        ensAddress = _ensAddress;
    }

    /*//////////////////////////////////////////////////////////////
                                 EXTERNAL METHODS
    //////////////////////////////////////////////////////////////*/

    /// @notice Used to create a new ENS bound badge contract
    /// @param _name Name of the badge
    /// @param _symbol Symbol for the badge
    /// @param _supply Max supply for the badge
    function createENSBoundBadge(
        string memory _name,
        string memory _symbol,
        uint256 _supply
    ) external {
        IENSBoundBadge _ensBoundBadgeAddress = IENSBoundBadge(
            Clones.clone(implementation)
        );

        _ensBoundBadgeAddress.initialize(
            _name,
            _symbol,
            ensAddress,
            msg.sender,
            _supply
        );

        ensBoundBadgeAddresses[++count] = address(_ensBoundBadgeAddress);

        emit NewENSBoundBadgeCreated(
            address(_ensBoundBadgeAddress),
            _name,
            _symbol,
            _supply
        );
    }

    /// @notice Used to update the address of ENSBoundBadge implementation contract
    /// @param _newImplementation Address of the updated contract
    function setImplementationAddress(address _newImplementation) external {
        if (msg.sender != owner) revert OnlyOwner();
        implementation = _newImplementation;
    }
}
