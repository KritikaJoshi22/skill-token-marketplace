// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//smart contract for the token market place

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SkillToken is ERC20 {
    address public owner;

    // Modifier to ensure that only the owner can execute certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        owner = msg.sender;
    }

    // Mint new skill tokens
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    // Exchange skill tokens
    function exchange(address recipient, uint256 amount) external {
        // Basic exchange logic, ensuring the sender has enough tokens
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, recipient, amount);
    }
}
