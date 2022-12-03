// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice Interface for ENSBoundBadge contract
interface IENSBBadge {
    function initialize(
        string memory _name,
        string memory _symbol,
        address _ensAddress,
        address _issuer,
        uint256 _supply
    ) external;
}
