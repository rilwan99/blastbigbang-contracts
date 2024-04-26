# Blast Big Bang Contracts
Contracts for [Blast Big Bang Competition](https://blast.io/en/bigbang)

# Contract Address
The **Iblast** contract serves as an interface for interaction within the Blast network. It defines standard functionalities or state variables that are essential for the other contracts to interact seamlessly on the Blast layer.
- [Iblast](https://testnet.blastscan.io/address/0x4300000000000000000000000000000000000002)

The  **GToken** contract manages the tokenization aspect of the game. It is responsible for minting GTokens, which represent the locked ETH. These tokens are used by players to place bets in the game. The contract handles operations such as token issuance, transfers, and possibly token burning.
- [GToken](https://testnet.blastscan.io/token/0x2735Cda07b8394Cd4315E12476c5eB6437F70093)

The **Broker** contract acts as the middleman between the game players and the Oracle. It is responsible for collecting bets, holding stakes, and distributing winnings based on the Oracle's data. This contract ensures that bets are placed correctly and that payouts are handled based on the game's outcome.
- [Broker](https://testnet.blastscan.io/address/0x3ed337454c122F77FE139454178911453E4e9CC4)

The **Oracle** contract provides reliable external data (weather data) to the smart contracts. The Oracle's role is to fetch accurate weather data from outside sources and provide it to the blockchain in a trustable manner. This data is used to determine the outcome of bets placed in the game.
- [Oracle](https://testnet.blastscan.io/address/0xa3216C630E7AAb219503A128B98447039B14c8B5)

The **Game** contract is the core of the betting application. It coordinates the game's logic, including accepting player entries, interacting with the GToken for betting purposes, and communicating with the Broker and Oracle to determine and settle the bets based on weather conditions.
- [Game](https://testnet.blastscan.io/address/0xD6db42BbC0967a1B91C091a702D32181ff83679a)

# Presentation
Check out the presentation on [Loom!](https://www.loom.com/share/bc80ff95d75b4b2195c04241712019cb?sid=a4a439db-5cb0-4977-a25a-d7f94a42d6b8)
https://www.loom.com/share/bc80ff95d75b4b2195c04241712019cb?sid=a4a439db-5cb0-4977-a25a-d7f94a42d6b8
