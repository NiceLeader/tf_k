
# Hyperledger Firefly Middleware Stack

# Create Stack for Firefly Middleware
resource "kaleido_platform_stack" "firefly_stack" {
  environment = var.environment_id
  name        = var.firefly_stack_name
  type        = "web3_middleware"
}


# Key Manager

# Must be created FIRST as other services depend on it

resource "kaleido_platform_runtime" "key_manager_runtime" {
  count       = var.enable_key_manager ? 1 : 0
  type        = "KeyManager"
  name        = var.key_manager_name
  environment = var.environment_id
  config_json = jsonencode({})
}

resource "kaleido_platform_service" "key_manager_service" {
  count       = var.enable_key_manager ? 1 : 0
  type        = "KeyManager"
  name        = var.key_manager_name
  environment = var.environment_id
  runtime     = kaleido_platform_runtime.key_manager_runtime[0].id
  config_json = jsonencode({})
}

# Create wallet and key for Firefly
resource "kaleido_platform_kms_wallet" "firefly_wallet" {
  count       = var.enable_key_manager ? 1 : 0
  type        = "hdwallet"
  name        = "firefly_wallet"
  environment = var.environment_id
  service     = kaleido_platform_service.key_manager_service[0].id
  config_json = jsonencode({})
}

resource "kaleido_platform_kms_key" "firefly_org_key" {
  count       = var.enable_key_manager ? 1 : 0
  name        = "firefly_org_key"
  environment = var.environment_id
  service     = kaleido_platform_service.key_manager_service[0].id
  wallet      = kaleido_platform_kms_wallet.firefly_wallet[0].id
}


# Transaction Manager

# Manages blockchain transaction lifecycle

resource "kaleido_platform_runtime" "transaction_manager_runtime" {
  count       = var.enable_transaction_manager ? 1 : 0
  type        = "TransactionManager"
  name        = var.transaction_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  config_json = jsonencode({})
}

resource "kaleido_platform_service" "transaction_manager_service" {
  count       = var.enable_transaction_manager ? 1 : 0
  type        = "TransactionManager"
  name        = var.transaction_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  runtime     = kaleido_platform_runtime.transaction_manager_runtime[0].id

  config_json = jsonencode(merge(
    {
      keyManager = var.enable_key_manager ? {
        id = kaleido_platform_service.key_manager_service[0].id
      } : null
      type = "evm"
      evm = {
        confirmations = {
          required = var.transaction_manager_confirmations
        }
        connector = {
          evmGateway = {
            id = var.evm_gateway_service_id
          }
        }
      }
    },
    var.transaction_manager_config
  ))

  depends_on = [
    kaleido_platform_service.key_manager_service
  ]
}


# Private Data Manager

# Manages private data exchange between parties

resource "kaleido_platform_runtime" "private_data_manager_runtime" {
  count       = var.enable_private_data_manager ? 1 : 0
  type        = "PrivateDataManager"
  name        = var.private_data_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  config_json = jsonencode({})
}

resource "kaleido_platform_service" "private_data_manager_service" {
  count       = var.enable_private_data_manager ? 1 : 0
  type        = "PrivateDataManager"
  name        = var.private_data_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  runtime     = kaleido_platform_runtime.private_data_manager_runtime[0].id

  config_json = jsonencode(merge(
    {
      dataExchangeType = "https"
    },
    var.private_data_manager_config
  ))
}



# Contract Manager

# Manages smart contract deployment

resource "kaleido_platform_runtime" "contract_manager_runtime" {
  count       = var.enable_contract_manager ? 1 : 0
  type        = "ContractManager"
  name        = var.contract_manager_name
  environment = var.environment_id
  config_json = jsonencode({})
}

resource "kaleido_platform_service" "contract_manager_service" {
  count       = var.enable_contract_manager ? 1 : 0
  type        = "ContractManager"
  name        = var.contract_manager_name
  environment = var.environment_id
  runtime     = kaleido_platform_runtime.contract_manager_runtime[0].id
  config_json = jsonencode({})
}



# Hyperledger Firefly Core

# Main orchestration engine

resource "kaleido_platform_runtime" "firefly_core_runtime" {
  count       = var.enable_firefly_core ? 1 : 0
  type        = "FireFly"
  name        = var.firefly_core_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  config_json = jsonencode({})
}

resource "kaleido_platform_service" "firefly_core_service" {
  count       = var.enable_firefly_core ? 1 : 0
  type        = "FireFly"
  name        = var.firefly_core_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.firefly_stack.id
  runtime     = kaleido_platform_runtime.firefly_core_runtime[0].id

  config_json = jsonencode({
    transactionManager = var.enable_transaction_manager ? {
      id = kaleido_platform_service.transaction_manager_service[0].id
    } : null
    privatedatamanager = var.enable_private_data_manager ? {
      id = kaleido_platform_service.private_data_manager_service[0].id
    } : null
  })

  depends_on = [
    kaleido_platform_service.transaction_manager_service,
    kaleido_platform_service.private_data_manager_service
  ]
}

