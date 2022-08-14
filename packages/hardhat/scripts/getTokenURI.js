const { ethers } = require("hardhat");

const numberOfTokens = 10;

async function main(numberOfNFTs) {
  const ethMan = await ethers.getContract("ETHMan");
  const res = [];
  //   eslint-disable-next-line no-plusplus
  for (let i = 0; i < numberOfNFTs; i++) {
    console.log(`Minting NFT with tokenId ${i + 1}`);
    const tokenId = (i + 1).toString();
    // eslint-disable-next-line no-await-in-loop
    const jsonBase64Encoded = await ethMan.tokenURI(tokenId);
    res.push(jsonBase64Encoded);
  }

  console.log(`Token URI's for first ${numberOfNFTs} tokens : `, res);
}

main(numberOfTokens)
  .then(() => process.exit(0))
  .catch((e) => {
    console.log(e);
    process.exit(1);
  });
