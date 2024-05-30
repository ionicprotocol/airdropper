import hre from "hardhat";

async function main() {
  const airdrop = await hre.viem.deployContract("Airdropper", [
    "0x18470019bf0e94611f15852f7e93cf5d65bc34ca", // ion token
  ]);
  console.log("airdrop.address: ", airdrop.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
