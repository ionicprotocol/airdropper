// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Airdropper} from "../src/Airdropper.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {strings} from "solidity-stringutils/src/strings.sol";

contract AirdropperTest is Test {
    using strings for *;

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

    function test_readCsv() public {
        uint256 MAX_BATCH = 1000;
        string memory eof = "";
        vm.readLine("test.csv"); // skip header
        uint256 parsedSum = 0;
        vm.startPrank(deployer);
        bool eofReached = false;
        while (true) {
            if (eofReached) {
                break;
            }
            address[] memory recipients = new address[](MAX_BATCH);
            uint256[] memory values = new uint256[](MAX_BATCH);
            uint256 batchSize = 0;
            for (uint256 i = 0; i < MAX_BATCH; i++) {
                string memory line = vm.readLine("test.csv");
                if (keccak256(bytes(line)) == keccak256(bytes(eof))) {
                    eofReached = true;
                    break;
                }
                strings.slice memory s = line.toSlice();
                strings.slice memory delim = ",".toSlice();
                string[] memory parts = new string[](5);
                for (uint j = 0; j < parts.length; j++) {
                    parts[j] = s.split(delim).toString();
                }
                recipients[i] = stringToAddress(parts[0]);
                values[i] = stringToUint(parts[2]); // liquid_amount
                parsedSum += values[i];
                batchSize++;
            }
            console.log("Dropping batch");
            console.logUint(batchSize);
            airdropper.drop(recipients, values);
        }
        vm.stopPrank();
        console.logUint(parsedSum);
    }

    function stringToUint(string memory s) public pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function stringToAddress(string memory str) public pure returns (address) {
        bytes memory strBytes = bytes(str);
        require(strBytes.length == 42, "Invalid address length");
        bytes memory addrBytes = new bytes(20);

        for (uint i = 0; i < 20; i++) {
            addrBytes[i] = bytes1(hexCharToByte(strBytes[2 + i * 2]) * 16 + hexCharToByte(strBytes[3 + i * 2]));
        }

        return address(uint160(bytes20(addrBytes)));
    }

    function hexCharToByte(bytes1 char) internal pure returns (uint8) {
        uint8 byteValue = uint8(char);
        if (byteValue >= uint8(bytes1('0')) && byteValue <= uint8(bytes1('9'))) {
            return byteValue - uint8(bytes1('0'));
        } else if (byteValue >= uint8(bytes1('a')) && byteValue <= uint8(bytes1('f'))) {
            return 10 + byteValue - uint8(bytes1('a'));
        } else if (byteValue >= uint8(bytes1('A')) && byteValue <= uint8(bytes1('F'))) {
            return 10 + byteValue - uint8(bytes1('A'));
        }
        revert("Invalid hex character");
    }
}
