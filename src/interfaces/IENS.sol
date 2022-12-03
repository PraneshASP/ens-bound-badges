// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice Interface for ENS Resolver

interface IENS {
    function resolver(bytes32 nodeHash) external view returns (address);

    function addr(bytes32 nodeHash) external view returns (address);
}
