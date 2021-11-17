resource "azurerm_resource_group" "main" {
  name = "${var.resource_group_name}-${var.resource_group_location}"
  location = var.resource_group_location
}


output "az_rg" {
  value = azurerm_resource_group.main
}
