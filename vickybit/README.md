# VickyBit (VBIT)

VickyBit is a SIP-010 compatible fungible token implemented in Clarity for the Stacks blockchain.

- Name: VickyBit
- Symbol: VBIT
- Decimals: 6
- Standard: SIP-010 Fungible Token

## Project structure

- `contracts/vickybit.clar` — SIP-010 token implementation
- `Clarinet.toml` — Clarinet project configuration
- `settings/*.toml` — Network settings
- `tests/` — Place for JS/TS tests with Clarinet

## Prerequisites

- Clarinet installed. Check with:

```bash
clarinet --version
```

If not installed, follow instructions: https://docs.hiro.so/clarinet

## Quick start

```bash
# From repo root
cd vickybit

# Syntax/type checks
clarinet check

# Open a REPL to interact locally
clarinet console
```

In the console, you can mint and transfer tokens, for example:

```clarity
# Mint 1,000.000000 VBIT to the deployer (replace with your principal as needed)
(contract-call? .vickybit mint u1000000000 tx-sender)

# Check total supply and balance
(contract-call? .vickybit get-total-supply)
(contract-call? .vickybit get-balance tx-sender)

# Transfer 100.000000 VBIT to another principal
(contract-call? .vickybit transfer u100000000 tx-sender 'SP3FBR2AGKXG86X1BEP03ZQJ2NV9E9ZQ3Z7DTN9A  none)
```

Notes:
- Only the contract owner (the deployer) can call `mint` and `set-owner`.
- Anyone can `burn` their own tokens; the owner can burn from any account.
- `transfer` allows the sender to move their own funds, or the owner to move on behalf of an account.

## SIP-010 interface implemented

- `get-name () -> (response (string-ascii 32) uint)`
- `get-symbol () -> (response (string-ascii 32) uint)`
- `get-decimals () -> (response uint uint)`
- `get-total-supply () -> (response uint uint)`
- `get-balance (principal) -> (response uint uint)`
- `transfer (uint principal principal (optional (buff 34))) -> (response bool uint)`

## Development

- Linting and testing are supported via the Clarinet JS tooling scaffolded by `clarinet new`.
- Add unit tests under `tests/` using Vitest. Example test harness is available in Clarinet docs.

## Deployment

Refer to the Stacks/Clarinet documentation for building, testing, and deploying contracts to Testnet/Mainnet using Clarinet and `stacks.js`/Stacks CLI.
