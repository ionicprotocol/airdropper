pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Airdropper is Ownable {
    IERC20 public immutable token;
    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function drop(
        address[] calldata recipients,
        uint256[] calldata values
    ) external onlyOwner {
        require(
            recipients.length == values.length,
            "Airdropper: recipients and values length mismatch"
        );
        for (uint256 i = 0; i < recipients.length; i++) {
            if (values[i] > 0 && recipients[i] != address(0)) {
                token.transfer(recipients[i], values[i]);
            }
        }
    }

    function withdraw() external onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}
