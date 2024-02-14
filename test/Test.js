const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
const { ethers } = require("hardhat");
  
  describe("Staking Interaction", function () {


    it ("Grant WeGame contract approval to transfer GTokens", async function() {
        const [player] = await ethers.getSigners();
        console.log("Player address: ", player.address);

        console.log("GToken address: ", process.env.TOKEN_ADDRESS);
        const gToken = await ethers.getContractAt("ERC20", process.env.TOKEN_ADDRESS);

        const wegameContractAddress = process.env.WEGAME_ADDRESS;
        console.log("WeGame address: ", wegameContractAddress);

        const approval = await gToken.approve(
            wegameContractAddress, 
            1,
        );
        console.log("Approve transaction: ", approval.hash)

        const transfer = await gToken.transferFrom(
            player.address, 
            wegameContractAddress, 
            1,
        )
        console.log("Transfer transaction: ", transfer.hash)
    });

  });