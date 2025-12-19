# =============================================================================
# Kaleido Platform Credentials
# =============================================================================
kaleido_platform_api      = "https://<account>.platform.<region>.kaleido.cloud"
kaleido_platform_username = "<username>"
kaleido_platform_password = "<password-or-api-key>"

# =============================================================================
# Environment Configuration
# =============================================================================
environment_id   = "e:<environment-id>"
environment_name = "<environment-name>"

# Existing Service IDs (from Kaleido Console)
key_manager_service_id = "s:<key-manager-service-id>"  # FireFly Signer
evm_gateway_service_id = "r:<evm-gateway-runtime-id>"

# =============================================================================
# WALLET & KEY - Created in KeyManager for signing transactions
# =============================================================================
enable_wallet_creation = true
wallet_name            = "digital-assets-wallet"
signing_key_name       = "signing-key"

# =============================================================================
# TOKENIZATION STACK - Asset Manager
# For token tracking, ERC20/ERC721 indexing
# =============================================================================
enable_tokenization_stack = true
tokenization_stack_name   = "tokenization-stack"
asset_manager_name        = "asset-manager"

# ERC20 Indexer - tracks token transfers via FireFly
enable_erc20_indexer = true
firefly_namespace    = "firefly"  # Hyperledger FireFly namespace name

# =============================================================================
# CUSTODY STACK - Wallet Manager
# For wallet management, custody operations
# =============================================================================
enable_custody_stack   = true
custody_stack_name     = "custody-stack"
wallet_manager_name    = "wallet-manager"

# =============================================================================
# Token Configuration
# =============================================================================
token_name   = "MyToken"
token_symbol = "MTK"

# Optional: Link to existing ERC20 contract (uncomment to use)
# existing_token_contract_address = "0x..."
