pragma solidity ^0.4.19;

contract Dice {
    address public owner;
    uint public constant MIN_BET = 0.01 ether;
    uint public maxBetPercent = 5;
    uint public constant EXPIRY_BLOCKS = 250;

    struct Bet {
        address player;
        uint8 choice;
        uint amount;
        uint blockNumber;
        bool settled;
    }

    Bet[] public bets;
    event BetPlaced(uint indexed id, address indexed player, uint8 choice, uint amount);
    event BetSettled(uint indexed id, address indexed player, uint8 roll, uint payout);

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

    function placeBet(uint8 choice) public payable returns (uint id) {
        require(choice >= 1 && choice <= 6);
        require(msg.value >= MIN_BET);
        require(msg.value <= (this.balance - msg.value) * maxBetPercent / 100);
        id = bets.length;
        bets.push(Bet(msg.sender, choice, msg.value, block.number, false));
        BetPlaced(id, msg.sender, choice, msg.value);
    }

    function settle(uint id) public {
        Bet storage b = bets[id];
        require(!b.settled);
        require(block.number > b.blockNumber + 1);
        require(block.number <= b.blockNumber + EXPIRY_BLOCKS);
        b.settled = true;
        uint8 result = uint8(uint(keccak256(block.blockhash(b.blockNumber + 1), id)) % 6) + 1;
        uint payout = 0;
        if (result == b.choice) {
            payout = b.amount * 5;
            b.player.transfer(payout);
        }
        BetSettled(id, b.player, result, payout);
    }

    // blockhash() returns 0 after 256 blocks, so late bets are refunded instead
    function refund(uint id) public {
        Bet storage b = bets[id];
        require(!b.settled);
        require(block.number > b.blockNumber + EXPIRY_BLOCKS);
        b.settled = true;
        b.player.transfer(b.amount);
    }
}
