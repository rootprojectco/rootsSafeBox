const RootsToken = artifacts.require("RootsToken");
const RootsSafeBox = artifacts.require("RootsSafeBox");

contract('RootsSafeBox test', async (accounts) => {

    let SAFE_BOX_FREEZE_IN_SECONDS = 5;

    let owner = accounts[0];
    let recipient = accounts[1];
    let tokenInstance;
    let safeBoxInstance;

    before(async () => {
        tokenInstance = await RootsToken.new.apply(this);

        let deployParams = [
            recipient,
            tokenInstance.address,
            Date.now()/1000 + SAFE_BOX_FREEZE_IN_SECONDS,
            owner
        ];
        safeBoxInstance = await RootsSafeBox.new.apply(this, deployParams);
    });

    it("should mint 10000 tokens to the first account", async () => {
        await tokenInstance.mint(owner, 10000);
        let balance = await tokenInstance.balanceOf(owner);

        assert.equal(balance.valueOf(), 10000);
    });

    it("should transfer 1000 tokens to the second account", async () => {
        await tokenInstance.transfer(recipient, 1000);
        let balanceOwner = await tokenInstance.balanceOf(owner);
        let balanceRecipient = await tokenInstance.balanceOf(recipient);

        assert.equal(balanceOwner.valueOf(), 9000);
        assert.equal(balanceRecipient.valueOf(), 1000);
    });

    it("should send 1000 tokens to the safe box account", async () => {
        await tokenInstance.transfer(safeBoxInstance.address, 1000);
        let balanceOwner = await tokenInstance.balanceOf(owner);
        let balanceSafeBox = await tokenInstance.balanceOf(safeBoxInstance.address);

        assert.equal(balanceOwner.valueOf(), 8000);
        assert.equal(balanceSafeBox.valueOf(), 1000);
    });

    it("should not withdraw now", async () => {
        let error;

        try {
            await safeBoxInstance.withdrawToken(tokenInstance.address);
        } catch (e) {
            error = e;
        }

        let balanceRecipient = await tokenInstance.balanceOf(recipient);

        assert.isDefined(error);
        assert.equal(balanceRecipient.valueOf(), 1000);
    });

    it("should withdraw after " + SAFE_BOX_FREEZE_IN_SECONDS*1000 + "ms", async () => {
        await new Promise(resolve => setTimeout(resolve, SAFE_BOX_FREEZE_IN_SECONDS*1000));

        let error;

        try {
            await safeBoxInstance.withdrawToken(tokenInstance.address);
        } catch (e) {
            error = e;
        }

        let balanceRecipient = await tokenInstance.balanceOf(recipient);

        assert.isUndefined(error);
        assert.equal(balanceRecipient.valueOf(), 2000);
    });
});