# Create public subnet
resource "azurerm_subnet" "wp-private-subnet" {
  #반복문
  count = var.vm-num
  name                 = "wp-priv-subnet${count.index}"
  resource_group_name  = azurerm_resource_group.wp-rg.name
  virtual_network_name = azurerm_virtual_network.wp_vnet.name
  address_prefixes     = ["10.0.${count.index+1}0.0/24"]
}

#network_interface1
resource "azurerm_network_interface" "wp-prv-nip" {
  #반복문
  count = var.vm-num
  name                = "wp-prv-nic${count.index}"
  location            = azurerm_resource_group.wp-rg.location
  resource_group_name = azurerm_resource_group.wp-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.wp-private-subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}


#프라이빗 네트워크 인터페이스-보안그룹 연결
resource "azurerm_network_interface_security_group_association" "prv-association" {
  #반복문
  count = var.vm-num
  network_interface_id      = azurerm_network_interface.wp-prv-nip[count.index].id
  network_security_group_id = azurerm_network_security_group.wp-sg.id
}
