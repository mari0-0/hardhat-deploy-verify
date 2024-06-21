const { ethers, run, network } = require("hardhat");

async function main() {
    const NFTRaffleFactory = await ethers.getContractFactory("NFTRaffle");
    console.log("Deploying contract...");
    const entryCost = ethers.parseEther("0.01"); // 0.01 ETH
    const NFTRaffle = await NFTRaffleFactory.deploy(entryCost, "0xE2A21305c422eA7989799ce5d59341909658f171", BigInt(6));
    
    console.log(`Deployed Contract to: ${NFTRaffle.target}`);

    if (network.config.chainId === 11155420 && process.env.OPSCAN_APIKEY) {
        console.log("Waiting for block confirmations...");
        await NFTRaffle.deploymentTransaction().wait(2);
        await verify(NFTRaffle.target, [entryCost, "0xE2A21305c422eA7989799ce5d59341909658f171", BigInt(6)]);
    }
}

async function verify(contractAddress, args) {
    console.log("Verifying Contract...");
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        });
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified");
        } else {
            console.log(e);
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
        console.error(err);
        process.exit(1);
    });
