# Kaleido Platform API Credentials
variable "kaleido_platform_api" {
  description = "Kaleido Platform API endpoint"
  type        = string
  default     = "https://api.kaleido.io/api/v1"
}

variable "kaleido_platform_username" {
  description = "Kaleido Platform username (email)"
  type        = string
  sensitive   = true
}

variable "kaleido_platform_password" {
  description = "Kaleido Platform password or API key"
  type        = string
  sensitive   = true
}

# Environment Configuration
variable "environment_id" {
  description = "Existing Kaleido environment ID to use"
  type        = string
  default     = ""
}

variable "environment_name" {
  description = "Environment name for reference"
  type        = string
  default     = ""
}

# Network Configuration
variable "network_name" {
  description = "Name for the blockchain network"
  type        = string
  default     = "dev-blockchain-network"
}

variable "network_type" {
  description = "Type of blockchain network (BesuNetwork, GoQuorumNetwork, etc.)"
  type        = string
  default     = "BesuNetwork"
}

variable "consensus_algorithm" {
  description = "Consensus algorithm for the blockchain (qbft, ibft2, raft)"
  type        = string
  default     = "qbft"

  validation {
    condition     = contains(["qbft", "ibft2", "raft"], var.consensus_algorithm)
    error_message = "Consensus algorithm must be one of: qbft, ibft2, raft"
  }
}

variable "block_period_seconds" {
  description = "Block production interval in seconds"
  type        = number
  default     = 4
}

# Node Configuration
variable "validator_node_count" {
  description = "Number of validator nodes to create"
  type        = number
  default     = 4

  validation {
    condition     = var.validator_node_count >= 1
    error_message = "At least 1 validator node is required"
  }
}

variable "archive_node_count" {
  description = "Number of archive nodes to create"
  type        = number
  default     = 1

  validation {
    condition     = var.archive_node_count >= 0
    error_message = "Archive node count must be non-negative"
  }
}

variable "load_test_node_count" {
  description = "Number of temporary non-validator nodes for load testing"
  type        = number
  default     = 2

  validation {
    condition     = var.load_test_node_count >= 0
    error_message = "Load test node count must be non-negative"
  }
}

variable "validator_node_size" {
  description = "Size/tier for validator nodes"
  type        = string
  default     = "small"
}

variable "archive_node_size" {
  description = "Size/tier for archive nodes"
  type        = string
  default     = "medium"
}

variable "load_test_node_size" {
  description = "Size/tier for load test nodes"
  type        = string
  default     = "small"
}

# Stack Configuration
variable "chain_infrastructure_stack_name" {
  description = "Name for the chain infrastructure stack"
  type        = string
  default     = "chain-infra-stack"
}

# Service Configuration
variable "enable_block_indexer" {
  description = "Enable Block Indexer service"
  type        = bool
  default     = true
}

variable "enable_evm_gateway" {
  description = "Enable EVM Gateway service"
  type        = bool
  default     = true
}

variable "block_indexer_name" {
  description = "Name for the Block Indexer service"
  type        = string
  default     = "block-indexer"
}

variable "evm_gateway_name" {
  description = "Name for the EVM Gateway service"
  type        = string
  default     = "evm-gateway"
}

# Tags and Metadata
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "development"
    ManagedBy   = "terraform"
    Project     = "blockchain-deployment"
  }
}

# Additional Configuration
variable "node_name_prefix" {
  description = "Prefix for node names"
  type        = string
  default     = "node"
}

variable "force_delete_nodes" {
  description = "Force delete nodes when destroying (set to true before terraform destroy)"
  type        = bool
  default     = false
}


# Hyperledger Firefly Configuration


variable "enable_firefly" {
  description = "Enable Hyperledger Firefly middleware deployment"
  type        = bool
  default     = false
}

variable "firefly_stack_name" {
  description = "Name for the Firefly middleware stack"
  type        = string
  default     = "firefly-middleware-stack"
}

# Firefly Core
variable "enable_firefly_core" {
  description = "Enable Hyperledger Firefly core service"
  type        = bool
  default     = true
}

variable "firefly_core_name" {
  description = "Name for Firefly core service"
  type        = string
  default     = "firefly-core"
}

# Transaction Manager
variable "enable_transaction_manager" {
  description = "Enable Firefly transaction manager"
  type        = bool
  default     = true
}

variable "transaction_manager_name" {
  description = "Name for transaction manager service"
  type        = string
  default     = "firefly-txmanager"
}

variable "transaction_manager_confirmations" {
  description = "Number of block confirmations required for transactions"
  type        = number
  default     = 0
}

variable "transaction_manager_config" {
  description = "Custom configuration for transaction manager"
  type        = map(any)
  default     = {}
}

# Private Data Manager
variable "enable_private_data_manager" {
  description = "Enable Firefly private data manager"
  type        = bool
  default     = true
}

variable "private_data_manager_name" {
  description = "Name for private data manager service"
  type        = string
  default     = "firefly-dataexchange"
}

variable "private_data_manager_config" {
  description = "Custom configuration for private data manager"
  type        = map(any)
  default     = {}
}

# Key Manager
variable "enable_key_manager" {
  description = "Enable Firefly key manager"
  type        = bool
  default     = true
}

variable "key_manager_name" {
  description = "Name for key manager service"
  type        = string
  default     = "firefly-signer"
}

variable "key_manager_type" {
  description = "Type of key manager (FireFlySigner, HDWalletSigner)"
  type        = string
  default     = "FireFlySigner"
}

variable "key_manager_config" {
  description = "Custom configuration for key manager"
  type        = map(any)
  default     = {}
}

# Contract Manager
variable "enable_contract_manager" {
  description = "Enable Firefly contract manager"
  type        = bool
  default     = true
}

variable "contract_manager_name" {
  description = "Name for contract manager service"
  type        = string
  default     = "firefly-contracts"
}

variable "contract_manager_config" {
  description = "Custom configuration for contract manager"
  type        = map(any)
  default     = {}
}

# Database Configuration
variable "firefly_database_type" {
  description = "Database type for Firefly (postgres, sqlite)"
  type        = string
  default     = "postgres"
}

# Advanced Configuration
variable "firefly_version" {
  description = "Firefly version to deploy"
  type        = string
  default     = "latest"
}

