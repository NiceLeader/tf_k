# Digital Assets Standalone - Terraform

Modular Terraform configuration for deploying Digital Assets infrastructure on Kaleido Platform.

## Overview

This module deploys:

- **TokenizationStack** (AssetManager)
  - Asset Manager Runtime & Service
  - ERC20 Indexer Task
  - FireFly Event Listener
- **CustodyStack** (WalletManager)
  - Wallet Manager Runtime & Service
- **Wallet & Key** (in KeyManager)
  - HD Wallet
  - Signing Key

All services connect to existing KeyManager (FireFly Signer) for transaction signing.

## Quick Start

### 1. Configure Variables

```bash
# Copy example config
cp vars/example.tfvars vars/dev.tfvars

# Edit with your credentials and settings
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan -var-file="vars/dev.tfvars"
```

### 4. Deploy

```bash
terraform apply -var-file="vars/dev.tfvars"
```

### 5. View Outputs

```bash
terraform output

terraform output deployment_summary

terraform output signing_key_address
```

## Configuration Options

### Enable/Disable Components

```hcl
# Stacks
enable_tokenization_stack = true
enable_custody_stack      = true

# Wallet & Key
enable_wallet_creation    = true

# ERC20 Indexer
enable_erc20_indexer      = true
```

### Link Existing Token Contract (Documentation)

```hcl
# For documentation - ERC20 Indexer tracks ALL transfers automatically
existing_token_contract_address = "0x..."
```

### FireFly Integration

```hcl
firefly_namespace = "firefly-core"  # Your FireFly service name
```

## Module Structure

```
digital_assets_standalone/
├── main.tf              # Root module (calls ./module)
├── variables.tf         # Root variables
├── outputs.tf           # Root outputs
├── providers.tf         # Provider configuration
├── module/
│   ├── main.tf          # Resources (stacks, services)
│   ├── variables.tf     # Module variables
│   ├── outputs.tf       # Module outputs
│   └── providers.tf     # Provider requirements
└── vars/
    ├── example.tfvars   # Configuration template
    └── dev.tfvars       # DEV environment config
```

## Configuration Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `enable_tokenization_stack` | Deploy TokenizationStack with AssetManager | `true` |
| `enable_custody_stack` | Deploy CustodyStack with WalletManager | `true` |
| `enable_wallet_creation` | Create HD Wallet and signing key | `true` |
| `enable_erc20_indexer` | Enable ERC20 token tracking | `true` |
| `firefly_namespace` | FireFly namespace for event listening | `firefly` |
| `existing_token_contract_address` | Document existing ERC20 contract (Indexer tracks all) | `""` |

## Required Inputs

| Variable | Description |
|----------|-------------|
| `environment_id` | Kaleido environment ID (e.g., `e:abc123`) |
| `key_manager_service_id` | Existing KeyManager service ID |
| `evm_gateway_service_id` | Existing EVM Gateway runtime ID |

## Outputs

| Output | Description |
|--------|-------------|
| `signing_key_address` | Ethereum address of signing key |
| `tokenization_stack_id` | TokenizationStack ID |
| `custody_stack_id` | CustodyStack ID |
| `asset_manager_service_id` | AssetManager service ID |
| `wallet_manager_service_id` | WalletManager service ID |
| `deployment_summary` | Full deployment summary |

## Dependencies

This module requires existing infrastructure:
- KeyManager (FireFly Signer) - for key management
- EVM Gateway - for blockchain connectivity
- FireFly Core - for event listening (if ERC20 Indexer enabled)

## Cleanup

```bash
terraform destroy -var-file="vars/dev.tfvars"
```
