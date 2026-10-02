# Resolver CCIP

A Cairo contract for CCIP (Cross-Chain Interoperability Protocol) endpoint and token management on Starknet.

## Cairo Version

This project uses **Cairo 2.10.0**.

## Dependencies

- **OpenZeppelin Cairo Contracts v0.22.0**
- **Starknet Foundry v0.38.0**

## Setup

### Prerequisites

1. Install [Starknet Foundry](https://foundry-rs.github.io/starknet-foundry/)
2. Install [Cairo 2.10.0](https://docs.cairo-lang.org/)

```bash
# Install Starknet Foundry
curl -L https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh | sh

# Install Cairo 2.10.0
curl -L https://install.cairo-lang.org/install.sh | bash
```

### Build

```bash
scarb build
```

### Run Tests

```bash
scarb test
```

## Contract Features

- **Endpoint Management**: Register and deregister CCIP endpoints with URLs
- **Token Configuration**: Set gateway fee and gas limit multipliers for tokens
- **Contract Registry**: Track registered protocol contracts per endpoint
- **ETH Transfer**: Transfer ETH between Ethereum addresses
- **Access Control**: OpenZeppelin Ownable for permissioned operations

## Usage

### Deploy

```bash
# Deploy using sncast
sncast --url http://localhost:5050 deploy --class-hash <CLASS_HASH>
```

### Interact

```bash
# Register endpoint
sncast --url http://localhost:5050 --account my_account invoke \
  --contract-address <CONTRACT_ADDRESS> \
  --function register_endpoint \
  --arguments <ENDPOINT> <URL>

# Register token
sncast --url http://localhost:5050 --account my_account invoke \
  --contract-address <CONTRACT_ADDRESS> \
  --function register_token \
  --arguments <TOKEN_ADDRESS> <GATEWAY_FEE_MULTIPLIER> <GAS_LIMIT_MULTIPLIER>
```

## License

MIT
