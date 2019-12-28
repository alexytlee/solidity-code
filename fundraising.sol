pragma solidity ^0.4.24;

contract FundRaising {
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline; // this is a timestamp
    uint public goal;
    uint public raisedAmount = 0;
    
    struct Request {
        string description;
        address recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
    
    Request[] public requests;
    
    constructor(uint _goal, uint _deadline) public {
        goal = _goal;
        deadline = now + _deadline;
        
        admin = msg.sender;
        minimumContribution = 10;
        
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
    
    function createRequest(string _description, address _recipient, uint _value) public onlyAdmin {
        Request memory newRequest = Request({
            description: _description,
            recipient: _recipient,
            value: _value,
            completed: false,
            noOfVoters: 0
        });
        requests.push(newRequest);
    }
    
    function voteRequest(uint index) public {
        Request storage thisRequest = requests[index];
    
        require(contributors[msg.sender] > 0);
        require(thisRequest.voters[msg.sender] == false);
        
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }
    
    function makePayment(uint index) public onlyAdmin {
        Request storage thisRequest = requests[index];
        require(thisRequest.completed == false);
        
        require(thisRequest.noOfVoters > noOfContributors / 2); // More than 50% voted
        thisRequest.recipient.transfer(thisRequest.value); // Transfer money to the recipient
        
        thisRequest.completed = true;
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