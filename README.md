# FundMe Smart Contract

FundMe is a simple decentralized crowdfunding smart contract built with Solidity and Chainlink price feeds. It allows users to fund the contract with ETH, enforcing a minimum USD value per contribution, and enables the contract owner to withdraw the collected funds.

## Features

- **Minimum Funding Requirement:** Users must send at least $5 USD worth of ETH (using real-time Chainlink price feeds).
- **Multiple Funders:** Tracks all funders and their contributions.
- **Owner Withdrawal:** Only the contract owner can withdraw the total funds.
- **Gas-Efficient Reset:** Resets funders’ balances efficiently after withdrawal.
- **Fallback & Receive:** Accepts ETH sent directly to the contract.

## How It Works

1. **Funding:**  
   Users call `fund()` or send ETH directly. The contract checks if the sent ETH meets the minimum USD threshold using Chainlink price feeds.

2. **Tracking:**  
   Each funder’s address and amount are recorded in a mapping and an array.

3. **Withdrawal:**  
   Only the owner (deployer) can call `withdraw()`, which transfers all ETH to the owner and resets funders’ balances.

## Key Files

- [`src/FundMe.sol`](src/FundMe.sol) – Main contract logic.
- [`src/PriceConverter.sol`](src/PriceConverter.sol) – Library for ETH/USD conversion.
- [`test/FundMeTest.t.sol`](test/FundMeTest.t.sol) – Foundry tests.
- [`script/DeployFundMe.s.sol`](script/DeployFundMe.s.sol) – Deployment script.

## Usage

1. **Install dependencies:**

   ```sh
   forge install
   ```

2. **Test the contract:**

   ```sh
   forge test
   ```

3. **Deploy:**  
   Update the Chainlink price feed address for your network in the deployment script, then run:
   ```sh
   forge script script/DeployFundMe.s.sol --broadcast
   ```

## Security

- Only the owner can withdraw funds.
- Uses custom errors for gas efficiency.
- Validates minimum funding using live price data.

## License

MIT

---

**Note:** This project is for educational purposes. Always audit smart contracts before deploying to mainnet.
