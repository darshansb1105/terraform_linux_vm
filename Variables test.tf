variable "resource_group_name" {
  default = "rg-centro-admin-spoke-test-001"
}

variable "location" {
  default = "South Central US"
}

variable "vnet_name" {
  default = "vnet-centro-admin-spoke-test-001"
}

variable "subnet_name" {
  default = "snet-centro-admin-test-spe2-004"
}

variable "os_name" {
   default = [ "Viewer1-autoDploy", "Viewer2-autoDploy"]
  }     
  

variable "vm_size" {
  default =  "D2s_v3"
}

variable "disk_specification" {
  default = "Standard_LRS"
}

variable "username" {
  default = "rtds"
}
variable "password" {
  default = "L0C4L4dmin!"
}

variable "source_image" {
  default = {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}