# FundMe (Foundry) — README

✅ This repository is a Foundry-based learning project implementing a simple FundMe dApp using Chainlink price feeds, test coverage (unit + integration) and convenience scripts for deploying and interacting with the contracts.

This project is based on Patrick Collins' FundMe tutorial but adapted to Foundry with small helpers, mocks and tests to demonstrate how to:

- Read Chainlink price feeds from Solidity via a library (PriceConverter)
- Accept ETH donations only if they meet a USD minimum (using conversion rate)
- Allow the owner to withdraw the accumulated funds safely

---

## Project layout

- `src/` — smart contracts
	- `FundMe.sol` — main funding contract (owner, fund, withdraw, cheaperWithdraw)
	- `PriceConverter.sol` — library to convert ETH amounts to USD using an AggregatorV3Interface
- `script/` — Foundry scripts
	- `DeployFundMe.s.sol` — deploy FundMe (uses `HelperConfig` to pick chain-dependent price feed)
	- `HelperConfig.s.sol` — network / chain config (local/anvil mock + Sepolia and ZkSync Sepolia price feed addresses)
	- `Interactions.s.sol` — helper scripts to fund and withdraw `FundMe`
- `test/` — tests
	- `unit/` — unit tests that run locally and in CI (`FundMe.t.sol`, `ZkSyncDevOps.t.sol`, ...)
	- `integration/` — integration-like tests that run as higher-level interactions (`InteractionsTest.t.sol`)
	- `mock/` — `MockV3Aggregator.sol` (Chainlink price feed mock used for local tests)
- `lib/` — external dependencies (foundry std, chainlink examples, foundry-devops helpers)

---

## How it works — quick summary

- The `FundMe` contract requires that an incoming fund (msg.value) meets a minimum USD threshold. It uses `PriceConverter` which calls a Chainlink `AggregatorV3Interface` to read ETH/USD price and compute the USD equivalent.
- When funding, the contract tracks each funder's contribution and stores funders in an array; only the owner can call `withdraw` or `cheaperWithdraw` to collect the contract balance.
- `HelperConfig` provides chain-specific configuration. For local testing with Anvil/Foundry, `getOrCreateAnvilEthConfig()` deploys a `MockV3Aggregator` and returns its address as the price feed.

---

## Tests in this repository

The repository includes both unit and integration-style tests built with Forge (Foundry):

- Unit tests (path: `test/unit/FundMe.t.sol`):
	- Verifies that the price feed is set correctly for deployed contracts
	- Ensures `fund()` reverts if insufficient ETH is sent
	- Confirms `fund()` updates the internal mapping and funders array
	- Tests `withdraw()` access control (only owner allowed)
	- Tests `withdraw()` for single and multiple funders (balance checks)

- Integration tests (path: `test/integration/InteractionsTest.t.sol`):
	- Simulates a user funding the contract and the owner withdrawing via the `WithdrawFundMe` script
	- Useful for higher-level integration checks using the real script flows

- Mock: `test/mock/MockV3Aggregator.sol`
	- Light-weight Chainlink aggregator mock to provide deterministic price feeds for local tests and scripts

Notes:
- Many test files use `ZkSyncChainChecker` / `skipZkSync` modifiers (from `foundry-devops`) to conditionally skip tests on ZkSync networks — this keeps tests robust when run on different chains.

---

## Getting started / prerequisites

You should have Foundry installed (forge, cast, anvil). See https://book.getfoundry.sh/ for installation instructions.

Suggested quick setup:

```bash
# build the project
forge build

# run all tests (unit + integration)
forge test

# run only unit tests
forge test --match-path test/unit

# run only integration tests
forge test --match-path test/integration
```

Local development flow using Anvil (recommended for iterating quickly):

```bash
# start a local chain (in another terminal)
anvil

# deploy to the anvil chain
forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url http://127.0.0.1:8545 --private-key <private_key> --broadcast

# fund the deployed contract
forge script script/Interactions.s.sol:FundFundMe --rpc-url http://127.0.0.1:8545 --private-key <private_key> --broadcast

# withdraw as owner
forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url http://127.0.0.1:8545 --private-key <private_key> --broadcast
```

If you use `DeployFundMe` on an Anvil (local) chain, `HelperConfig.getOrCreateAnvilEthConfig()` deploys a `MockV3Aggregator` for ETH/USD so tests and scripts have a deterministic price feed.

---

## Useful commands / scripting tips

- Run a single test file:
	- `forge test --match-path test/unit/FundMe.t.sol`
- Show contract size and artifacts (for auditing):
	- `forge inspect FundMe size`
- Formatting: `forge fmt`

---

## Contributing / learning notes

This repository is intended as a learning resource. If you want to expand it:

- Add richer integration tests covering forks (mainnet or Sepolia) using a `--fork-url`
- Add event emission / logging to `FundMe` and assert events in tests
- Add v2 features (e.g., minimum funding per address, per-block rate limits, reimbursements)

---

If you'd like, I can also:

- Add a brief developer README section that includes a step-by-step local developer workflow (Anvil + quick-run commands)
- Add CI configuration (GitHub Actions) to run `forge test` on pushes and PRs

Happy to expand or tailor this README for docs, demos or a beginner walkthrough — tell me what you want next! 👋
