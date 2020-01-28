const ItemManager = artifacts.require('./ItemManager.sol');

contract('ItemManager', accounts => {
	it('... should be able to add an Item', async function() {
		const ItemManagerInstance = await ItemManager.deployed();
		const itemName = 'test1';
		const itemPrice = 500;

		const result = await ItemManagerInstance.createItem(
			itemName,
			itemPrice,
			{
				from: accounts[0]
			}
		);
		console.log(result);
	});
});
