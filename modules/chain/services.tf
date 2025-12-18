
# EVM Gateway


# Create Runtime for EVM Gateway
resource "kaleido_platform_runtime" "evm_gateway_runtime" {
  count       = var.enable_evm_gateway ? 1 : 0
  type        = "EVMGateway"
  name        = var.evm_gateway_name
  stack_id    = kaleido_platform_stack.chain_infra_stack.id
  environment = var.environment_id
  config_json = jsonencode({})
}

# Create Service for EVM Gateway
resource "kaleido_platform_service" "evm_gateway_service" {
  count       = var.enable_evm_gateway ? 1 : 0
  type        = "EVMGateway"
  name        = var.evm_gateway_name
  stack_id    = kaleido_platform_stack.chain_infra_stack.id
  environment = var.environment_id
  runtime     = kaleido_platform_runtime.evm_gateway_runtime[0].id

  config_json = jsonencode({
    network = {
      id = kaleido_platform_network.blockchain_network.id
    }
  })

  depends_on = [
    kaleido_platform_service.validator_service,
    kaleido_platform_service.archive_service
  ]
}

# Data source to get EVM network information
data "kaleido_platform_evm_netinfo" "evm_gateway_netinfo" {
  count       = var.enable_evm_gateway ? 1 : 0
  environment = var.environment_id
  service     = kaleido_platform_service.evm_gateway_service[0].id

  depends_on = [
    kaleido_platform_service.validator_service,
    kaleido_platform_service.evm_gateway_service
  ]
}


# Block Indexer


# Create Runtime for Block Indexer
resource "kaleido_platform_runtime" "block_indexer_runtime" {
  count       = var.enable_block_indexer ? 1 : 0
  type        = "BlockIndexer"
  name        = var.block_indexer_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.chain_infra_stack.id
  config_json = jsonencode({})
}

# Create Service for Block Indexer
resource "kaleido_platform_service" "block_indexer_service" {
  count       = var.enable_block_indexer ? 1 : 0
  type        = "BlockIndexer"
  name        = var.block_indexer_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.chain_infra_stack.id
  runtime     = kaleido_platform_runtime.block_indexer_runtime[0].id

  config_json = jsonencode({
    evmGateway = {
      id = var.enable_evm_gateway ? kaleido_platform_service.evm_gateway_service[0].id : null
    }
  })

  depends_on = [
    kaleido_platform_service.evm_gateway_service
  ]
}
