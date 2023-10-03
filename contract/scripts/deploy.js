// scripts/deploy.js
const { ethers, upgrades } = require('hardhat');

async function main() {
    // deploy upgradeable contract
    const [deployer] = await ethers.getSigners();
    const gas = await ethers.provider.getGasPrice();
    console.log(
        'Deploy wallet balance:',
        ethers.utils.formatEther(await deployer.getBalance())
    );
    console.log('Deployer wallet public key:', deployer.address);

    const contractFactory = await ethers.getContractFactory('NFTUpgradeable');
    // const proxyContract = await upgrades.deployProxy(contractFactory,[],{
    //     gasPrice: gas, 
    //     initializer: "initialize",
    //     });

    const proxyContract = await upgrades.deployProxy(contractFactory);

    await proxyContract.deployed();

        // initialize
        // let txn = await proxyContract.initialize();
        // await txn.wait();

    console.log(`OpenZeppelin Proxy deployed to ${proxyContract.address}\n\n`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
