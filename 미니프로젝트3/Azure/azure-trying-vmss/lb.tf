resource "azurerm_public_ip" "lb-pubip" {
  name                = "lb-pubip"
  location            = azurerm_resource_group.wp-rg.location
  resource_group_name = azurerm_resource_group.wp-rg.name
  allocation_method   = "Static"

  sku = "Standard"
}

resource "azurerm_lb" "vmss-lb" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.wp-rg.location
  resource_group_name = azurerm_resource_group.wp-rg.name
  
  sku = "Standard"

  #Front
  frontend_ip_configuration {
    name                 = "lb-publicip"
    public_ip_address_id = azurerm_public_ip.lb-pubip.id
    #subnet_id            = azurerm_subnet.lb-subnet.id
  }

  depends_on = [
    azurerm_public_ip.lb-pubip
  ]
}

resource "azurerm_lb_backend_address_pool" "lb-pool" {
  loadbalancer_id = azurerm_lb.vmss-lb.id
  name            = "lb-pool"

  depends_on = [
    azurerm_lb.vmss-lb
  ]
}

resource "azurerm_lb_probe" "lb-probe" {
  loadbalancer_id = azurerm_lb.vmss-lb.id
  name            = "lb-probe"
  port            = 80

  depends_on = [
    azurerm_lb.vmss-lb
  ]
}

resource "azurerm_lb_rule" "lb-rule" {
  loadbalancer_id                = azurerm_lb.vmss-lb.id
  name                           = "lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-publicip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-pool.id]
  probe_id                       = azurerm_lb_probe.lb-probe.id
  depends_on = [
    azurerm_lb.vmss-lb,
    azurerm_lb_probe.lb-probe
  ]
}