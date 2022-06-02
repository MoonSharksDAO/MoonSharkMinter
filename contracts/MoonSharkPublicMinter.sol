// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IMoonSharkNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract MoonSharkPublicMinter is Ownable,Pausable {
  IMoonSharkNFT public moonSharkNFT;
  mapping(address => MintedMember) public mintedMembers;

  uint public MAX_CAP;
  uint public constant MAX_MINT_AMOUNT = 10;
  uint public constant SINGLE_MINT_FEE = 0.05 ether;

  struct MintedMember {
    uint mintedAmount;
    address memberAddress;
  }
  
  constructor(address _moonSharkNFT,uint maxCap) {
    moonSharkNFT = IMoonSharkNFT(_moonSharkNFT);
    MAX_CAP = maxCap;
  }

  function mint() external payable whenNotPaused {
    require(msg.value == SINGLE_MINT_FEE,"FEE ISN'T CORRECT");

    MintedMember storage member = mintedMembers[msg.sender];
    require(member.mintedAmount+1 <= MAX_MINT_AMOUNT,"REACHED MINT AMOUNT LIMIT");

    uint supply = moonSharkNFT.totalSupply();
    require(supply+1 <= MAX_CAP,"MAX_CAP REACHED");

    moonSharkNFT.mintTo(1,msg.sender);
    member.mintedAmount += 1;
  }

  function batchMint(uint quantity) external payable whenNotPaused {
    require(msg.value == SINGLE_MINT_FEE*quantity,"FEE ISN'T CORRECT");
    require(quantity <= MAX_MINT_AMOUNT,"ABOVE BATCH MINT LIMIT");

    MintedMember storage member = mintedMembers[msg.sender];
    require(member.mintedAmount+quantity <= MAX_MINT_AMOUNT,"REACHED MINT AMOUNT LIMIT");

    uint supply = moonSharkNFT.totalSupply();
    require(supply+quantity <= MAX_CAP,"MAX_CAP REACHED");

    moonSharkNFT.mintTo(quantity,msg.sender);
    member.mintedAmount += quantity;
  }

  function retrieveFund(address treasury) external onlyOwner whenPaused {

    (bool success, ) = treasury.call{value: address(this).balance }("");
    require(success, "FAILED TO SEND FUND TO TREASURY");

  }

  function pause() external onlyOwner {
    _pause();
  }

  function unPause() external onlyOwner {
    _unpause();
  }

}
