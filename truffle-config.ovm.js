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
 
 const localMnemonic = process.env["OPTIMISM_LOCAL_MNEMONIC"];
 const kovanMnemonic = process.env["OPTIMISM_KOVAN_MNEMONIC"];
 const mainnetMnemonic = process.env["OPTIMISM_MAINNET_MNEMONIC"];

 const infuraKey = process.env["INFURA_KEY"];

module.exports = {
    contracts_build_directory: './build_optimistic',
    contracts_directory: './contracts/optimistic',

    networks: {
        'optimistic-local-node': {
            network_id: 420,
            gas: 200000000,
            gasPrice: 15000000,
            provider: function () {
                return new HDWalletProvider({
                    mnemonic: {
                        phrase: localMnemonic,
                    },
                    providerOrUrl: 'http://127.0.0.1:8545/',
                    addressIndex: 0,
                    numberOfAddresses: 1,
                    chainId: 420,
                });
            },
        },
        'optimistic-local-kovan': {
            host: '127.0.0.1',
            port: 8545,
            network_id: 69,
            skipDryRun: true,
        },
        'optimistic-kovan': {
            network_id: 69,
            chain_id: 69,
            gas: 11000000,
            gasPrice: 15000000,
            provider: function () {
                return new HDWalletProvider(kovanMnemonic, 'https://optimism-kovan.infura.io/v3/' + infuraKey, 0, 1);
            },
        },
        'optimistic-local-mainnet': {
            host: '127.0.0.1',
            port: 8545,
            network_id: 10,
            skipDryRun: true,
        },
        'optimistic-mainnet': {
            network_id: 10,
            chain_id: 10,
            provider: function () {
                return new HDWalletProvider(
                    mainnetMnemonic,
                    'https://optimism-mainnet.infura.io/v3/' + infuraKey,
                    0,
                    1
                );
            },
        },
    },

    mocha: {
        timeout: 100000,
    },
    compilers: {
        solc: {
            version: 'node_modules/@eth-optimism/solc',
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 800,
                },
            },
        },
    },
    db: {
        enabled: false,
    },
};
