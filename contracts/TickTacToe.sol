pragma solidity 0.4.23;

contract TickTacToe {

    address[2] players;
    enum Move { PLAYER_1_MOVE, PLAYER_2_MOVE }
    Move move;

    bytes field;

    constructor(address _player1, address _player2) public
    {
        players[0] = _player1;
        players[1] = _player2;
    }

    modifier rightPlayer()
    {
        require(msg.sender == players[uint(move)]);
        _;
    }

    function doMove()
        public
        rightPlayer
    {
        field[3] = 0;
        field[1] = "g";
        field[2] = "j";
    }



}