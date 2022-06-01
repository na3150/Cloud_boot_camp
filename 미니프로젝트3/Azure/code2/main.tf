# Create a virtual network
resource "azurerm_virtual_network" "wp_vnet" {
  name                = "myTFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.az-region
  resource_group_name = azurerm_resource_group.wp-rg.name
}

resource "azurerm_resource_group" "wp-rg" {
  name     = "wp-resource-group"
  location = var.az-region
}

#virtual_machine
resource "azurerm_linux_virtual_machine" "bastion-vm" {
  name                = "bastion-vm"
  resource_group_name = azurerm_resource_group.wp-rg.name
  location            = azurerm_resource_group.wp-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.wp-pub-nip.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  connection {
    user        = "adminuser"
    host        = self.public_ip_address
    private_key = file("/home/vagrant/.ssh/id_rsa")
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "/home/vagrant/.ssh/id_rsa"
    destination = "/tmp/key_file"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/key_file /home/adminuser/.ssh/id_rsa",
      "sudo chmod 400 /home/adminuser/.ssh/id_rsa"
    ]
  }
}
