pragma solidity 0.4.23;

import "./IStateMachine.sol";

contract StateChannelsManager {

    enum Status { Initialize, Started, Dispute }

    struct Player
    {
        bool registred;
        address addr;
        uint deposit;
        uint extra;        
    }

    struct State
    {
        uint txNumber;        
        bytes state;
    }

    Status status = Status.Initialize;
    State lastState;
    IStateMachine sm;

    uint initialized = 0; 

    uint deadline;
    

    mapping(address => Player) players;
    address player1;
    address player2;

    modifier isPlayer()
    {
        require(msg.sender == players[msg.sender].addr);
        _;
    }

    modifier isStatus(Status _status)
    {
        require(status == _status);
        _;
    }

    constructor(address[] _ads, uint[] _deposits, uint[] _extras) public 
    {
        playersCount = _ads.length;
        require(playersCount == 2);
        require(playersCount == _deposits.length);
        require(playersCount == _extras.length);

        for(uint i = 0; i < _ads.length; i++)
            players[_ads[i]] = Player(false, _ads[i], _deposits[i], _extras[i]);
    }

    function register() public payable
    isStatus(Status.Initialize)
    isPlayer
    {
        Player storage player = players[msg.sender];
        require(player.registred == false);
        require(player.deposit + player.extra == msg.value);
        player.registred = true;
        initialized++;
        if(playersCount == initialized)        
            start();
    }

    function start() private 
    {
        status = Status.Started;

    }

    function close() public
    {
        if(sm.canClose())
        {
            
        }
    }

    function disputeWaitingForTX() public
    {

    }

    function disputeWaitingForSig() public
    {

    }

    /**
        This method is called by a party, if counterparty denies to sign transaction.
     */
    function subitTX(bytes transaction, bytes newState) 
    isPlayer
    public
    {
        sm.verifyTx(lastState.state, transaction, newState);
    }

    function submitState(uint txCount, bytes state, uint8 v1, bytes sig1, bytes sig2) external
    {
        require(txCount > lastState.txNumber);
        bytes32 stateHash = keccak256(txCount, state, address(this));
        require(confirmState(player1, stateHash, sig1));
        require(confirmState(player2, stateHash, sig2));
    }
    
    function confirmState(address addr, bytes32 _hash, bytes sig)
    external
    returns(bool)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            v := calldataload(sig)
            r := calldataload(add(sig, 1))
            s := calldataload(add(sig, 33))
        }
        return (addr == ecrecover(_hash,v,r,s));
    }

}