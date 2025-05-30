const hre = require("hardhat");

async function main() {
  const BondChain = await hre.ethers.getContractFactory("BondChain");
  const bondChain = await BondChain.deploy();

  await bondChain.deployed();
  console.log("BondChain deployed to:", bondChain.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
