
# Validator Nodes (4 nodes)


# Create Runtime for Validator Nodes
resource "kaleido_platform_runtime" "validator_runtime" {
  count        = var.validator_node_count
  type         = "BesuNode"
  name         = "${var.node_name_prefix}-validator-${count.index + 1}"
  environment  = var.environment_id
  stack_id     = kaleido_platform_stack.chain_infra_stack.id
  config_json  = jsonencode({})
  force_delete = var.force_delete_nodes
}

# Create Service for Validator Nodes
resource "kaleido_platform_service" "validator_service" {
  count       = var.validator_node_count
  type        = "BesuNode"
  name        = "${var.node_name_prefix}-validator-${count.index + 1}"
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.chain_infra_stack.id
  runtime     = kaleido_platform_runtime.validator_runtime[count.index].id

  config_json = jsonencode({
    network = {
      id = kaleido_platform_network.blockchain_network.id
    }
  })

  force_delete = var.force_delete_nodes
}


# Archive Node (1 node)


# Create Runtime for Archive Node
resource "kaleido_platform_runtime" "archive_runtime" {
  count        = var.archive_node_count
  type         = "BesuNode"
  name         = "${var.node_name_prefix}-archive-${count.index + 1}"
  environment  = var.environment_id
  stack_id     = kaleido_platform_stack.chain_infra_stack.id
  config_json  = jsonencode({})
  force_delete = var.force_delete_nodes
}

# Create Service for Archive Node
resource "kaleido_platform_service" "archive_service" {
  count       = var.archive_node_count
  type        = "BesuNode"
  name        = "${var.node_name_prefix}-archive-${count.index + 1}"
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.chain_infra_stack.id
  runtime     = kaleido_platform_runtime.archive_runtime[count.index].id

  config_json = jsonencode({
    network = {
      id = kaleido_platform_network.blockchain_network.id
    }
  })

  force_delete = var.force_delete_nodes
}


# Load Test Nodes (2 temporary non-validator nodes)


# Create Runtime for Load Test Nodes
resource "kaleido_platform_runtime" "load_test_runtime" {
  count        = var.load_test_node_count
  type         = "BesuNode"
  name         = "${var.node_name_prefix}-loadtest-${count.index + 1}"
  environment  = var.environment_id
  stack_id     = kaleido_platform_stack.chain_infra_stack.id
  config_json  = jsonencode({})
  force_delete = var.force_delete_nodes
}

# Create Service for Load Test Nodes
resource "kaleido_platform_service" "load_test_service" {
  count       = var.load_test_node_count
  type        = "BesuNode"
  name        = "${var.node_name_prefix}-loadtest-${count.index + 1}"
  environment = var.environment_id
  stack_id    = kaleido_platform_stack.chain_infra_stack.id
  runtime     = kaleido_platform_runtime.load_test_runtime[count.index].id

  config_json = jsonencode({
    network = {
      id = kaleido_platform_network.blockchain_network.id
    }
  })

  force_delete = var.force_delete_nodes
}
