# =============================================================================
# WALLET & KEY Outputs
# =============================================================================

output "wallet_id" {
  description = "ID of the HD Wallet"
  value       = var.enable_wallet_creation ? kaleido_platform_kms_wallet.hdwallet[0].id : null
}

output "signing_key_id" {
  description = "ID of the signing key"
  value       = var.enable_wallet_creation ? kaleido_platform_kms_key.signing_key[0].id : null
}

output "signing_key_address" {
  description = "Ethereum address of the signing key"
  value       = var.enable_wallet_creation ? kaleido_platform_kms_key.signing_key[0].address : null
}

# =============================================================================
# TOKENIZATION STACK Outputs
# =============================================================================

output "tokenization_stack_id" {
  description = "ID of the TokenizationStack"
  value       = var.enable_tokenization_stack ? kaleido_platform_stack.tokenization_stack[0].id : null
}

output "asset_manager_runtime_id" {
  description = "Runtime ID of Asset Manager"
  value       = var.enable_tokenization_stack ? kaleido_platform_runtime.asset_manager_runtime[0].id : null
}

output "asset_manager_service_id" {
  description = "Service ID of Asset Manager"
  value       = var.enable_tokenization_stack ? kaleido_platform_service.asset_manager_service[0].id : null
}

output "erc20_indexer_task_id" {
  description = "ID of ERC20 indexer task"
  value       = var.enable_tokenization_stack && var.enable_erc20_indexer ? kaleido_platform_ams_task.erc20_indexer[0].id : null
}

output "erc20_indexer_listener_id" {
  description = "ID of ERC20 FireFly listener"
  value       = var.enable_tokenization_stack && var.enable_erc20_indexer ? kaleido_platform_ams_fflistener.erc20_indexer[0].id : null
}

# =============================================================================
# CUSTODY STACK Outputs
# =============================================================================

output "custody_stack_id" {
  description = "ID of the CustodyStack"
  value       = var.enable_custody_stack ? kaleido_platform_stack.custody_stack[0].id : null
}

output "wallet_manager_runtime_id" {
  description = "Runtime ID of Wallet Manager"
  value       = var.enable_custody_stack ? kaleido_platform_runtime.wallet_manager_runtime[0].id : null
}

output "wallet_manager_service_id" {
  description = "Service ID of Wallet Manager"
  value       = var.enable_custody_stack ? kaleido_platform_service.wallet_manager_service[0].id : null
}

# =============================================================================
# Summary
# =============================================================================

output "deployment_summary" {
  description = "Summary of digital assets deployment"
  value = {
    environment = var.environment_name

    tokenization = var.enable_tokenization_stack ? {
      stack_id           = kaleido_platform_stack.tokenization_stack[0].id
      stack_name         = kaleido_platform_stack.tokenization_stack[0].name
      asset_manager_id   = kaleido_platform_service.asset_manager_service[0].id
      erc20_indexer      = var.enable_erc20_indexer ? "enabled" : "disabled"
    } : null

    custody = var.enable_custody_stack ? {
      stack_id           = kaleido_platform_stack.custody_stack[0].id
      stack_name         = kaleido_platform_stack.custody_stack[0].name
      wallet_manager_id  = kaleido_platform_service.wallet_manager_service[0].id
    } : null

    shared_services = {
      key_manager_id     = var.key_manager_service_id
      evm_gateway_id     = var.evm_gateway_service_id
    }

    wallet = var.enable_wallet_creation ? {
      wallet_id          = kaleido_platform_kms_wallet.hdwallet[0].id
      signing_key_id     = kaleido_platform_kms_key.signing_key[0].id
      signing_address    = kaleido_platform_kms_key.signing_key[0].address
    } : null

    token_config = {
      name               = var.token_name
      symbol             = var.token_symbol
      linked_contract    = var.existing_token_contract_address != "" ? var.existing_token_contract_address : "none"
    }
  }
}
