// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

import './Epsilon.sol';

contract Governance {
    
    Epsilon public tokenContract;

    address public owner;
    
    string[] public TicketArray;
    
   uint256 public MinVotingTokens = 500 * 10**9;
    
    struct TicketInUse {
        uint256 index;
        string name;
        uint256 endTime;
        uint256 startTime;
        address[] votedinFavor;
        uint256 numinFavor;
        address[] votedAgainst;
        uint256 numAgainst;
        
    }
    
    TicketInUse[] public TicketInUseArray;
    uint256 counter = 0;
    address[] public votersArray;
    mapping (uint256 => mapping(address=>bool))  MappingofVotersArray;

    
    constructor (address payable _TokenAddress) {
        owner = msg.sender;
        Epsilon _tokenContract = Epsilon(_TokenAddress);
        
        tokenContract = _tokenContract;
        
    }
    
    function addTicket(string memory name) public {
        require(msg.sender == owner,"This function can only be set by owner");
        TicketArray.push(name);
        
    } 
    
    function getTicketByIndex(uint256 index) public view returns(string memory){
        return TicketArray[index];
    } 

    
    function getTicketArray() public view returns(string[] memory){
        return TicketArray;
    } 
    
    function InitiateTicket(uint256 ticketIndex, uint256 time) public  {
        require(msg.sender == owner,"only owner can initialize the tickets");
        address[] memory addressinFavor;
        uint256 favor;
        address[] memory addressinAgainst;
        uint256 against;
        TicketInUse memory tx1 = TicketInUse(counter , TicketArray[ticketIndex],block.timestamp+time,block.timestamp ,addressinFavor,favor,addressinAgainst,against);
        TicketInUseArray.push(tx1);
        counter+=1;
    }
    
    function getTicketInUseByIndex(uint256 _index) public view returns(TicketInUse memory) {
         return TicketInUseArray[_index];
    }
    
    function getTicketInUseArray() public view returns(TicketInUse[] memory) {
         return TicketInUseArray;
    }
    
    
    function vote(uint256 _index, bool _vote) public {
        require(TicketInUseArray[_index].endTime > block.timestamp,"Voting time has ended");
        require(MappingofVotersArray[_index][msg.sender] == false,"you have already voted");
        
        if(_vote){
            TicketInUseArray[_index].numinFavor += tokenContract.balanceOf(msg.sender);
            TicketInUseArray[_index].votedinFavor.push(msg.sender); 
        }
        else if(!_vote){
            TicketInUseArray[_index].numAgainst += tokenContract.balanceOf(msg.sender);
            TicketInUseArray[_index].votedAgainst.push(msg.sender); 
        }
        MappingofVotersArray[_index][msg.sender] = true;
    }
    
    
    function retrieveVoteResult(uint256 _index) public view returns (uint256, uint256,string memory){
        require(TicketInUseArray[_index].startTime <block.timestamp,"voting has not yet started");
        require(TicketInUseArray[_index].endTime < block.timestamp,"voting has not yet ended");

        uint256 inFavor = TicketInUseArray[_index].numinFavor;
        uint256 against = TicketInUseArray[_index].numAgainst;
        string memory result;
        if(inFavor>against){result = "Favor";}else{result = " against";}

        return (inFavor,against,result);
        
        }

    function endVoting(uint256 _index) public {
        require(msg.sender==owner,"this function can only be invoke by owner");
        TicketInUseArray[_index].endTime = block.timestamp;
    }
}