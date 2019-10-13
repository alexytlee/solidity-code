pragma solidity ^0.4.24;

contract Lottery{
    address[] public players; // dynamic array with player addresses
    address public manager;
    constructor() public{
        manager = msg.sender;
    }
    // this fallback payable function will be automatically called when somebody sends ether to our contract address
    function () payable public{
        require(msg.value >= 0.01 ether);
        players.push(msg.sender); // add the address of the account that sends ether to players array
    }
    function get_balance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance; // return contract balance
    }
    function random() public view returns(uint256){
        return uint256(keccak256(block.difficulty, block.timestamp, players.length));
    }
    function selectWinner() public{
        require(msg.sender == manager);
        uint r = random();
        address winner;
        uint index = r % players.length;
        winner = players[index];
        //transfer contract balance to the winner address
        winner.transfer(address(this).balance);
        players = new address[](0);
    }
}

// Launched on this contract: 0x04710Ea30afa91Cf05B1dd65754a4E0549F75B9C
// https://rinkeby.etherscan.io/address/0x04710ea30afa91cf05b1dd65754a4e0549f75b9c