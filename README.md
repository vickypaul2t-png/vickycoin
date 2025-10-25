# VickyCoin

A simple fungible token (SIP-010–like) implemented in Clarity and set up for Clarinet.

## Project structure

- `Clarinet.toml` — Clarinet project configuration
- `contracts/vickycoin.clar` — VickyCoin smart contract

## Requirements

- Clarinet: https://docs.hiro.so/clarity/clarinet

## Quick start

- Check the project:
  - `clarinet check`
- Open a REPL to interact locally:
  - `clarinet console`

## Contract interface

Read-only functions:
- `(get-name) -> (ok "VickyCoin")`
- `(get-symbol) -> (ok "VICKY")`
- `(get-decimals) -> (ok u6)`
- `(get-total-supply) -> (ok uint)`
- `(get-balance principal) -> (ok uint)`
- `(get-token-uri) -> (ok none)`

Public functions:
- `(transfer amount sender recipient (optional (buff 34))) -> (ok true) | (err code)`
- `(mint amount recipient) -> (ok true) | (err code)` — only contract owner
- `(burn amount sender) -> (ok true) | (err code)` — sender burns own tokens
- `(set-owner principal) -> (ok true) | (err code)` — only current owner

Error codes:
- `u100` — unauthorized
- `u101` — insufficient balance
- `u102` — zero-amount not allowed

## Examples (Clarinet console)

- Mint (as deployer/owner):
  - `(contract-call? .vickycoin mint u100000 'SPXXXXXXXXXXXXXXX...)`
- Check balance:
  - `(contract-call? .vickycoin get-balance 'SPXXXXXXXXXXXXXXX...)`
- Transfer (sender must be `tx-sender`):
  - `::set_tx_sender SPYYYYYYYYYYYYYYYY...`
  - `(contract-call? .vickycoin transfer u500 'SPYYYYYYYYYYYYYYYY... 'SPZZZZZZZZZZZZZZZZ... none)`

Replace the example addresses with real ones from your Clarinet console (e.g., `deployer`, `wallet_1`, etc.).
