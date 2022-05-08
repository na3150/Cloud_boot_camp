# data
data "azurerm_resource_group" "image" {
  name       = "myimg"
  depends_on = [azurerm_resource_group.wp-rg] # 의존성
}

data "azurerm_image" "image" {
  name                = "wp-centos"                            # Packer로 생성된 이미지 이름
  resource_group_name = data.azurerm_resource_group.image.name # 이미지가 존재하는 리소스 그룹의 이름
  depends_on          = [azurerm_resource_group.wp-rg]         # 의존성
}