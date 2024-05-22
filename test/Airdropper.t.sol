// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Airdropper} from "../src/Airdropper.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract AirdropperTest is Test {
    Airdropper public airdropper;
    IERC20 ion = IERC20(0x18470019bF0E94611f15852F7e93cf5D65BC34CA);
    address deployer = 0x1155b614971f16758C92c4890eD338C9e3ede6b7;
    address safe = 0x6EAC39BBe26f0d6Ab8DF0f974734D2228d4Da226;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mode"));
        vm.prank(deployer);
        airdropper = new Airdropper(address(ion));
        vm.prank(safe);
        ion.transfer(address(airdropper), 100_000_000 ether);
    }

    function test_onlyOwner(address sender) public {
        vm.assume(sender != address(airdropper));
        vm.assume(sender != deployer);
        vm.expectRevert();
        vm.prank(sender);
        address[] memory recipients = new address[](1);
        recipients[0] = address(1);

        uint256[] memory values = new uint256[](1);
        values[0] = 1;

        airdropper.drop(recipients, values);
    }

    function test_drop() public {
        uint256 NUM_RECIPIENTS = 1000;
        address[] memory recipients = new address[](NUM_RECIPIENTS);
        for (uint256 i = 0; i < NUM_RECIPIENTS; i++) {
            recipients[i] = vm.addr(i + 1);
        }

        uint256[] memory values = new uint256[](NUM_RECIPIENTS);
        for (uint256 i = 0; i < NUM_RECIPIENTS; i++) {
            values[i] = i + 1 ether;
        }

        vm.prank(deployer);
        airdropper.drop(recipients, values);
        for (uint256 i = 0; i < NUM_RECIPIENTS; i++) {
            assertEq(ion.balanceOf(recipients[i]), values[i]);
        }
    }
}
