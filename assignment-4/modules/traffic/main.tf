resource "azurerm_traffic_manager_profile" "main" {
  name                = var.az_rg_name
  resource_group_name = var.az_rg_name

  traffic_routing_method = "Performance"

  dns_config {
    relative_name = var.az_rg_name
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = {
    env = "production"
  }
}

output "az_trf_man_profile" {
    value = azurerm_traffic_manager_profile.main
}
