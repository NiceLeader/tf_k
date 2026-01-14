# Module Outputs

output "wallet_id" {
  description = "ID of the HD Wallet"
  value       = module.digital_assets.wallet_id
}

output "signing_key_id" {
  description = "ID of the signing key"
  value       = module.digital_assets.signing_key_id
}

output "signing_key_address" {
  description = "Ethereum address of the signing key"
  value       = module.digital_assets.signing_key_address
}

output "tokenization_stack_id" {
  description = "ID of the TokenizationStack"
  value       = module.digital_assets.tokenization_stack_id
}

output "asset_manager_service_id" {
  description = "Service ID of Asset Manager"
  value       = module.digital_assets.asset_manager_service_id
}

output "custody_stack_id" {
  description = "ID of the CustodyStack"
  value       = module.digital_assets.custody_stack_id
}

output "wallet_manager_service_id" {
  description = "Service ID of Wallet Manager"
  value       = module.digital_assets.wallet_manager_service_id
}

output "deployment_summary" {
  description = "Summary of digital assets deployment"
  value       = module.digital_assets.deployment_summary
}
