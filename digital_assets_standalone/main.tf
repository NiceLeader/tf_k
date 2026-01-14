# Digital Assets Standalone Deployment
# Root module that calls the digital_assets module

module "digital_assets" {
  source = "./module"

  # Environment
  environment_id   = var.environment_id
  environment_name = var.environment_name

  # Existing Services
  key_manager_service_id = var.key_manager_service_id
  evm_gateway_service_id = var.evm_gateway_service_id

  # Wallet & Key
  enable_wallet_creation = var.enable_wallet_creation
  wallet_name            = var.wallet_name
  signing_key_name       = var.signing_key_name
  signing_key_count      = var.signing_key_count

  # Tokenization Stack
  enable_tokenization_stack = var.enable_tokenization_stack
  tokenization_stack_name   = var.tokenization_stack_name
  asset_manager_name        = var.asset_manager_name
  enable_erc20_indexer      = var.enable_erc20_indexer
  firefly_namespace         = var.firefly_namespace

  # Custody Stack
  enable_custody_stack  = var.enable_custody_stack
  custody_stack_name    = var.custody_stack_name
  wallet_manager_name   = var.wallet_manager_name

  # Token Configuration
  token_name                      = var.token_name
  token_symbol                    = var.token_symbol
  existing_token_contract_address = var.existing_token_contract_address

}
