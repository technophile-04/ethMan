const networkConfig = {
  rinkeby: {
    ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
    blockConfirmations: 6,
  },
  polygon: {
    ethUsdPriceFeed: "0xF9680D99D6C9589e2a93a78A04A279e509205945",
    blockConfirmations: 6,
  },
  arbitrum: {
    ethUsdPriceFeed: "0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612",
    blockConfirmations: 2,
  },
};

const developmentChains = ["hardhat", "localhost"];

const DECIMALS = 8;
const INITAL_ANSWERE = 200000000000;

module.exports = { networkConfig, developmentChains, DECIMALS, INITAL_ANSWERE };
