# Digital Assets Module
# Deploys both TokenizationStack (AssetManager) and CustodyStack (WalletManager)
# Both use the existing KeyManager (FireFly Signer)

# =============================================================================
# WALLET & KEY - Created in existing KeyManager
# Required for signing transactions and managing tokens
# =============================================================================

resource "kaleido_platform_kms_wallet" "hdwallet" {
  count       = var.enable_wallet_creation ? 1 : 0
  type        = "hdwallet"
  name        = var.wallet_name
  environment = var.environment_id
  service     = var.key_manager_service_id
  config_json = jsonencode({})
}

resource "kaleido_platform_kms_key" "signing_key" {
  count       = var.enable_wallet_creation ? 1 : 0
  name        = var.signing_key_name
  environment = var.environment_id
  service     = var.key_manager_service_id
  wallet      = kaleido_platform_kms_wallet.hdwallet[0].id
}

# NOTE: Address registration in AssetManager/WalletManager requires
# kaleido_platform_ams_address which is not available in provider v1.1.0
# Addresses will be auto-registered when ERC20 Indexer detects transactions

# =============================================================================
# TOKENIZATION STACK - Asset Manager
# For token tracking, ERC20/ERC721 indexing, asset management
# =============================================================================

resource "kaleido_platform_stack" "tokenization_stack" {
  count       = var.enable_tokenization_stack ? 1 : 0
  environment = var.environment_id
  name        = var.tokenization_stack_name
  type        = "digital_assets"
  sub_type    = "TokenizationStack"
}

resource "kaleido_platform_runtime" "asset_manager_runtime" {
  count       = var.enable_tokenization_stack ? 1 : 0
  type        = "AssetManager"
  name        = var.asset_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.tokenization_stack[0].id
  config_json = jsonencode({})
}

resource "kaleido_platform_service" "asset_manager_service" {
  count       = var.enable_tokenization_stack ? 1 : 0
  type        = "AssetManager"
  name        = var.asset_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.tokenization_stack[0].id
  runtime     = kaleido_platform_runtime.asset_manager_runtime[0].id

  config_json = jsonencode({
    keyManager = {
      id = var.key_manager_service_id
    }
  })
}

# =============================================================================
# ERC20 INDEXER TASK - For tracking token transfers
# =============================================================================

resource "kaleido_platform_ams_task" "erc20_indexer" {
  count       = var.enable_tokenization_stack && var.enable_erc20_indexer ? 1 : 0
  environment = var.environment_id
  service     = kaleido_platform_service.asset_manager_service[0].id
  name        = "erc20_indexer"

  task_yaml = <<EOT
steps:
- name: naming
  options:
    template: >-
      {
          "pool": "pool",
          "poolQualified": input.blockchainEvent.info.address & "/pool",
          "activity": "pool-" & input.blockchainEvent.info.address,
          "protocolIdSafe": $replace(input.blockchainEvent.protocolId, "/", "_")
      }
  stopCondition: >-
    $not(
        input.blockchainEvent.info.signature = "Transfer(address,address,uint256)" and
        $exists(input.blockchainEvent.output.value)
    )
  type: jsonata_template
- dynamicOptions:
    activities: |-
      [{
          "updateType": "create_or_ignore",
          "name": steps.naming.data.activity
      }]
    addresses: |-
      [
        {
          "updateType": "create_or_update",
          "address": input.blockchainEvent.info.address,
          "displayName": input.blockchainEvent.info.address,
          "contract": true
        },
        {
          "updateType": "create_or_update",
          "address": input.blockchainEvent.output.from,
          "displayName": input.blockchainEvent.output.from
        },
        {
          "updateType": "create_or_update",
          "address": input.blockchainEvent.output.to,
          "displayName": input.blockchainEvent.output.to
        }
      ]
    events: |-
      [{
          "updateType": "create_or_replace",
          "name": "transfer-" & steps.naming.data.protocolIdSafe,
          "activity": steps.naming.data.activity,
          "parent": {
              "type": "pool",
              "ref": steps.naming.data.poolQualified
          },
          "info": {
            "address": input.blockchainEvent.info.address,
            "blockNumber": input.blockchainEvent.info.blockNumber,
            "protocolId": input.blockchainEvent.protocolId,
            "transactionHash": input.blockchainEvent.info.transactionHash
          }
      }]
    pools: |-
      [{
          "updateType": "create_or_ignore",
          "address": input.blockchainEvent.info.address,
          "name": steps.naming.data.pool,
          "standard": "ERC-20",
          "firefly": {
            "namespace": input.blockchainEvent.namespace
          }
      }]
    transfers: |-
      [{
          "updateType": "create_or_replace",
          "protocolId": input.blockchainEvent.protocolId,
          "from": input.blockchainEvent.output.from,
          "to": input.blockchainEvent.output.to,
          "amount": input.blockchainEvent.output.value,
          "transactionHash": input.blockchainEvent.info.transactionHash,
          "parent": {
              "type": "pool",
              "ref": steps.naming.data.poolQualified
          },
          "firefly": {
            "namespace": input.blockchainEvent.namespace
          },
          "info": {
              "blockNumber": input.blockchainEvent.info.blockNumber
          }
      }]
  name: transfer_upsert
  type: data_model_update
- dynamicOptions:
    assets: |-
      [{
          "updateType": "create_or_ignore",
          "name": "pool_" & input.blockchainEvent.info.address
      }]
    pools: |-
      [{
          "updateType": "update_only",
          "address": input.blockchainEvent.info.address,
          "name": steps.naming.data.pool,
          "asset": "pool_" & input.blockchainEvent.info.address
      }]
  name: link_asset
  type: data_model_update
EOT
}

# =============================================================================
# FIREFLY LISTENER - Listens for blockchain events from FireFly
# =============================================================================

resource "kaleido_platform_ams_fflistener" "erc20_indexer" {
  count       = var.enable_tokenization_stack && var.enable_erc20_indexer ? 1 : 0
  environment = var.environment_id
  service     = kaleido_platform_service.asset_manager_service[0].id
  name        = "erc20_indexer"

  depends_on = [kaleido_platform_ams_task.erc20_indexer]

  config_json = jsonencode({
    namespace = var.firefly_namespace
    taskName  = "erc20_indexer"
    blockchainEvents = {
      createOptions = {
        firstEvent = "0"
      }
      abiEvents = [
        {
          anonymous = false
          inputs = [
            {
              indexed = true
              name    = "from"
              type    = "address"
            },
            {
              indexed = true
              name    = "to"
              type    = "address"
            },
            {
              indexed = false
              name    = "value"
              type    = "uint256"
            }
          ]
          name = "Transfer"
          type = "event"
        }
      ]
    }
  })
}

# =============================================================================
# CUSTODY STACK - Wallet Manager
# For wallet management, custody operations, key management
# =============================================================================

resource "kaleido_platform_stack" "custody_stack" {
  count       = var.enable_custody_stack ? 1 : 0
  environment = var.environment_id
  name        = var.custody_stack_name
  type        = "digital_assets"
  sub_type    = "CustodyStack"
}

resource "kaleido_platform_runtime" "wallet_manager_runtime" {
  count       = var.enable_custody_stack ? 1 : 0
  type        = "WalletManager"
  name        = var.wallet_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.custody_stack[0].id
  config_json = jsonencode({})
}

resource "kaleido_platform_service" "wallet_manager_service" {
  count       = var.enable_custody_stack ? 1 : 0
  type        = "WalletManager"
  name        = var.wallet_manager_name
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.custody_stack[0].id
  runtime     = kaleido_platform_runtime.wallet_manager_runtime[0].id

  config_json = jsonencode({
    keyManager = {
      id = var.key_manager_service_id
    }
  })
}
