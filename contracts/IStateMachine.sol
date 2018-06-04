pragma solidity 0.4.23;

contract IStateMachine {

    function verifyTx(bytes state, bytes transaction, bytes newState) public returns(bool);
    

}