require('dotenv').config();

const yargs = require('yargs');
const {spawn} = require('child_process');

const infuraKey = process.env["INFURA_KEY"];

async function onExit(childProcess) {
    return new Promise((resolve, reject) => {
        childProcess.once('exit', (code, signal) => {
            if (code === 0) {
                resolve(undefined);
            } else {
                reject(new Error('Exit with error code: ' + code));
            }
        });
        childProcess.once('error', (err) => {
            reject(err);
        });
    });
}

async function runGanache(network, blocktime) {
    var ganacheArgs = ['ganache-cli'];

    // Network option
    switch (network) {
        case 'bsc-local-testnet':
            ganacheArgs.push(...['-f', 'https://data-seed-prebsc-1-s1.binance.org:8545/', '--chainId', '97']);
            break;
        case 'bsc-local-mainnet':
            ganacheArgs.push(...['-f', 'https://bsc-dataseed.binance.org/', '--chainId', '56']);
            break;
        case 'eth-local-ropsten':
            ganacheArgs.push(
                ...['-f', 'https://ropsten.infura.io/v3/' + infuraKey, '--chainId', '3']
            );
            break;
        case 'eth-local-mainnet':
            ganacheArgs.push(
                ...['-f', 'https://mainnet.infura.io/v3/' + infuraKey, '--chainId', '1']
            );
            break;
        case 'optimistic-local-kovan':
            ganacheArgs.push(
                ...['-f', 'https://optimism-kovan.infura.io/v3/' + infuraKey, '--chainId', '69']
            );
            break;
        case 'optimistic-local-mainnet':
            ganacheArgs.push(
                ...['-f', 'https://optimism-mainnet.infura.io/v3/' + infuraKey, '--chainId', '10']
            );
            break;            
        default:
            throw new Error('Unsupported network: ' + network);
    }

    // Automatic block mining time
    if (blocktime) {
        ganacheArgs.push(...['--blockTime', `${blocktime}`]);
    }

    var ganache = spawn('ganache-cli', ganacheArgs, {stdio: [process.stdin, process.stdout, process.stderr]});
    return onExit(ganache);
}

async function main() {
    // Parse input arguments
    const argv = yargs
        .option('network', {
            alias: 'n',
            description: 'Network to fork',
            type: 'string',
        })
        .option('blocktime', {
            alias: 'b',
            description: 'Number of seconds for automatic block mining',
            type: 'number',
        })
        .help()
        .alias('help', 'h').argv;

    await runGanache(argv.network, argv.blocktime);
}

main();
