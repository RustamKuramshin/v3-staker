// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract VulnerableBank {
    mapping(address => uint256) public balances;

    
    address public owner = tx.origin;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] -= _amount;
    }

   
    function destroy() public {
        selfdestruct(msg.sender);
    }

    
    function changeOwner(address newOwner) public {
        require(tx.origin == owner, "Not authorized");
        owner = newOwner;
    }
}
