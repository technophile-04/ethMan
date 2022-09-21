# 🧍‍♂️ EthMan

## ETH Man 🧍‍♂️ has started borning on Arbitrum mainnet 🎉 !

---

**ETH Man** reacts to **live** **ETH** price using Chainlink **oracles**! He is **happy** 🙂 when it's up 📈 and **sad** 🙁 when it's down 📉 than the previous value. (Dynamic face, colors on chain SVG NFT). 

### **100+ already minted 🫣 🫣!**

**Made with [scaffold-eth](https://github.com/scaffold-eth/scaffold-eth]) ❤️**

Mint it on: https://ethman-sb.surge.sh/

The price is only 0.001 AETH and everything goes to https://buidlguidl.com/ (web3 Builders community)

View the collection on Arbitrum Marketplace: https://stratosnft.io/collection/0x28E1679b0b5CAbd4F494278171cEDcB7134D5DF2

Verified Contract : https://arbiscan.io/address/0x28E1679b0b5CAbd4F494278171cEDcB7134D5DF2#code
(Also available and verified on https://sourcify.dev/ )

![Screenshot 2022-08-16 at 6 13 52 PM](https://user-images.githubusercontent.com/80153681/185744895-de73a431-1cb4-423f-94f9-5e4fbd2d2aa3.jpg)


## For Developers 👋
---

# 🏄‍♂️ Getting Started

Prerequisites: [Node (v16 LTS)](https://nodejs.org/en/download/) plus [Yarn](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

> clone/fork 🧍‍♂️ ETH Man:

```bash
git clone https://github.com/technophile-04/ethMan.git
```

> install:

```bash
cd ethMan
yarn install
```
## Introduction 
This repo shows you how to generate Dynamic SVG NFTs based on live [Chainlink's Data Feeds](https://docs.chain.link/docs/get-the-latest-price/).

Take a look at `ETHMan.sol` at `packages/hardhat/contracts`.
```solidity
AggregatorV3Interface public immutable i_priceFeed;
```
`i_priceFeed` holds the contract address of price feed from which it will be getting live price from. Checkout all the available price feeds [here](https://docs.chain.link/docs/ethereum-addresses/). 


```solidity 
  /* == states == */
  // updates with new price every time someone mints the token 
  uint256 private lastPrice = 0;
  // each Token ID has HUE associated with it, which decides the colors of different body parts of ETH Man 🧍‍♂️
  mapping(uint16 => uint16[7]) public tokenIdToHue;
  // holds the randomNumber for tokenId generated at mint
  mapping(uint16 => uint256) public tokenIdToRandomNumber;
  // Check if particular token ID is happy or not
  mapping(uint16 => bool) public isHappy;
```

`mintItem()` function : 
```solidity
(
  ,
  /*uint80 roundID*/
  int price,
  ,
  ,
  /* uint startedAt */
  /*uint timeStamp*/
  uint80 answeredInRound
) = i_priceFeed.latestRoundData();

if (uint256(price) > lastPrice) {
  isHappy[id] = true;
  lastPrice = uint256(price);
} else {
  // by defalut its false
  // isHappy[id] = false;
  lastPrice = uint256(price);
}

```
This gets the live price from data feeds. Learn more about the function `latestRoundData` [here](https://docs.chain.link/docs/price-feeds-api-reference/#latestrounddata) and updates `isHappy` mapping based on previous and current price

```solidity
uint16[7] memory HUES = [0, 60, 120, 180, 240, 300, 340];
```
This values represent the angles in the color wheel which represents a color check it out [here](https://www.researchgate.net/profile/Jack-Jiang-6/publication/259245149/figure/fig5/AS:541610991931392@1506141531460/A-Two-dimensional-hue-wheel-indicating-perceived-color-and-the-corresponding-hue-angle.png), This `HUES` array will be reordered randomly below...This reordered `HUES` array will decide the colors of ETH Man 🧍‍♂️.


```solidity 
// Calculating pseudoRandomNumber using price also to increase entropy
uint256 pseudoRandomNumber = uint256(
    keccak256(
        abi.encodePacked(
            msg.sender,
            address(this),
            block.chainid,
            id,
            block.timestamp,
            block.difficulty,
            price
        )
    )
);

// reorder the HUES randomly
for (uint256 i = 0; i < 7; i++) {
  uint256 randomIndex = i + ((pseudoRandomNumber + answeredInRound) % (7 - i));
  uint16 temp = HUES[randomIndex];
  HUES[randomIndex] = HUES[i];
  HUES[i] = temp;
}

// Assigning HUES and randomNumber for particular ID
tokenIdToHue[id] = HUES;
tokenIdToRandomNumber[id] = pseudoRandomNumber;
```

Other functions are self explanatory and a bit of maths, feel free to reach out if you face any difficulty 🙌 [Twitter](https://twitter.com/ShivBhonde)

## Using Mocks for local deployment
Taking a look at `constructor(address _priceFeed)` it need an address of `priceFeed` to get the latest `price`.To test out locally we have created `Mock` contract, checkout `/packages/hardhat/contracts/tests/MockV3.sol` which we will be deploying on local hardhat chain which will Mock the actual `AggregatorV3`(Price feed contract).

Look at `00_deploy_Mocks.js` in `packages/hardhat/deploy/` it deploys `MockV3` only when you are using your `chain` as `localhost`

Checkout out `01_deploy_ETHMan.js` in `packages/hardhat/deploy` it uses `MockV3` address as price feed if we are using local chain, If its not local chain then it uses the `AggregatorV3` contract address configured in `helper-hardhat-config.js` at `packages/hardhat`

Now when you run **`yarn deploy`** (make sure your local chain is running) this is will check your `defaultNetwork` in `hardhat.config.js` if its `localhost` then it will deploy `MockV3` and pass its address to `EthMan` contract and if its not `localhost` it will use address `AggregatorV3` configured in `helper-hardhat-config.js` at `packages/hardhat`

## Using scripts to mintNFTs and checking the generated NFTs

> in a new terminal window, (Make sure your local chain is running and have ran `yarn deploy` )

```bash
cd ethMan
yarn mintNFTs
```

This will mint 10 NFTs, checkout `mintNFTs.js` in `packages/hardhat/scripts` it increases the price every `even` mint to get `happy faces`

> To get the tokenURIs run of first 10 tokenIDs run : 

```bash
cd ethMan
yarn getTokenURIs
```
This will log the `tokenURIs` for first 10 `tokenIDs` you can copy the `tokenURI` and paste it in browser to check out `metadata` 😁

---
## Running Locally : 

> in a first terminal window, start your 👷‍ Hardhat chain:

```bash
cd ethMan
yarn chain
```


> in a second terminal window, start your 📱 frontend:

```bash
cd ethMan
yarn start
```

> in a third terminal window, 🛰 deploy your contract:

```bash
cd ethMan
yarn deploy
```

> You are ready to go 🚀

📱 Open http://localhost:3000 to see the app

## Contact

Feel free  to reach out if you have any doubts 🙌


[![Shiv Bhonde Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/ShivBhonde)
[![Shiv Bhonde Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://web.telegram.org/k/#@shiv_bhonde)
[![Shiv Bhonde Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/shiv-bhonde-b23a1a205/)
[![Shiv Bhonde Gmail](https://img.shields.io/badge/Gmail-gray?style=for-the-badge&logo=gmail)](mailto:shivbhonde04@gmail.com)
Discord : Shiv Bhonde#3592