# Kaleido Platform Credentials
variable "kaleido_platform_api" {
  description = "Kaleido Platform API endpoint"
  type        = string
}

variable "kaleido_platform_username" {
  description = "Kaleido Platform username"
  type        = string
  sensitive   = true
}

variable "kaleido_platform_password" {
  description = "Kaleido Platform password or API key"
  type        = string
  sensitive   = true
}

# Environment
variable "environment_id" {
  description = "Kaleido environment ID"
  type        = string
}

variable "environment_name" {
  description = "Environment name for reference"
  type        = string
  default     = ""
}

# Existing Service IDs (from Kaleido Console)
variable "key_manager_service_id" {
  description = "ID of existing KeyManager service (FireFly Signer)"
  type        = string
}

variable "evm_gateway_service_id" {
  description = "ID of existing EVM Gateway service"
  type        = string
}

# =============================================================================
# WALLET & KEY Configuration
# =============================================================================

variable "enable_wallet_creation" {
  description = "Create HD Wallet and signing key in KeyManager"
  type        = bool
  default     = true
}

variable "wallet_name" {
  description = "Name for the HD Wallet"
  type        = string
  default     = "digital-assets-wallet"
}

variable "signing_key_name" {
  description = "Name for the signing key"
  type        = string
  default     = "signing-key"
}

# =============================================================================
# TOKENIZATION STACK Configuration
# =============================================================================

variable "enable_tokenization_stack" {
  description = "Enable TokenizationStack with AssetManager"
  type        = bool
  default     = true
}

variable "tokenization_stack_name" {
  description = "Name for the TokenizationStack"
  type        = string
  default     = "tokenization-stack"
}

variable "asset_manager_name" {
  description = "Name for the Asset Manager service"
  type        = string
  default     = "asset-manager"
}

variable "enable_erc20_indexer" {
  description = "Enable ERC20 token indexer task and FireFly listener"
  type        = bool
  default     = true
}

variable "firefly_namespace" {
  description = "FireFly namespace name (usually the FireFly service name)"
  type        = string
  default     = "firefly"
}

# =============================================================================
# CUSTODY STACK Configuration
# =============================================================================

variable "enable_custody_stack" {
  description = "Enable CustodyStack with WalletManager"
  type        = bool
  default     = true
}

variable "custody_stack_name" {
  description = "Name for the CustodyStack"
  type        = string
  default     = "custody-stack"
}

variable "wallet_manager_name" {
  description = "Name for the Wallet Manager service"
  type        = string
  default     = "wallet-manager"
}

# =============================================================================
# Token Configuration (for linking existing contracts)
# =============================================================================

variable "token_name" {
  description = "Name of the token"
  type        = string
  default     = "Token"
}

variable "token_symbol" {
  description = "Symbol of the token"
  type        = string
  default     = "TKN"
}

variable "existing_token_contract_address" {
  description = "Address of existing ERC20 token contract to link (optional)"
  type        = string
  default     = ""
}
