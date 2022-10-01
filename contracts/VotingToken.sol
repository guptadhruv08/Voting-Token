//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./token.sol";

contract VotingTokens{

    Token public token;

    uint256 public constant tokensPerEth = 100;

    address[5] candidatesAddress =  [0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,0x617F2E2fD72FD9D5503197092aC168c91465E7f2,0x17F6AD8Ef982297579C203069C1DbfFE4348c372];
    
    mapping(address => Candidate) candidates;
    uint public tokenPrice;
    uint public tokenSupplyForVoting;
    address public owner;
    uint public votingStartingTime;
    uint public deadline;
    enum voting {Close,Open}
    voting public voteStatus;

      struct Candidate {
        bool isValid;
        uint votes;
    }


    // constructor(address[] memory _candidates,address tokenAddress) {
    constructor(address tokenAddress) {
        token = Token(tokenAddress);
        owner = msg.sender;
        for(uint i=0; i < candidatesAddress.length; i++){
            candidates[candidatesAddress[i]].isValid = true;
        }
    }

    modifier onlyOwner() {
        require(owner == msg.sender,"Need owner to open the voting");
        _;
    }

    function openVoting(uint _deadline) public onlyOwner{
        require(voteStatus == voting.Close,"Voting is already Opened");
        votingStartingTime = block.timestamp;
        deadline = block.timestamp + _deadline;
        // tokenPrice = _tokenPrice;
        // tokenSupplyForVoting = _tokenSupply;
        voteStatus = voting.Open;
    }

    function closeVoting() public onlyOwner {
        require(voteStatus == voting.Open,"Voting is already closed");
        voteStatus = voting.Close;
        deadline = 0;
        tokenPrice = 0;
        tokenSupplyForVoting = 0;
    }

    function vote(address _candidate) public {
        address user = msg.sender;
        require(token.balanceOf(msg.sender)>1,"You don't have token to vote right now. Please buy some token first");
        require(block.timestamp < deadline,"Voting is closed");
        require(voteStatus == voting.Open,"Voting is closed now");
        candidates[_candidate].votes += 1;

        // token.allowance(msg.sender, address(this));
        // (bool approve) = token.approve(address(this),100000000000000000000);
        // require(approve, "Not approved");

        (bool sent) = token.transferFrom(user,address(this),100000000000000000000);
        require(sent, "Failed");
    }

    function checkVotesOfCandidates(address _candidate) public view returns(uint) {
        return candidates[_candidate].votes;
    }

    function yourTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

    function buy() public payable{
        require(voteStatus == voting.Open,"Voting is closed now");
        require(msg.value > 0,"Send some eth to buy Token");
        address user = msg.sender;
        uint ethAmount = msg.value;
        uint tokenAmount = ethAmount * tokensPerEth;

        (bool sent) = token.transfer(user,tokenAmount);
        require(sent, "Failed");
    }


}