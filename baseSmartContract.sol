//SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract Allowance is Ownable{

    event AllowanceChanged(address indexed _forwho, address indexed _fromwhom, uint _oldamount, uint _newamount);
    
    function isOwner() internal view returns(bool) {

        return owner() == msg.sender;

    }

    mapping (address => uint) public allowance;

    function addAllowance(address _who, uint _amount) public onlyOwner{
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "you are not allowed");
        _;
    }
    function reduceAllowance(address _who, uint _amount) internal
    {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who]-_amount);
        allowance[_who] -= _amount;
    }
}

contract SharedWallet is Allowance {

     event moneySent(address indexed _to, uint _amount);
     event moneyRecieved(address indexed _from, uint _amount);

    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
       require(_amount <= address(this).balance, "there are not enough funds in the smart contract");

       if(!isOwner())
       {
           reduceAllowance(msg.sender, _amount);
       }

       emit moneySent(_to, _amount);
        _to.transfer(_amount);
    }

    function renounceOwnership() public view override onlyOwner{
        revert("cant renounce ownership here");
    }

    receive() external payable {
        emit moneyRecieved(msg.sender, msg.value);
    }
    
}