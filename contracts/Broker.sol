// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GToken.sol";
import "./IBlast.sol";

contract Broker {
    address public owner;
    address public blastAddress;
    uint256 public nextGTokenId;
    GToken public gToken;
    uint256 public releaseBlock;
    uint256 public totalDeposits;

    struct Deposit {
        address depositor;
        uint256 amount;
        uint256 releaseBlock;
    }

    mapping(address => uint256[]) private depositorDepositIds;
    mapping(uint256 => Deposit) public deposits;

    event DepositMade(address indexed depositor, uint256 depositId, uint256 amount, uint256 releaseBlock);
    event GTokensClaimed(address indexed claimer, uint256 depositId, uint256 gAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address _gToken, address _blastAddress, uint256 _releaseBlock) {
        owner = msg.sender;
        gToken = GToken(_gToken);
        releaseBlock = _releaseBlock;
        blastAddress = _blastAddress;
        IBlast(_blastAddress).configureAutomaticYield();
    }

    function deposit() external payable {
        require(releaseBlock > block.number, "Release block must be in the future");
        uint256 depositId = nextGTokenId++;

        depositorDepositIds[msg.sender].push(depositId);
        deposits[depositId] = Deposit({
            depositor: msg.sender,
            amount: msg.value,
            releaseBlock: releaseBlock
        });

        emit DepositMade(msg.sender, depositId, msg.value, releaseBlock);

        // Mint GToken tokens to the depositor based on the deposited amount
        gToken.mint(msg.sender, msg.value);
        totalDeposits += msg.value; // Update totalDeposits
    }

    function claimGTokens(uint256 depositId) external {
        Deposit storage depositInfo = deposits[depositId];
        require(depositInfo.depositor == msg.sender, "You are not the depositor");
        require(block.number >= depositInfo.releaseBlock, "Deposit is not yet matured");

        // Get the gToken amount
        uint256 gTokenAmount = gToken.balanceOf(address(this));

        // If there are gTokens available, calculate the extra value
        uint256 yield = 0;
        if (gTokenAmount > 0) {
            // Call calculateYield function with the gToken amount
            yield = calculateYield(gTokenAmount);
        }

        // Burn the gTokens
        gToken.burn(address(this), gTokenAmount);

        // Refund the deposited ETH to the depositor along with the extra value
        uint256 refundAmount = depositInfo.amount + yield;
        payable(msg.sender).transfer(refundAmount);

        // Emit event
        emit GTokensClaimed(msg.sender, depositId, refundAmount);

        // Update totalDeposits amount
        totalDeposits -= depositInfo.amount;

        // Clear the deposit record
        delete deposits[depositId];
    }


    function calculateYield(uint256 gTokenAmount) internal view returns (uint256) {
        // Get the current ETH balance of the contract
        uint256 ethBalance = address(this).balance;

        // Subtract the total deposits from the ETH balance
        uint256 netEthBalance = ethBalance - totalDeposits;

        // Ensure there is enough net ETH balance to distribute yield
        require(netEthBalance >= 0, "Insufficient ETH balance for yield distribution");

        // Calculate the percentage of the yield that the user is eligible for
        // based on their gToken amount and the total supply of gTokens
        uint256 yieldPercentage = (gTokenAmount * 1e18) / gToken.totalSupply();

        // Calculate the user's share of the net ETH balance based on the yield percentage
        uint256 userYield = (netEthBalance * yieldPercentage) / 1e18;

        return userYield;
    }

    function withdrawOwnerFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getDepositorDepositIds(address depositor) external view returns (uint256[] memory) {
        return depositorDepositIds[depositor];
    }

    function getDepositInfo(uint256 depositId) external view returns (address depositor, uint256 amount, uint256 releaseBlock) {
        Deposit memory userDeposit = deposits[depositId];
        return (userDeposit.depositor, userDeposit.amount, userDeposit.releaseBlock);
    }

    function setReleaseBlock(uint256 _releaseBlock) external onlyOwner {
        require(releaseBlock > block.number, "Release block must be in the future");
        releaseBlock = _releaseBlock;
    }
}
