# Kaleido Platform Credentials
# REQUIRED: Update these values with your actual credentials
kaleido_platform_api = "kaleido_platform_api"
kaleido_platform_username = "your-email@example.com"
kaleido_platform_password = "your-kaleido-api-key-or-password"

# Environment Configuration
# IMPORTANT: Update this with your actual environment ID
environment_id   = "id"
environment_name = "name"

# Network Configuration
network_name           = "dev-blockchain-network"
network_type           = "BesuNetwork"
consensus_algorithm    = "qbft"
block_period_seconds   = 4

# Node Configuration
validator_node_count = 4
archive_node_count   = 1
validator_node_size  = "small"
archive_node_size    = "medium"
node_name_prefix     = "node"

# Stack Configuration
chain_infrastructure_stack_name = "chain-infra-stack"

# Service Configuration
enable_block_indexer = true
enable_evm_gateway   = true
block_indexer_name   = "block-indexer-mock"
evm_gateway_name     = "evm-gateway-mock"

# Hyperledger Firefly Configuration
# Enable Firefly middleware deployment
enable_firefly = true

# Stack Configuration
firefly_stack_name = "firefly-middleware-stack"

# Firefly Core
enable_firefly_core = true
firefly_core_name   = "firefly-core"

# Transaction Manager
enable_transaction_manager = true
transaction_manager_name   = "firefly-txmanager"

# Custom transaction manager configuration (optional)
# transaction_manager_config = {
#   # maxInFlight = 100
#   # gasOracleMode = "connector"
#   # txTimeout = 300
#   # autoRetry = true
# }

# Private Data Manager (Data Exchange)
enable_private_data_manager = true
private_data_manager_name   = "firefly-dataexchange"

# Custom private data manager configuration (optional)
# private_data_manager_config = {
#   # maxDataSize = 10485760  # 10MB
#   # transferTimeout = 300
#   # encryptionEnabled = true
# }

# Key Manager (Signer)
enable_key_manager = true
key_manager_name   = "firefly-signer"
key_manager_type   = "HDWalletSigner" # Options: FireFlySigner, HDWalletSigner

# Custom key manager configuration (optional)
# key_manager_config = {
  # keystorePath = "/data/keystore"
  # signingAlgorithm = "secp256k1"
  # hsmEnabled = false
# }

# Contract Manager
enable_contract_manager = true
contract_manager_name   = "firefly-contracts"

# Custom contract manager configuration (optional)
# contract_manager_config = {
  # autoConfirm = true
  # confirmations = 12
  # defaultGasLimit = 5000000
  # verifyBytecode = true
# }

# Subscriptions
enable_subscriptions = true
subscriptions_name   = "firefly-subscriptions"

# Event Listeners
enable_event_listeners = true
event_listeners_name   = "firefly-events"

# Custom event listeners configuration (optional)
# event_listeners_config = {
#   fromBlock = "latest"
#   blocksToFinality = 0
#   batchSize = 100
#   pollInterval = 1000
#   contractFiltering = true
# }

# Database and Storage Configuration
firefly_database_type = "postgres" # Options: postgres, sqlite
firefly_enable_ipfs   = true       # Enable IPFS for shared storage

