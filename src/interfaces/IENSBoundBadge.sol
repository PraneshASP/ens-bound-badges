// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice Interface for ENSBoundBadge contract
interface IENSBoundBadge {
    struct BadgeInfo {
        string title; /// Title of the Badge
        string description; /// Description for the badge
        string metadataURI; /// Metadata URI for the badge
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        address _ensAddress,
        address _issuer,
        uint256 _supply,
        bool _canHoldMultiple
    ) external;
}
