pragma solidity 0.4.23;

import "./IStateMachine.sol";

contract StateChannelsManager {

    enum Status { Initialize, Started, Refunding, Closed }
    
    struct Player
    {
        bool registred;
        address addr;
        uint deposit;
        uint extra;  
        uint refund;      
    }

    struct State
    {
        uint txNumber;        
        bytes state;
    }

    Status status = Status.Initialize;
    State lastState;
    IStateMachine sm;

    uint deadline;
    
    mapping(address => Player) players;
    address[2] playersAds;

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

    modifier isStatuses(Status[] _statuses)
    {
        bool t = false;
        for(uint i = 0; i < _statuses.length; i++)
            if(_statuses[i] == status)
            {
                t = true;
                break;
            }
        require(t);
        _;
    }

    constructor(address[] _ads, uint[] _deposits, uint[] _extras) public 
    {
        require(2 == _ads.length);
        require(2 == _deposits.length);
        require(2 == _extras.length);

        for(uint i = 0; i < _ads.length; i++)
            players[_ads[i]] = Player(false, _ads[i], _deposits[i], _extras[i]);

        playersAds[0] = _ads[0];
        playersAds[1] = _ads[1];
    }

    function register() public payable
    isStatus(Status.Initialize)
    isPlayer
    {
        Player storage player = players[msg.sender];
        require(player.registred == false);
        require(player.deposit + player.extra == msg.value);
        player.registred = true;
        
        if(players[playersAds[0]].registred && players[playersAds[1]].registred)        
            start();
    }

    function start() private 
    {
        status = Status.Started;
    }

    function closeChannel() public
    isPlayer
    {
        require(status == Status.Started || status == Status.Initialize);
        uint[2] memory refunds = sm.tryClose();
        for(uint i = 0; i < 2; i++)
            players[playersAds[i]].refund = refunds[i];
        status = Status.Refunding;
    }

    function withdraw() public
    isPlayer
    isStatus(Status.Refunding)
    {
    }

    /**
        This method is called by a party, if counterparty denies to sign transaction.
     */
    function subitTX(uint txNumber, bytes transaction, bytes newState) 
    isPlayer
    public
    {
        sm.verifyTx(lastState.state, transaction, newState);
        lastState.state = State(newState, txNumber);
    }

    function submitState(uint txNumber, bytes state, uint8 v1, bytes sig1, bytes sig2) 
    external
    {
        require(txNumber > lastState.txNumber);
        bytes32 stateHash = keccak256(txNumber, state, address(this));
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