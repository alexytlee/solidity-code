pragma solidity ^0.4.24;

contract FundRaising {
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline; // this is a timestamp
    uint public goal;
    uint public raisedAmount = 0;
    
    constructor(uint _goal, uint _deadline) public {
        goal = _goal;
        deadline = now + _deadline;
        
        admin = msg.sender;
        minimumContribution = 10;
        
    }
    
    function contribute() public payable {
        require(now < deadline);
        require(msg.value >= minimumContribution);
        if(contributors[msg.sender] == 0) {
            noOfContributors++;
        }
        
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function getRefund() public {
        require(now > deadline);
        require(raisedAmount < goal);
        require(contributors[msg.sender] > 0);
        
        address receipient = msg.sender;
        uint value = contributors[msg.sender];
        
        receipient.transfer(value);
        contributors[msg.sender] = 0;
    }
}