const HDWalletProvider = require("truffle-hdwallet-provider-privkey");

const privKey = process.env.privateKey; // private key

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!

	networks: {
		development: {
			host: "127.0.0.1",
			port: 7545,
			network_id: "*" // Match any network id
		},
		rinkeby: {
			provider: new HDWalletProvider(privKey, 'https://rinkeby.infura.io/v3/8995b01133a04236bf97b129a1c9f019'),
			network_id: '*',
			gas: 4500000,
			gasPrice: 25000000000
		},
	}
};
