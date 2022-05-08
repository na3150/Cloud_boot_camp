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

# #virtual_machine
# resource "azurerm_linux_virtual_machine" "wp-vm" {

#   #반복문
#   count = var.vm-num

#   #db 생성 후 vm 생성
#   depends_on = [
#     azurerm_mariadb_database.wordpress
#   ]

#   name                = "wp-vm${count.index}"
#   resource_group_name = azurerm_resource_group.wp-rg.name
#   location            = azurerm_resource_group.wp-rg.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   network_interface_ids = [
#     azurerm_network_interface.wp-prv-nip[count.index].id,
#   ]

#   source_image_reference {
#     publisher = "OpenLogic"
#     offer     = "CentOS"
#     sku       = "7.5"
#     version   = "latest"
#   }

#   connection {
#     user        = "adminuser"
#     host        = self.private_ip_address
#     private_key = file("~/.ssh/id_rsa")
#     timeout     = "1m"

#     bastion_user        = "adminuser"
#     bastion_host        = azurerm_linux_virtual_machine.bastion-vm.public_ip_address
#     bastion_private_key = file("~/.ssh/id_rsa")
#   }

#   #yaml 파일 복사
#   provisioner "file" {
#     source      = "wp"
#     destination = "wp"
#   }

#   #ansible 설치 및 playbook 실행
#   provisioner "remote-exec" {
#     inline = [
#       #ansible 패키지설치
#       "sudo yum install centos-release-ansible-29 -y",
#       #ansible 설치
#       "sudo yum install ansible -y",
#       #RDS 엔트포인트 수정
#       "sed -i 's/rdsendpoint/${var.db-server}.mariadb.database.azure.com/g' /home/adminuser/wp/roles/wordpress/vars/main.yaml",
#       #playbook 실행s
#       "ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 /home/adminuser/wp/wordpress.yaml -b",
#       #SeLinux 끄기
#       "sudo setenforce 0"
#     ]
#   }

# }

