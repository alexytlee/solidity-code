pragma solidity 0.4.24;

// https://github.com/ethereum/EIPs/issues/20
interface ERC20Interface {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    // function decimals() public view returns(uint digits);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract DKLM is ERC20Interface {
    string public name = "Diu Kui Lo Mo";
    string public symbol = "DKLM";
    uint public decimals = 18;
    uint public supply;
    address public founder;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;
    // allowed[0x1111....][02222....] = 100;
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    constructor() public{
        supply = 10000000000;
        founder = msg.sender;
        balances[founder] = supply;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint _value) public returns (bool success){
        require(balances[msg.sender] >= _value);
        require(_value > 0);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint _value) public returns (bool success){
        require(allowed[_from][_to] >= _value);
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][_to] -= _value;
    }

    function totalSupply() public view returns (uint totalSupply){
        return supply;
    }
    function balanceOf(address _owner) public view returns (uint balance){
        return balances[_owner];
    }
    // this is what makes the token transferrable
    function transfer(address _to, uint _value) public returns (bool success){
        require(balances[msg.sender] >= _value && _value > 0);
        balances[_to] += _value;
        balances[msg.sender] -= _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

}

contract DKLMICO is DKLM{
    address public admin;
    address public deposit;
    // token price in wei: 1DKLM = 0.001 ETHER, 1 ETHER = 1000 CRPT
    uint tokenPrice = 1000000000000000;
    // 300 Ether in wei
    uint public hardCap = 300000000000000000000;
    uint public raisedAmount;
    uint public salesStart = now;
    uint public salesEnd = now + 604800; // one weeks
    uint public coinTradeStart = salesEnd + 604800; // transferrable in a week after salesEnd 
    uint public maxInvestment = 5000000000000000000; // 5 ETHER
    uint public minInvestment = 10000000000000000;  // 1 ETHER
    enum State { beforeStart, running, afterEnd, halted }
    State public icoState;
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
    event Invest(address investor, uint value, uint tokens);
    constructor(address _deposit) public{
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }
    // emergency stop
    function halt() public onlyAdmin{
        icoState = State.halted;
    }
    // restart
    function unhalt() public onlyAdmin{
        icoState = State.running;
    }
    
    function invest() payable public returns(bool){
        // invest only in running
        icoState = getCurrentState();
        require(icoState == State.running);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        uint tokens = msg.value / tokenPrice;
        require(raisedAmount + msg.value <= hardCap);
        raisedAmount += msg.value;
        // add tokens to investor balance from founder balance
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value); // transfer eth to the deposit address
        emit Invest(msg.sender, msg.value, tokens);
        return true;
    }
    function burn() public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0; // burn everything from founder that's left unsold
    }
    function transfer(address to, uint value) public returns(bool){
        require(block.timestamp > coinTradeStart);
        super.transfer(to, value);
    }
    function transferFrom(address _from, address _to, uint _value) public returns(bool){
        require(block.timestamp > coinTradeStart);
        super.transferFrom(_from, _to, _value);
    }
    // fallback function
    function () payable public{
        invest();
    }
    // change deposit address
    function changeDepositAddress(address newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }
    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        } else if(block.timestamp < salesStart) {
            return State.beforeStart;
        } else if(block.timestamp >= salesStart && block.timestamp <= salesEnd) {
            return State.running;
        } else {
            State.afterEnd;
        }
    }
}

// Original deployed here https://rinkeby.etherscan.io/token/0x1db151d9d0ac64d70f20c039bf86caf07d7a0308
// Full deployed here https://rinkeby.etherscan.io/tx/0x406fadd0eca2a469501adc9b7ba0c8468f6b6b9275a2d08e5bd6947d98d0ec0d