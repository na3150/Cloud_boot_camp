variable "playbook" {
  type    = string
  default = "/home/vagrant/azure-trying-vmss/wp/wordpress.yaml"
}

variable "client_id" {
  type    = string
  default = env("AZ_ID")
}

variable "client_secret" {
  type    = string
  default = env("AZ_PASSWORD")
}

variable "subscription_id" {
  type    = string
  default = env("AZ_SUBSCRIPTION_ID")
}

variable "tenant_id" {
  type    = string
  default = env("AZ_TENANT")
}

source "azure-arm" "wp-azure-arm" {

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  managed_image_name                = "wp-centos"
  managed_image_resource_group_name = "myimg"
  ssh_username = "vagrant"

  os_type         = "Linux"
  image_publisher = "OpenLogic"
  image_offer     = "CentOS"
  image_sku       = "7_9"
  image_version   = "latest"

  location = "Korea Central"
  vm_size  = "Standard_DS2_v2"
}

build {
  sources = [ "source.azure-arm.wp-azure-arm"]

   provisioner "ansible" {
     extra_arguments= ["--become"]
     playbook_file = var.playbook
   }
}