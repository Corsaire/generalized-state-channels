pragma solidity 0.4.23;

contract StateChannelsManager {

    enum Status { Initialize, Started }

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

    uint initialized = 0; 
    uint playersCount;

    mapping(address => Player) players;

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
        require(playersCount >= 1);
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

    function disputeClose()
    {

    }

    function disputeWaitingForTX()
    {

    }

    function disputeWaitingForSig()
    {

    }

    function submitState(bytes state, uint8 v1, bytes32 r1, bytes32 s1, uint8 v2, bytes32 r2, bytes32 s2)
    {
        bytes32 stateHash = keccak256(state, address(this));
    }

    
    function confirmState(address addr, bytes32 _hash, uint8 v, bytes32 r, bytes32 s)
    private
    returns(bool)
    {
        require(addr == ecrecover(_hash,v,r,s));
    }

    function dispute(bytes state, bytes32 transaction, address player, uint8 v, bytes32 r, bytes32 s) public
    isStatus(Status.Started)
    isPlayer
    {
        require(msg.sender != signer);
        bytes32 txHash = keccak256(state, transaction);
        address signer = ecrecover(txHash,v,r,s);
        require(signer == player);
        require(players[player].registred);
        
    }

}