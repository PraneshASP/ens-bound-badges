// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/src/Script.sol";

import {ENSBoundBadge} from "../src/ENSBoundBadge.sol";
import {ENSBoundBadgeFactory} from "../src/ENSBoundBadgeFactory.sol";

contract DeployScript is Script {
    address public constant ENS_ADDRESS =
        0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address _ensBoundBadgeInstance = address(new ENSBoundBadge());

        address _ensBoundBadgeFactoryInstance = address(
            new ENSBoundBadgeFactory(_ensBoundBadgeInstance, ENS_ADDRESS)
        );

        vm.stopBroadcast();

        console.log(
            "ENSBoundBadge implementation contract deployed at : ",
            _ensBoundBadgeInstance
        );
        console.log(
            "ENSBoundBadgeFactory contract deployed at : ",
            _ensBoundBadgeFactoryInstance
        );
    }
}
