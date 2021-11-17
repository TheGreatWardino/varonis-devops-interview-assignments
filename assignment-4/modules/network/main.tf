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

 resource "azurerm_managed_disk" "disk" {
   count                = 2
   name                 = "${var.az_rg_name}-managed_datadisk-${count.index}"
   location             = var.az_rg_location
   resource_group_name  = var.az_rg_name
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "1023"
 }

  resource "azurerm_availability_set" "avset" {
   name                         = "avset"
   location                     = var.az_rg_location
   resource_group_name          = var.az_rg_name
   platform_fault_domain_count  = 2
   platform_update_domain_count = 2
   managed                      = true
 }

 resource "azurerm_virtual_machine" "vm" {
   count                 = 2
   name                  = "${var.az_rg_name}-vm-${count.index}"
   location              = var.az_rg_location
   availability_set_id   = azurerm_availability_set.avset.id
   resource_group_name   = var.az_rg_name
   network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
   vm_size               = "Standard_DS1_v2"

   # Uncomment this line to delete the OS disk automatically when deleting the VM
   # delete_os_disk_on_termination = true

   # Uncomment this line to delete the data disks automatically when deleting the VM
   # delete_data_disks_on_termination = true

   storage_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "16.04-LTS"
     version   = "latest"
   }

   storage_os_disk {
     name              = "${var.az_rg_name}-osdisk-${count.index}"
     caching           = "ReadWrite"
     create_option     = "FromImage"
     managed_disk_type = "Standard_LRS"
   }

   # Optional data disks
   storage_data_disk {
     name              = "${var.az_rg_name}-datadisk-${count.index}"
     managed_disk_type = "Standard_LRS"
     create_option     = "Empty"
     lun               = 0
     disk_size_gb      = "1023"
   }

   storage_data_disk {
     name            = element(azurerm_managed_disk.disk.*.name, count.index)
     managed_disk_id = element(azurerm_managed_disk.disk.*.id, count.index)
     create_option   = "Attach"
     lun             = 1
     disk_size_gb    = element(azurerm_managed_disk.disk.*.disk_size_gb, count.index)
   }

   os_profile {
     computer_name  = "${var.az_rg_name}-hostname-${count.index}"
     admin_username = "localadmin"
     admin_password = "Abc_1234!"
   }

   os_profile_linux_config {
     disable_password_authentication = false
   }

   tags = {
     environment = "production"
   }
 }