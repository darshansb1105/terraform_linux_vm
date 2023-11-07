
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

locals {
  private_key_filename = "C:/Softwares/Terraform/DC_Viewer_Azure/Viewer_sshKey.pem"
}

resource "null_resource" "store_private_key_locally" {

provisioner "local-exec" {
  command = <<-EOT
    echo '${jsondecode(azapi_resource_action.ssh_public_key_gen.output).privateKey}' > ${local.private_key_filename}
    chmod 600 ${local.private_key_filename}
  EOT
}
}