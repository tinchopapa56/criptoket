const hre = require("hardhat");

async function main() {

  const NFTMarketplace = await hre.ethers.getContractFactory("NFTMarketplace");
  const nftMarket = await NFTMarketplace.deploy();

  await nftMarket.deployed();

  console.log("NFTMarketplace deployed to:", nftMarket.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
