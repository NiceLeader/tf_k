
# Environment Variables

variable "environment_id" {
  description = "Kaleido environment ID"
  type        = string
}

variable "environment_name" {
  description = "Environment name for reference"
  type        = string
}


# Network Variables

variable "network_id" {
  description = "Existing blockchain network ID to connect Firefly to"
  type        = string
}

variable "evm_gateway_service_id" {
  description = "Existing EVM Gateway service ID"
  type        = string
}


# Stack Configuration

variable "firefly_stack_name" {
  description = "Name for the Firefly middleware stack"
  type        = string
  default     = "firefly-middleware-stack"
}


# Hyperledger Firefly Core

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

  validation {
    condition     = contains(["FireFlySigner", "HDWalletSigner"], var.key_manager_type)
    error_message = "Key manager type must be one of: FireFlySigner, HDWalletSigner"
  }
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

variable "database_type" {
  description = "Database type for Firefly (postgres, sqlite)"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "sqlite"], var.database_type)
    error_message = "Database type must be one of: postgres, sqlite"
  }
}


# Advanced Configuration

variable "firefly_version" {
  description = "Firefly version to deploy"
  type        = string
  default     = "latest"
}

# Tags and Metadata

variable "tags" {
  description = "Tags to apply to Firefly resources"
  type        = map(string)
  default = {
    Component = "firefly-middleware"
    ManagedBy = "terraform"
  }
}
