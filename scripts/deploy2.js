const hre = require("hardhat")

async function main() {
    // const [deployer] = await hre.ethers.getSigners()
    // console.log("Deploying contracts with the account:", deployer.address)

    // const balance = await deployer.getBalance()
    // console.log("Account balance:", balance.toString())

    const NFTRaffleFactory =
        await hre.ethers.getContractFactory("NFTRaffleFactory")
    const nftRaffleFactory = await NFTRaffleFactory.deploy()

    console.log(`Deployed Contract to: ${nftRaffleFactory.target}`)
    // console.log("NFTRaffleFactory deployed to:", nftRaffleFactory.address)

    if (network.config.chainId === 11155420 && process.env.OPSCAN_APIKEY) {
        console.log("waiting for block conformations...")
        await nftRaffleFactory.deploymentTransaction().wait(6)
        await verify(nftRaffleFactory.target, [])
    }
}

async function verify(contractAddress, args) {
    console.log("Verifying Contract.....")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructor: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verfied")
        } else {
            console.log(e)
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
