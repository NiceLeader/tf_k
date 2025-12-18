# Kaleido Blockchain Infrastructure - Terraform

Professional modular Terraform configuration for deploying blockchain infrastructure with Hyperledger Firefly middleware on Kaleido Platform.

## Overview

This repository contains Terraform scripts to deploy:

- **Blockchain Network** (Hyperledger Besu/GoQuorum)
  - Validator nodes
  - Archive nodes
  - EVM Gateway
  - Block Indexer
- **Hyperledger Firefly Middleware** (Optional)
  - Firefly Core
  - Transaction Manager
  - Private Data Manager
  - Key Manager
  - Contract Manager
  - Subscriptions
  - Event Listeners

All services are deployed in a single, managed stack for easy configuration and maintenance.

## Quick Start - Unified Deployment (Blockchain + Firefly)

The `vars/dev.tfvars` file contains a **unified configuration** that deploys both blockchain and Firefly middleware together.

### 1. Review Configuration

```bash
# The dev.tfvars already includes both blockchain and Firefly settings
cat vars/dev.tfvars
```

**Firefly is enabled by default** with all services configured:

- Firefly Core
- Transaction Manager
- Private Data Manager
- Key Manager
- Contract Manager
- Subscriptions
- Event Listeners

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

terraform output firefly_deployment_summary

terraform output firefly_all_service_ids
```

## Customizing Firefly Configuration

### Disable Firefly (Deploy Blockchain Only)

Edit `vars/dev.tfvars` and set:

```hcl
enable_firefly = false
```

Then apply:

```bash
terraform apply -var-file="vars/dev.tfvars"
```

### Enable/Disable Individual Services

In `vars/dev.tfvars`, toggle individual services:

```hcl
enable_firefly = true

# Individual service controls
enable_firefly_core         = true
enable_transaction_manager  = true
enable_private_data_manager = false  # Disable this service
enable_key_manager          = true
enable_contract_manager     = false  # Disable this service
enable_subscriptions        = true
enable_event_listeners      = true
```

### Alternative: Use Separate Configuration Files

If you want separate configs for blockchain-only and full stack:

```bash
# For blockchain only - use example.tfvars as base
cp vars/example.tfvars vars/blockchain-only.tfvars

# For full stack - use dev.tfvars (already configured)
terraform apply -var-file="vars/dev.tfvars"
```

### Firefly Configuration Options

#### All Services Enabled (Default)

All Firefly components are enabled by default in `vars/firefly.tfvars`.

#### Minimal Configuration

To deploy only core services:

```hcl
enable_firefly              = true
enable_firefly_core         = true
enable_transaction_manager  = true
enable_key_manager          = true
enable_contract_manager     = false
enable_subscriptions        = false
enable_event_listeners      = false
enable_private_data_manager = false
```

#### Custom Service Configuration

You can customize each service with additional configuration:

```hcl
transaction_manager_config = {
  maxInFlight    = 100
  gasOracleMode  = "connector"
}

event_listeners_config = {
  fromBlock        = "latest"
  blocksToFinality = 50
}
```

### View Firefly Deployment

```bash
# View all outputs
terraform output

# View Firefly-specific outputs
terraform output firefly_deployment_summary
terraform output firefly_all_service_ids

# View specific service IDs
terraform output firefly_core_service_id
terraform output firefly_transaction_manager_service_id
```

## Configuration Reference

### Firefly Services

| Service              | Variable                      | Description                     | Default |
| -------------------- | ----------------------------- | ------------------------------- | ------- |
| Firefly Core         | `enable_firefly_core`         | Main orchestration engine       | `true`  |
| Transaction Manager  | `enable_transaction_manager`  | Manages blockchain transactions | `true`  |
| Private Data Manager | `enable_private_data_manager` | Manages private data exchange   | `true`  |
| Key Manager          | `enable_key_manager`          | Cryptographic key management    | `true`  |
| Contract Manager     | `enable_contract_manager`     | Smart contract deployment       | `true`  |
| Subscriptions        | `enable_subscriptions`        | Event subscriptions & webhooks  | `true`  |
| Event Listeners      | `enable_event_listeners`      | Blockchain event monitoring     | `true`  |

### Database Options

```hcl
firefly_database_type = "postgres"  # or "sqlite"
firefly_enable_ipfs   = true        # Enable IPFS for shared storage
```

### Key Manager Types

```hcl
key_manager_type = "FireFlySigner"  # or "HDWalletSigner"
```

## Module Structure

```
.
├── main.tf                    # Root module
├── variables.tf               # Root variables
├── outputs.tf                 # Root outputs
├── provider.tf                # Provider configuration
├── terraform.tfvars           # Current configuration
├── modules/
│   ├── chain/                 # Blockchain network module
│   │   ├── main.tf
│   │   ├── nodes.tf
│   │   ├── services.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── firefly/               # Hyperledger Firefly module
│       ├── main.tf            # Firefly services
│       ├── variables.tf       # Firefly variables
│       └── outputs.tf         # Firefly outputs
└── vars/
    ├── example.tfvars         # Blockchain example
    └── firefly.tfvars         # Firefly example
```

## Connecting to Existing Network (Story 11513537)

The Firefly module automatically connects to your existing blockchain network:

```hcl
# In main.tf, the connection is established via:
module "firefly_middleware" {
  network_id             = module.blockchain_chain.blockchain_network_id
  evm_gateway_service_id = module.blockchain_chain.evm_gateway_service_id
}
```

The middleware will use:

- Existing EVM Gateway for blockchain interactions
- Existing Block Indexer for event querying
- Network configuration from Story 11513537

## Best Practices

1. **Always use var-files**: Keep credentials separate from code
2. **Enable all services initially**: Disable only after understanding dependencies
3. **Use PostgreSQL for production**: SQLite is for development only
4. **Enable IPFS**: Required for private data exchange
5. **Tag resources**: Use tags for cost tracking and organization
6. **Review plans**: Always review `terraform plan` before applying

## Troubleshooting

### Firefly Services Not Starting

Check dependencies:

```bash
terraform output evm_gateway_service_id
terraform output blockchain_network_id
```

Ensure the blockchain network is fully deployed before enabling Firefly.

### Configuration Errors

Validate your Terraform configuration:

```bash
terraform validate
terraform fmt -check
```

### Service Dependencies

Services have the following dependencies:

- Firefly Core → EVM Gateway
- Transaction Manager → Firefly Core + EVM Gateway
- Contract Manager → Transaction Manager + Firefly Core
- Event Listeners → Subscriptions + Firefly Core
- Private Data Manager → Firefly Core

## Cleanup

To destroy the Firefly stack only:

```bash
# Set enable_firefly = false in your tfvars
terraform apply -var-file="vars/your-config.tfvars"
```

To destroy everything:

```bash
# Enable force deletion first
terraform apply -var="force_delete_nodes=true" -var-file="vars/your-config.tfvars"

# Then destroy
terraform destroy -var-file="vars/your-config.tfvars"
```

## Support

For issues or questions:

1. Check the Kaleido documentation
2. Review Terraform logs: `terraform show`
3. Validate configuration: `terraform validate`
