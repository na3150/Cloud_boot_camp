variable "az-region" {
  description = "azurerm_virtual_network Region"
  type        = string
  default     = "koreacentral"
}

variable "rg-name" {
  description = "resource_group_name"
  type        = string
  default     = "wp-resource-group"
}

variable "db-server" {
  description = "Azure MariaDB Server Name"
  type        = string
  default     = "wp-mdb-server-d"
}

variable "db-user" {
  description = "Azure MariaDB Wordpress User"
  type        = string
  default     = "wordpress"
}

variable "db-password" {
  description = "Azure MariaDB Password"
  type        = string
  default     = "p@ssw0rd"
}

variable "vm-num" {
  description = "The Number Of VM"
  type        = number
  default     = 2
}


variable "admin_user" {
  description = "User of VMSS"
  type        = string
  default     = "adminuser"
}