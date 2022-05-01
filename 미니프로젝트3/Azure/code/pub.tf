# Create public subnet
resource "azurerm_subnet" "wp-public-subnet" {
  name                 = "wp-pub-subnet"
  resource_group_name  = azurerm_resource_group.wp-rg.name
  virtual_network_name = azurerm_virtual_network.wp_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create private IPs
resource "azurerm_public_ip" "wp-publicip" {
  name                = "wp-publicip"
  location            = azurerm_resource_group.wp-rg.location
  resource_group_name = azurerm_resource_group.wp-rg.name
  allocation_method   = "Dynamic"
}

#network_interface
resource "azurerm_network_interface" "wp-pub-nip" {
  name                = "wp-pub-nic"
  location            = azurerm_resource_group.wp-rg.location
  resource_group_name = azurerm_resource_group.wp-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.wp-public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wp-publicip.id
  }
}

#퍼블릭 네트워크 인터페이스-보안그룹 연결
resource "azurerm_network_interface_security_group_association" "pub-association" {
  network_interface_id      = azurerm_network_interface.wp-pub-nip.id
  network_security_group_id = azurerm_network_security_group.bastion-sg.id
}