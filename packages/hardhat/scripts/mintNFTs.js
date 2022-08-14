const { ethers } = require("hardhat");

const numberOfTokensToMint = 10;
const ethValue = ethers.utils.parseEther("0.001");

async function main(numberOfNFTs) {
  const ethMan = await ethers.getContract("ETHMan");

  // eslint-disable-next-line no-plusplus
  for (let i = 0; i < numberOfNFTs; i++) {
    console.log(`Getting token URI for tokenID ${i + 1}`);
    // eslint-disable-next-line no-await-in-loop
    const txnRes = await ethMan.mintItem({ value: ethValue });
    // eslint-disable-next-line no-await-in-loop
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
