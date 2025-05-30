# Metis Ninjas Smart Contract Overview

This Solidity project powers the Metis Ninjas NFT collection, deployed on the Metis blockchain. The contract integrates royalty standards, access control, and DEX swapping for buybacks, and features dynamic pricing for public sales.

## Main Contract

### `MetisNinjas.sol`
- ERC721 NFT with ERC2981 royalties.
- Uses OpenZeppelin standards and roles for ownership/minter control.
- Mints a specified count on deployment to a preset wallet.
- Public minting via `purchase()` with tiered pricing (1.5–2.5 METIS).
- Includes `airdropNFT()` for admin airdrops.
- Handles revenue splits (65% treasury, 25% artist, 10% buyback).
- Swaps leftover METIS to `proToken` using NetSwap.

## Interfaces

### `INetswapRouter02.sol`
- Interface for NetSwap’s `swapExactMetisForTokens` used in token buyback logic.

## Scripts

### `scripts/deploy.ts`
- Handles deployment of the MetisNinjas contract.

### `test/index.ts`
- Tests for contract behavior and minting logic.

## Dependencies

From `package.json` and Solidity imports:
- `@openzeppelin/contracts`
- `hardhat`, `ethers`, `typescript`
- `ERC721`, `ERC2981`, `AccessControl`, `ReentrancyGuard`
- `SafeMath`, `Address`, `Strings`

---

# Metis Ninja NFT

Contracts Written in conjuction with NFT Apparel Team

Pricing has already been updated and reflected in the contract
1 - 2 Ninjas = 2.5 Metis each
3 - 5 Ninjas = 2 Metis each
6 - 10 Ninjas = 1.7 Metis each
10+ Ninjas = 1.5 Metis each

Distribution of sale funds are:
10% goes to buy back and hold PRO Token. (what is $PRO? Learn more) ** Done **
65% goes to the BlockChat Treasury ** Done **
25% goes to the creator of Metis Ninjas (Stellie) ** Done **
