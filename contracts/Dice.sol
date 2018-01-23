pragma solidity ^0.4.19;

contract Dice {
    address public owner;
    uint public constant MIN_BET = 0.01 ether;

    function Dice() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function fund() public payable {}

    function withdraw(uint amount) public onlyOwner {
        require(amount <= this.balance);
        owner.transfer(amount);
    }

    function roll(uint8 choice) public payable {
        require(choice >= 1 && choice <= 6);
        require(msg.value >= MIN_BET);
        uint8 result = uint8(uint(keccak256(block.blockhash(block.number - 1), msg.sender)) % 6) + 1;
        if (result == choice) {
            msg.sender.transfer(msg.value * 5);
        }
    }
}
