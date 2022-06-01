resource "azurerm_subnet" "db-subnet" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.wp-rg.name
  virtual_network_name = azurerm_virtual_network.wp_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_mariadb_server" "wp-mdb-server" {
  name                = var.db-server
  location            = azurerm_resource_group.wp-rg.location
  resource_group_name = azurerm_resource_group.wp-rg.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  administrator_login          = "wordpress"
  administrator_login_password = "p@ssw0rd"
  version                      = "10.2"
  ssl_enforcement_enabled      = false
}

resource "azurerm_mariadb_database" "wordpress" {
  name                = "wordpress"
  resource_group_name = azurerm_resource_group.wp-rg.name
  server_name         = azurerm_mariadb_server.wp-mdb-server.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_mariadb_firewall_rule" "db-fw-rule" {
  name                = "db-fw-rule"
  resource_group_name = azurerm_resource_group.wp-rg.name
  server_name         = azurerm_mariadb_server.wp-mdb-server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
