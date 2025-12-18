# Create Stack for Chain Infrastructure
resource "kaleido_platform_stack" "chain_infra_stack" {
  environment = var.environment_id
  name        = var.chain_infrastructure_stack_name
  type        = "chain_infrastructure"
  network_id  = kaleido_platform_network.blockchain_network.id
}

# Create Blockchain Network
resource "kaleido_platform_network" "blockchain_network" {
  type        = var.network_type
  name        = var.network_name
  environment = var.environment_id

  config_json = jsonencode({
    bootstrapOptions = {
      "${var.consensus_algorithm}" = {
        blockperiodseconds = var.block_period_seconds
      }
    }
  })
}
