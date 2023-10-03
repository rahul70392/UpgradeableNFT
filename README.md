# erc721-upgradeable-with-ERC20-Deposit

## Getting Started

Install dependencies and run tests to make sure things are working.

    cd contract
    npm install
    npm test

    *NOTE - The tests are not currently according to the assignment, should be updated

### First setup configuration and fund your wallet

-   copy `.env.sample` to `.env`. Then view and edit `.env` for further instructions on configuring your RPC endpoints, private key and Etherscan API key.
-   for deploys to testnet, ensure your wallet account has some test currency to deploy.


### Deploy to Testnet

Scenario 1: First-time deploy of all 3 contracts (Proxy, Admin and your actual contract)

-   cd contract
-   deploy via `npx hardhat run --network testnet scripts/deploy.js`
-   once deployed, you'll see `Deployer wallet public key`. Head over to Etherscan (or Polygonscan) and view that account. You'll see 3 contracts recently deployed.
    1.  The first chronologically deployed contract is yours (example: https://mumbai.polygonscan.com/address/0xc858c56f9137aea2508474aa17658de460febb7d#code). Let's call this `CONTRACT_ADDRESS`.
    2.  The second contract is called "ProxyAdmin" (example: https://mumbai.polygonscan.com/address/0xec34f10619f7c0cf30d92d17993e10316a01c884#code).
    3.  The third is called "TransparentUpgradeableProxy" (example: https://mumbai.polygonscan.com/address/0xbf1774e5ba0fe942c7498b67ff93c509b723eb67#code) and this is the address that matches the `OpenZeppelin Proxy deployed to` in the output after running the deploy script. Let's call this `PROXY_ADDRESS`.
-   upload source code so others can verify it on-chain via `npx hardhat verify --network testnet CONTRACT_ADDRESS`. Head back to Etherscan or Polygonscan and view #1 again. You should now see actual source code in the contract.
-   `PROXY_ADDRESS` is that actual address used to interact with the contract, view on OpenSea, etc.
-   **IMPORTANT** You'll notice new files in `.openzeppelin` folder. It's important you keep these files and check them into the repository. They are required for upgrading the contract.

Scenario 2: Upgrade your contract

If you upgrade contract without making any changes, the system will continue to use currently deployed version.

-   cd contract
-   update `UPGRADEABLE_PROXY_ADDRESS` environment variables in `.env` and set to the `PROXY_ADDRESS` from above. This is always the Proxy contract address which doesn't change. Only the `CONTACT_ADDRESS` changes when upgrading.
-   upgrade via `npx hardhat run --network testnet scripts/deploy-upgrade.js`
-   find the newly deployed contract (`CONTRACT_ADDRESS`) from steps above. You'll find the newest contract recently deployed by the deployer wallet labeled as "Contract Creation".
-   upload source code so others can verify it on-chain via `npx hardhat verify --network testnet CONTRACT_ADDRESS`. Head back to Etherscan or Polygonscan and view #1 again. You should now see actual source code in the contract.
-   `PROXY_ADDRESS` is that actual address used to interact with the contract, view on OpenSea, etc.
-   **IMPORTANT** You'll notice changed files in `.openzeppelin` folder. It's important you keep these files and check them into the repository. They are required for upgrading the contract.



