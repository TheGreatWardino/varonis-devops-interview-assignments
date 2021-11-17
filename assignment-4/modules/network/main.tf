resource "azurerm_virtual_network" "main" {
  name                = var.az_rg_name
  resource_group_name = var.az_rg_name
  location            = var.az_rg_location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = var.az_rg_name
  resource_group_name  = var.az_rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "address" {
  name                = var.az_rg_name
  location            = var.az_rg_location
  resource_group_name = var.az_rg_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "load_balancer" {
  name                = var.az_rg_name
  location            = var.az_rg_location
  resource_group_name = var.az_rg_name

  frontend_ip_configuration {
    name                 = var.az_rg_name
    public_ip_address_id = azurerm_public_ip.address.id
  }
}

 resource "azurerm_lb_backend_address_pool" "lb_backend" {
   loadbalancer_id     = azurerm_lb.load_balancer.id
   name                = var.az_rg_name
 }

resource "azurerm_network_interface" "main" {
  count               = 2
  name                = "${var.az_rg_name}-ni-${count.index}"
  location            = var.az_rg_location
  resource_group_name = var.az_rg_name

  ip_configuration {
    name                          = var.az_rg_name
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "ni_backend_addr_pool_association" {
  count               = 2
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
  ip_configuration_name   = var.az_rg_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id
}

output "az_ni" {
  value = azurerm_network_interface.main
}
