
# Stack Outputs

output "firefly_stack_id" {
  description = "ID of the Firefly middleware stack"
  value       = kaleido_platform_stack.firefly_stack.id
}

output "firefly_stack_name" {
  description = "Name of the Firefly middleware stack"
  value       = kaleido_platform_stack.firefly_stack.name
}


# Firefly Core Outputs

output "firefly_core_runtime_id" {
  description = "Runtime ID of Firefly core"
  value       = var.enable_firefly_core ? kaleido_platform_runtime.firefly_core_runtime[0].id : null
}

output "firefly_core_service_id" {
  description = "Service ID of Firefly core"
  value       = var.enable_firefly_core ? kaleido_platform_service.firefly_core_service[0].id : null
}

output "firefly_core_name" {
  description = "Name of Firefly core service"
  value       = var.enable_firefly_core ? kaleido_platform_service.firefly_core_service[0].name : null
}


# Transaction Manager Outputs

output "transaction_manager_runtime_id" {
  description = "Runtime ID of transaction manager"
  value       = var.enable_transaction_manager ? kaleido_platform_runtime.transaction_manager_runtime[0].id : null
}

output "transaction_manager_service_id" {
  description = "Service ID of transaction manager"
  value       = var.enable_transaction_manager ? kaleido_platform_service.transaction_manager_service[0].id : null
}

output "transaction_manager_name" {
  description = "Name of transaction manager service"
  value       = var.enable_transaction_manager ? kaleido_platform_service.transaction_manager_service[0].name : null
}


# Private Data Manager Outputs

output "private_data_manager_runtime_id" {
  description = "Runtime ID of private data manager"
  value       = var.enable_private_data_manager ? kaleido_platform_runtime.private_data_manager_runtime[0].id : null
}

output "private_data_manager_service_id" {
  description = "Service ID of private data manager"
  value       = var.enable_private_data_manager ? kaleido_platform_service.private_data_manager_service[0].id : null
}

output "private_data_manager_name" {
  description = "Name of private data manager service"
  value       = var.enable_private_data_manager ? kaleido_platform_service.private_data_manager_service[0].name : null
}


# Key Manager Outputs

output "key_manager_runtime_id" {
  description = "Runtime ID of key manager"
  value       = var.enable_key_manager ? kaleido_platform_runtime.key_manager_runtime[0].id : null
}

output "key_manager_service_id" {
  description = "Service ID of key manager"
  value       = var.enable_key_manager ? kaleido_platform_service.key_manager_service[0].id : null
}

output "key_manager_name" {
  description = "Name of key manager service"
  value       = var.enable_key_manager ? kaleido_platform_service.key_manager_service[0].name : null
}


# Contract Manager Outputs

output "contract_manager_runtime_id" {
  description = "Runtime ID of contract manager"
  value       = var.enable_contract_manager ? kaleido_platform_runtime.contract_manager_runtime[0].id : null
}

output "contract_manager_service_id" {
  description = "Service ID of contract manager"
  value       = var.enable_contract_manager ? kaleido_platform_service.contract_manager_service[0].id : null
}

output "contract_manager_name" {
  description = "Name of contract manager service"
  value       = var.enable_contract_manager ? kaleido_platform_service.contract_manager_service[0].name : null
}

# Summary Output

output "firefly_deployment_summary" {
  description = "Summary of Firefly deployment"
  value = {
    stack_id                     = kaleido_platform_stack.firefly_stack.id
    stack_name                   = kaleido_platform_stack.firefly_stack.name
    environment                  = var.environment_name
    network_id                   = var.network_id
    firefly_core_enabled         = var.enable_firefly_core
    transaction_manager_enabled  = var.enable_transaction_manager
    private_data_manager_enabled = var.enable_private_data_manager
    key_manager_enabled          = var.enable_key_manager
    contract_manager_enabled     = var.enable_contract_manager
    database_type                = var.database_type
  }
}


# Service IDs Collection

output "all_service_ids" {
  description = "Collection of all Firefly service IDs"
  value = {
    firefly_core         = var.enable_firefly_core ? kaleido_platform_service.firefly_core_service[0].id : null
    transaction_manager  = var.enable_transaction_manager ? kaleido_platform_service.transaction_manager_service[0].id : null
    private_data_manager = var.enable_private_data_manager ? kaleido_platform_service.private_data_manager_service[0].id : null
    key_manager          = var.enable_key_manager ? kaleido_platform_service.key_manager_service[0].id : null
    contract_manager     = var.enable_contract_manager ? kaleido_platform_service.contract_manager_service[0].id : null
  }
}
