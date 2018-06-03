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

    Status status = Status.Initialize;
    bytes state;

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
    {
        Player storage player = players[msg.sender];
        require(player.addr == msg.sender);
        require(player.registred == false);
        require(player.deposit + player.extra == msg.value);
        player.registred = true;
        initialized++;
        if(playersCount == initialized)        
            start();
    }

    function start() public 
    {
        
    }

}