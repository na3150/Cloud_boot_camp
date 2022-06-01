resource "azurerm_subnet" "vmss-prv-subnet" {
  name                 = "vmss-prv-subnet"
  resource_group_name  = azurerm_resource_group.wp-rg.name
  virtual_network_name = azurerm_virtual_network.wp_vnet.name
  address_prefixes     = ["10.0.50.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "wp-vmss" {
  name                            = "wp-vmss"
  resource_group_name             = azurerm_resource_group.wp-rg.name
  location                        = azurerm_resource_group.wp-rg.location
  sku                             = "Standard_F2"
  instances                       = 2
  admin_username                  = "adminuser"
  disable_password_authentication = true #비밀번호 인증X

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  custom_data = (base64encode(
    <<-EOF
      #!/bin/bash
      sudo setenforce 0
      EOF
  ))

  source_image_id = data.azurerm_image.image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "nic-vmss"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.vmss-sg.id

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss-prv-subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb-pool.id]
    }
  }
}