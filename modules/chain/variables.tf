# Environment Configuration
variable "environment_id" {
  description = "Existing Kaleido environment ID to use"
  type        = string
}

variable "environment_name" {
  description = "Environment name for reference"
  type        = string
}

# Network Configuration
variable "network_name" {
  description = "Name for the blockchain network"
  type        = string
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
}

variable "evm_gateway_name" {
  description = "Name for the EVM Gateway service"
  type        = string
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

# Tags and Metadata
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
