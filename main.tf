# Root main.tf - calls chain module and firefly module


# Blockchain Chain Module

module "blockchain_chain" {
  source = "./modules/chain"

  # Environment
  environment_id   = var.environment_id
  environment_name = var.environment_name

  # Network
  network_name                    = var.network_name
  network_type                    = var.network_type
  consensus_algorithm             = var.consensus_algorithm
  block_period_seconds            = var.block_period_seconds
  chain_infrastructure_stack_name = var.chain_infrastructure_stack_name

  # Nodes
  validator_node_count = var.validator_node_count
  archive_node_count   = var.archive_node_count
  load_test_node_count = var.load_test_node_count
  validator_node_size  = var.validator_node_size
  archive_node_size    = var.archive_node_size
  load_test_node_size  = var.load_test_node_size
  node_name_prefix     = var.node_name_prefix
  force_delete_nodes   = var.force_delete_nodes

  # Services
  enable_block_indexer = var.enable_block_indexer
  enable_evm_gateway   = var.enable_evm_gateway
  block_indexer_name   = var.block_indexer_name
  evm_gateway_name     = var.evm_gateway_name

  # Tags
  tags = var.tags
}


# Hyperledger Firefly Module

module "firefly_middleware" {
  source = "./modules/firefly"

  # Only deploy if Firefly is enabled
  count = var.enable_firefly ? 1 : 0

  # Environment
  environment_id   = var.environment_id
  environment_name = var.environment_name

  # Connect to existing blockchain network
  network_id             = module.blockchain_chain.blockchain_network_id
  evm_gateway_service_id = module.blockchain_chain.evm_gateway_service_id

  # Stack Configuration
  firefly_stack_name = var.firefly_stack_name

  # Firefly Core
  enable_firefly_core = var.enable_firefly_core
  firefly_core_name   = var.firefly_core_name

  # Transaction Manager
  enable_transaction_manager      = var.enable_transaction_manager
  transaction_manager_name        = var.transaction_manager_name
  transaction_manager_confirmations = var.transaction_manager_confirmations
  transaction_manager_config      = var.transaction_manager_config

  # Private Data Manager
  enable_private_data_manager = var.enable_private_data_manager
  private_data_manager_name   = var.private_data_manager_name
  private_data_manager_config = var.private_data_manager_config

  # Key Manager
  enable_key_manager = var.enable_key_manager
  key_manager_name   = var.key_manager_name
  key_manager_type   = var.key_manager_type
  key_manager_config = var.key_manager_config

  # Contract Manager
  enable_contract_manager = var.enable_contract_manager
  contract_manager_name   = var.contract_manager_name
  contract_manager_config = var.contract_manager_config

  # Database Configuration
  database_type = var.firefly_database_type

  # Advanced Configuration
  firefly_version = var.firefly_version

  # Tags
  tags = merge(var.tags, {
    Component = "firefly-middleware"
  })

  depends_on = [
    module.blockchain_chain
  ]
}
