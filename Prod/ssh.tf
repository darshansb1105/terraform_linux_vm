
data "azurerm_resource_group" "centro" {
  name = "${var.resource_group_name}"
}

resource "azapi_resource_action" "ssh_public_key_gen" {

  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {

  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "Viewer-sshKey"
  location  = var.location
  parent_id = data.azurerm_resource_group.centro.id
}

output "key_data" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
}

output "private_key" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).privateKey
  sensitive = true
}