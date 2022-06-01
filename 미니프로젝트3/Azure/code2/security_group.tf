# Create Network Security Group and rule
resource "azurerm_network_security_group" "bastion-sg" {
  name                = "bastion-sg"
  location            = azurerm_resource_group.wp-rg.location
  resource_group_name = azurerm_resource_group.wp-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "[내 IP]/32"
    destination_address_prefix = "*"
  }
}


#Wordpress VMSS sg
resource "azurerm_network_security_group" "vmss-sg" {
  name                = "wmss-sg"
  location            = azurerm_resource_group.wp-rg.location
  resource_group_name = azurerm_resource_group.wp-rg.name

  security_rule {
    name                       = "Allow SSH" # 이름
    description                = "Allow SSH"
    priority                   = 1001 # 규칙 우선순위
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow HTTP"
    description                = "Allow HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

