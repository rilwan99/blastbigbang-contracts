// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract WeatherOracle is Ownable{

    // address of the node.js server listening for the event
    address private triggerAddress;

    uint256 private temperature;

    modifier requiresTriggerAddress() {
      require(msg.sender == triggerAddress, "Only the Oracle related service can trigger this function");
      _;
    }

    //event to say that new weather is set
    event NewTemperatureSet(uint256 newTemp);

    constructor(uint256 _temperature,address _triggerAddress) Ownable(msg.sender){
        temperature = _temperature;
        triggerAddress = _triggerAddress;
    }

    function getTemperature() public view returns (uint256) {
      return temperature;
    }

    function getTriggerAddress() public view returns (address) {
      return triggerAddress;
    }

    function setTriggerAddress(address _triggerAddress) public onlyOwner {// trigger address is the address used by the node.js service
        triggerAddress = _triggerAddress;
    }

    function updateWeatherData(uint256 _temperature) public requiresTriggerAddress{ // this function can only be called by the trigger address
        //when update weather is called by node.js upon API results, data is updated
        temperature = _temperature;

        // emit an event to signal that weather data is available (not so necessary anymore)
        emit NewTemperatureSet(_temperature); // honestly it is not neccesary and could be remove to reduce gas
    }

}