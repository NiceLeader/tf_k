# Environment Information
output "environment_id" {
  description = "Kaleido environment ID"
  value       = var.environment_id
}

output "environment_name" {
  description = "Environment name"
  value       = var.environment_name
}

# Network Information
output "blockchain_network_id" {
  description = "Blockchain network ID"
  value       = kaleido_platform_network.blockchain_network.id
}

output "blockchain_network_name" {
  description = "Blockchain network name"
  value       = kaleido_platform_network.blockchain_network.name
}

output "blockchain_network_type" {
  description = "Blockchain network type"
  value       = kaleido_platform_network.blockchain_network.type
}

# Stack Information
output "chain_infra_stack_id" {
  description = "Chain infrastructure stack ID"
  value       = kaleido_platform_stack.chain_infra_stack.id
}

# Validator Nodes
output "validator_node_ids" {
  description = "List of validator node runtime IDs"
  value       = kaleido_platform_runtime.validator_runtime[*].id
}

output "validator_node_names" {
  description = "List of validator node names"
  value       = kaleido_platform_runtime.validator_runtime[*].name
}

output "validator_service_ids" {
  description = "List of validator service IDs"
  value       = kaleido_platform_service.validator_service[*].id
}

# Archive Nodes
output "archive_node_ids" {
  description = "List of archive node runtime IDs"
  value       = kaleido_platform_runtime.archive_runtime[*].id
}

output "archive_node_names" {
  description = "List of archive node names"
  value       = kaleido_platform_runtime.archive_runtime[*].name
}

output "archive_service_ids" {
  description = "List of archive service IDs"
  value       = kaleido_platform_service.archive_service[*].id
}

# Load Test Nodes
output "load_test_node_ids" {
  description = "List of load test node runtime IDs"
  value       = kaleido_platform_runtime.load_test_runtime[*].id
}

output "load_test_node_names" {
  description = "List of load test node names"
  value       = kaleido_platform_runtime.load_test_runtime[*].name
}

output "load_test_service_ids" {
  description = "List of load test service IDs"
  value       = kaleido_platform_service.load_test_service[*].id
}

# EVM Gateway
output "evm_gateway_runtime_id" {
  description = "EVM Gateway runtime ID"
  value       = var.enable_evm_gateway ? kaleido_platform_runtime.evm_gateway_runtime[0].id : null
}

output "evm_gateway_service_id" {
  description = "EVM Gateway service ID"
  value       = var.enable_evm_gateway ? kaleido_platform_service.evm_gateway_service[0].id : null
}

output "evm_gateway_name" {
  description = "EVM Gateway service name"
  value       = var.enable_evm_gateway ? kaleido_platform_service.evm_gateway_service[0].name : null
}

output "evm_gateway_netinfo" {
  description = "EVM Gateway network information"
  value       = var.enable_evm_gateway ? data.kaleido_platform_evm_netinfo.evm_gateway_netinfo[0] : null
  sensitive   = true
}

# Block Indexer
output "block_indexer_runtime_id" {
  description = "Block Indexer runtime ID"
  value       = var.enable_block_indexer ? kaleido_platform_runtime.block_indexer_runtime[0].id : null
}

output "block_indexer_service_id" {
  description = "Block Indexer service ID"
  value       = var.enable_block_indexer ? kaleido_platform_service.block_indexer_service[0].id : null
}

output "block_indexer_name" {
  description = "Block Indexer service name"
  value       = var.enable_block_indexer ? kaleido_platform_service.block_indexer_service[0].name : null
}

# Summary
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment           = var.environment_name
    network_name          = var.network_name
    consensus             = var.consensus_algorithm
    validator_nodes_count = var.validator_node_count
    archive_nodes_count   = var.archive_node_count
    load_test_nodes_count = var.load_test_node_count
    evm_gateway_enabled   = var.enable_evm_gateway
    block_indexer_enabled = var.enable_block_indexer
  }
}
