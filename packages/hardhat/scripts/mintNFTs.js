/* eslint-disable no-await-in-loop */
const { ethers } = require("hardhat");
const { INITAL_ANSWERE } = require("../helper-hardhat-config");

const numberOfTokensToMint = 10;

const ethValue = ethers.utils.parseEther("0.001");
async function main(numberOfNFTs) {
  const ethMan = await ethers.getContract("ETHMan");
  const ethUsdAggregator = await ethers.getContract("MockV3Aggregator");
  let currentPrice = INITAL_ANSWERE;

  // eslint-disable-next-line no-plusplus
  for (let i = 0; i < numberOfNFTs; i++) {
    console.log(`Minting NFT with tokenId ${i + 1}`);

    if (i % 2 === 0) {
      currentPrice += INITAL_ANSWERE;
      const increasedPriceTx = await ethUsdAggregator.updateAnswer(
        currentPrice
      );
      await increasedPriceTx.wait(1);
    } else {
      currentPrice -= INITAL_ANSWERE;
      const decreasedPriceTx = await ethUsdAggregator.updateAnswer(
        currentPrice
      );
      await decreasedPriceTx.wait(1);
    }

    const txnRes = await ethMan.mintItem({ value: ethValue });
    await txnRes.wait(1);
    console.log(`Token with tokenId ${i + 1} minted`);
  }
}

main(numberOfTokensToMint)
  .then(() => process.exit(0))
  .catch((e) => {
    console.log(e);
    process.exit(1);
  });
