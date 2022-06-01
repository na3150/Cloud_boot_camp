output "bastion-publicip" {
  value = azurerm_linux_virtual_machine.bastion-vm.public_ip_address
}

# output "wp-privateip" {
#   value = azurerm_linux_virtual_machine.wp-vm{*}.private_ip_address
# }


output "lb-frontend_ip" {
  value = azurerm_public_ip.lb-pubip.ip_address
}