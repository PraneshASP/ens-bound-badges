// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Clones} from "./helpers/Clones.sol";
import {IENSBBadge} from "./interfaces/IENSBBadge.sol";

error OnlyOwner(); // Caller is not owner

contract ENSBoundBadgeFactory {
    address public implementation;
    address public owner;

    address public immutable ensAddress;
    mapping(uint256 => address) public ensBoundBadgeAddresses;

    uint256 public count;

    event NewENSBoundBadgeCreated(
        address indexed _ensBoundBadgeAddress,
        string _name,
        string _symbol,
        uint256 _supply
    );

    constructor(address _implementation, address _ensAddress) {
        implementation = _implementation;
        owner = msg.sender;
        ensAddress = _ensAddress;
    }

    function createENSBBadge(
        string memory _name,
        string memory _symbol,
        uint256 _supply
    ) external {
        IENSBBadge _ensBoundBadgeAddress = IENSBBadge(
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

    function setImplementationAddress(address _newImplementation) external {
        if (msg.sender != owner) revert OnlyOwner();
        implementation = _newImplementation;
    }
}
