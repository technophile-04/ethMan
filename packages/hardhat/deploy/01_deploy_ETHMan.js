// deploy/00_deploy_your_contract.js

const { network } = require("hardhat");
const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  log("ChainID", chainId);

  let ethUsdPriceFeedAddress;
  let blockConfirmations;

  if (chainId === "31337") {
    const ethUsdAggregator = await get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
    blockConfirmations = 1;
  } else {
    ethUsdPriceFeedAddress = networkConfig[network.name].ethUsdPriceFeed;
    blockConfirmations = networkConfig[network.name].blockConfirmations;
  }

  log("----------------------------------------------------");
  log("Deploying ETHMan and waiting for confirmations...");

  const ethMan = await deploy("ETHMan", {
    from: deployer,
    args: [ethUsdPriceFeedAddress],
    log: true,
    waitConfirmations: blockConfirmations || 1,
  });

  log(`EThMan deployed at ${ethMan.address}`);
  try {
    if (!developmentChains.includes(network.name)) {
      log("Verifying on etherscan....");
      await run("verify:verify", {
        address: ethMan.address,
        contract: "contracts/ETHMan.sol:ETHMan",
        constructorArguments: [ethUsdPriceFeedAddress],
      });
      log(`Verified!! at address ${ethMan.address}`);
    }
  } catch (error) {
    console.error(error);
  }
};
module.exports.tags = ["all", "ETHMan"];
