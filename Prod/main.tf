#Production
provider "azurerm" {
  features {}
}

data "azurerm_virtual_network" "centro" {
  name                = "${var.vnet_name}"
  resource_group_name = "${var.resource_group_name}"
}

data "azurerm_subnet" "centro" {
  name                 = "${var.subnet_name}"
  virtual_network_name = data.azurerm_virtual_network.centro.name
  resource_group_name  = "${var.resource_group_name}"
}

resource "azurerm_network_security_group" "centro" {
  for_each              = toset("${var.os_name}")
  name                = "${each.key}-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

}

resource "azurerm_network_interface" "centro" {
  for_each              = toset("${var.os_name}")
  name                = "${each.key}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

ip_configuration {
    name                          = "centroViewer-ip-config"
    subnet_id                     = data.azurerm_subnet.centro.id
    private_ip_address_allocation = "Dynamic"
   
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "centro" {
  for_each              = toset("${var.os_name}")
  network_interface_id     = azurerm_network_interface.centro[each.key].id
  network_security_group_id = azurerm_network_security_group.centro[each.key].id
}


# Define the virtual machine
resource "azurerm_linux_virtual_machine" "centro" {
  
  for_each              = toset("${var.os_name}")
  name                  = "${each.key}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids =  [azurerm_network_interface.centro[each.key].id]
  size               = "${var.vm_size}"
  # Define other VM properties like size, OS, etc.
  source_image_reference  {
    publisher = "${var.source_image.publisher}"
    offer     = "${var.source_image.offer}"
    sku       = "${var.source_image.sku}"
    version   = "${var.source_image.version}"
  } 
  
  admin_ssh_key {
    username   = "${var.username}"
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }
  admin_username = var.username

  os_disk {
    name                  = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type   = "${var.disk_specification}"
  }
  
}

resource "azurerm_managed_disk" "centro" {
  for_each              = toset("${var.os_name}")
  name                 = "${each.key}_DataDisk"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "${var.disk_specification}"
  create_option        = "Empty"
  disk_size_gb         = 50
}
resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  for_each              = toset("${var.os_name}")
  managed_disk_id    = azurerm_managed_disk.centro[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.centro[each.key].id
  lun                ="10"
  caching            = "ReadWrite"
}
# resource "null_resource" "example" {
#      for_each              = toset("${var.os_name}")
#     connection {
#         type = "ssh"
#         user = "${var.username}"
#         password = "${var.password}"
#         host =  azurerm_network_interface.centro[each.key].private_ip_address
#         port = 22
#     }
#     provisioner "file" {
#         source = "1ViewerInstallScript.sh"
#         destination = "/1ViewerInstallScript.sh"
#     }

#     provisioner "remote-exec" {
#         inline = [
#             "chmod +x /1ViewerInstallScript.sh",
#             "/bin/bash /1ViewerInstallScript.sh "
#         ]
#     }
# }