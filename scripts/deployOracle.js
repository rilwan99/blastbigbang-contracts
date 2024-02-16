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
  const Oracle = await ethers.getContractFactory("WeatherOracle");

  // Deploy the contract
  const temperature = 20;
  const triggerAddress = "0xA7bf720D2Ec5F1Ac2D65650CB2795D0869712096"
  const oracle = await Oracle.deploy(temperature,triggerAddress);

  // Wait for the contract to be mined
  await oracle.waitForDeployment(); //v5 uses deployed() instead

  const address = await oracle.getAddress();
  console.log(`Oracle deployed to Address: ${address}`); // v5 uses simpleAccount.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});