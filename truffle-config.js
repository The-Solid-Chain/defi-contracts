/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

/**
 * Create a file at the root of your project and name it .env -- there you can set process variables
 * like the mnemomic below. Note: .env is ignored by git in this project to keep your private information safe
 */
require('dotenv').config();

const HDWalletProvider = require('@truffle/hdwallet-provider');

const binanceMnemonic = process.env["BINANCE_MNEMONIC"];
const ropstenMnemonic = process.env["ETHEREUM_ROPSTEN_MNEMONIC"];

const infuraKey = process.env["INFURA_KEY"];

module.exports = {
    contracts_directory: './contracts/ethereum',
    contracts_build_directory: './build/',

    /**
     * Networks define how you connect to your ethereum client and let you set the
     * defaults web3 uses to send transactions. If you don't specify one truffle
     * will spin up a development blockchain for you on port 9545 when you
     * run `develop` or `test`. You can ask a truffle command to use a specific
     * network from the command line, e.g
     *
     * $ truffle test --network <network-name>
     */

    networks: {
        // Useful for testing. The `development` name is special - truffle uses it by default
        // if it's defined here and no other network is specified at the command line.
        // You should run a client (like ganache-cli, geth or parity) in a separate terminal
        // tab if you use this network and you must also set the `host`, `port` and `network_id`
        // options below to some value.
        //
        dev: {
            host: '127.0.0.1',
            port: 8545,
            network_id: '*',
        },
        'bsc-local-testnet': {
            host: '127.0.0.1',
            port: 8545,
            network_id: '97',
        },
        'bsc-local-mainnet': {
            host: '127.0.0.1',
            port: 8545,
            network_id: '56',
        },
        'bsc-testnet': {
            provider: () => new HDWalletProvider(binanceMnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`),
            network_id: 97,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true,
        },
        'bsc-mainnet': {
            provider: () => new HDWalletProvider(binanceMnemonic, `https://bsc-dataseed.binance.org/`),
            network_id: 56,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true,
        },
        'eth-local-ropsten': {
            host: '127.0.0.1',
            port: 8545,
            network_id: 3,
            skipDryRun: true,
        },
        'eth-ropsten': {
            provider: () =>
                new HDWalletProvider(ropstenMnemonic, `https://ropsten.infura.io/v3/${infuraKey}`),
            network_id: 3,
            gas: 5500000,
            gasPrice: 15000000000,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true,
        },
        'eth-local-mainnet': {
            host: '127.0.0.1',
            port: 8545,
            network_id: 1,
            skipDryRun: true,
        },
        'eth-mainnet': {
            provider: () =>
                new HDWalletProvider(ropstenMnemonic, `https://mainnet.infura.io/v3/${infuraKey}`),
            network_id: 3,
            gas: 5500000,
            gasPrice: 15000000000,
            confirmations: 2,
            timeoutBlocks: 200,
        },
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: '0.8.6', // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            // settings: {          // See the solidity docs for advice about optimization and evmVersion
            //  optimizer: {
            //    enabled: false,
            //    runs: 200
            //  },
            //  evmVersion: "byzantium"
            // }
        },
    },

    // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
    //
    // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
    // those previously migrated contracts available in the .db directory, you will need to run the following:
    // $ truffle migrate --reset --compile-all

    db: {
        enabled: false,
    },

    plugins: ['truffle-contract-size'],
};
