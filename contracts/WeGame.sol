// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// Import the ABI of the oracle, token and VRF contracts
import "./WeatherOracle.sol";
import "./GToken.sol";

contract WeatherGame is Ownable {
    using SafeCast for uint256;
    GToken public gToken;
    WeatherOracle public weOracle;
    uint256 public tokenRewardAmount = 10000000000000000000; // 10 gTokens in wei
    uint256 public depositAmount = 10000000000000000000; // 10 gTokens in wei

    // below are the variables for the randomize function to get a random number
    uint public constant SCALE = 100;  // Set SCALE to the desired range (1 to 100)
    // Revised SCALIFIER using SafeMath
    uint256 public constant SCALIFIER = 115792089237316195423570985008687907853269984665640564039457584007913129639935 / SCALE; // this scalifier helps to ensure that the range for the values we get from the return is always between 0(inclusive) and 100(inclusive) as long we divide the generated number from the keccak algo is divided by the scalifier as defined. if the generated number is < scalifier, when we divide by the scalifier the scaled value will be 0. If the generated number is same as the MAX variable when we dvide by the scalifier we will get 100.

		modifier requiresMinimumDeposit() {
		    require(gToken.balanceOf(msg.sender) >= depositAmount, "Insufficient gToken balance for deposit");
		    require(gToken.allowance(msg.sender, address(this)) >= depositAmount, "Contract is not approved to spend gTokens");
		    require(gToken.balanceOf(address(this)) >= tokenRewardAmount, "Insufficient gToken balance in Game Contract");
		    _;
		}

    event GamePlayed(address indexed player, string chosenWeather, string actualWeather, bool won, uint256 ethDeposited, uint256 tokenReward);
    event newOracleAddressEvent(WeatherOracle weOracle);
    event newDepositAmountSet(uint256 depositAmount);
    event newTokenRewardAmountSet(uint256 tokenRewardAmount);

    constructor(address _tokenContract, address _oracleContract) Ownable(msg.sender){
        gToken = GToken(_tokenContract);
        weOracle = WeatherOracle(_oracleContract);
    }

    function setOracleAddress(address _oracleInstanceAddress) public onlyOwner {
        weOracle = WeatherOracle(_oracleInstanceAddress);
        emit newOracleAddressEvent(weOracle);
    }

    function setDepositAmount(uint256 _amount) public onlyOwner {
        depositAmount = _amount;
        emit newDepositAmountSet(_amount);
    }

    function setTokenRewardAmount (uint256 _amount) public onlyOwner {
        tokenRewardAmount = _amount;
        emit newTokenRewardAmountSet(_amount);
    }

    // Function to get the temperature from WeatherOracle
    function getTemperatureFromOracle() public view returns (uint256) { // for testing purposes it makes sense that this function is public, although in actuality it makes sense if it is internal
        // Call the getTemperature() function from WeatherOracle
        return weOracle.getTemperature();
    }

    function randomize(bool test) public view returns (uint256 scaled, uint256 temp) { // for testing purposes it makes sense that this function is public, although in actuality it makes sense if it is internal

  
        temp = getTemperatureFromOracle(); // getting the temperature from the oracle contract

        uint256 seed = uint(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1),temp))); // The number is tyring to be as random as possible we are still depending on the blockhash and the current time (deterministic), I am using more sources of entropy like temperature and the randomNumber from the chainlink VRF
          
        // Ensure SCALIFIER is not 0 to avoid division by zero
        require(SCALIFIER != 0, "SCALIFIER cannot be zero");
        scaled = seed / SCALIFIER; // the scaled values would be from 0 to 100, it will be 0 if the seed is less than the scalifier, also it will only be 100 if we reach te max possible value for a uint256
        // I do not need an explicit return statement because the compiler undersatnds that the value of scaled and temperature should be returned
    }

		// Function to allow users to approve the contract to spend gTokens on their behalf
		function approveContract(uint256 amount) external {
		    gToken.approve(address(this), amount);
		}

    function play(string memory chosenWeather, bool test) external payable requiresMinimumDeposit returns (string memory) { // memory is temperorary data and won't be stored anywhere,

				require(gToken.transferFrom(msg.sender, address(this), depositAmount), "Failed to transfer gTokens to contract"); 
				
        // Generate a random number between 0 and 100 using the randomize function, it also returns me the temperature, didn't want to call the get function again because I would be calling it twice
        (uint256 randomNumber, uint256 temp) = randomize(test); 

        uint256 rainyProbability = 20;
        uint256 cloudyProbability = 30;
        uint256 sunnyProbability = 50;

        if (temp < 2500) { // low temperature
            rainyProbability = 50;
            cloudyProbability = 30;
            sunnyProbability = 20;
        } else if (temp > 2600) { // high temperature
            rainyProbability = 20;
            cloudyProbability = 30;
            sunnyProbability = 50;
        } else { // meidium temperature
            rainyProbability = 20;
            cloudyProbability = 50;
            sunnyProbability = 30;
        }

        string memory actualWeather;

        if (randomNumber < rainyProbability) {
            actualWeather = "Rainy";
        } else if (randomNumber < rainyProbability + cloudyProbability) {
            actualWeather = "Cloudy";
        } else {
            actualWeather = "Sunny";
        }

        bool won = keccak256(abi.encodePacked(chosenWeather)) == keccak256(abi.encodePacked(actualWeather));

        if (won) {
            payable(msg.sender).transfer(msg.value); 
            gToken.transfer(msg.sender, tokenRewardAmount + depositAmount);
            emit GamePlayed(msg.sender, chosenWeather, actualWeather, true, msg.value, tokenRewardAmount);
        }else {
            emit GamePlayed(msg.sender, chosenWeather, actualWeather, false, msg.value, 0);
        }

        return actualWeather;

    }

    fallback() external payable {}

    receive() external payable{}

    // Function to deposit tokens into the contract
    function depositTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        // Check the allowance to ensure it's set correctly
        require(gToken.allowance(msg.sender, address(this)) >= amount, "Allowance not set correctly, please approve amount from the token contract or call approveTransfer"); // have to call the approve function from gToken first -> can do this in the front end
        gToken.transferFrom(msg.sender, address(this), amount);
    }

    // Function to withdraw tokens from the contract (only for contract owner)
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(amount <= gToken.balanceOf(address(this)), "Insufficient balance");
        gToken.transfer(owner(), amount);
    }
}