const { network } = require("hardhat");
const {
  developmentChains,
  DECIMALS,
  INITAL_ANSWERE,
} = require("../helper-hardhat-config");

module.exports = async (hre) => {
  const { getNamedAccounts, deployments } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainName = network.name;

  if (developmentChains.includes(chainName)) {
    log("Local network detected!, Deploying mocks...");
    await deploy("MockV3Aggregator", {
      from: deployer,
      log: true,
      args: [DECIMALS, INITAL_ANSWERE],
    });

    log("Mock Deployed !");
    log("------------------------------------------------ ");
  }
};

module.exports.tags = ["all", "mocks"];
