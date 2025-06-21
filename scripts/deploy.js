const hre = require("hardhat");

async function main() {
  const FractionalNFT = await hre.ethers.getContractFactory("FractionalNFT");
  const fractionalNFT = await FractionalNFT.deploy();

  await fractionalNFT.deployed();

  console.log("FractionalNFT deployed to:", fractionalNFT.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
