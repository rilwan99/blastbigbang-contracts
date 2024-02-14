// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {ethers} = require("hardhat");
require("dotenv").config();

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  // Compile the contract
  const Broker = await ethers.getContractFactory("Broker");

  // Deploy the contract
  const broker = await Broker.deploy(process.env.TOKEN_ADDRESS,process.env.IBLAST_ADDRESS,9999999);

  // Wait for the contract to be mined
  await broker.waitForDeployment(); //v5 uses deployed() instead

  const address = await broker.getAddress();
  console.log(`Broker deployed to Address: ${address}`); // v5 uses simpleAccount.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});