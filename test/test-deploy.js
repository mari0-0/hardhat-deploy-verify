const { ethers, run, network } = require("hardhat")
const { expect, assert } = require("chai")
describe("SimpleStorage", () => {
    let simpleStorgeFactory, simpleStorge
    beforeEach(async () => {
        simpleStorgeFactory = await ethers.getContractFactory("SimpleStorage")
        simpleStorge = await simpleStorgeFactory.deploy()
    })

    it("Should start with a fav number of 0", async function () {
        const currentValue = await simpleStorge.retrieve()
        const expectedValue = "0"
        assert.equal(currentValue.toString(), expectedValue)
    })
    it("Should update when we call store", async function () {
        const expectedValue = "7"
        const transactionResponse = await simpleStorge.store(expectedValue)
        await transactionResponse.wait(1)
        const currentValue = await simpleStorge.retrieve()
        assert.equal(currentValue.toString(), expectedValue)
    })
})
