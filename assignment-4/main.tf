terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "c8cc589f-47cc-49a4-929e-6dd729ef4dd2"
  tenant_id = "a00bd783-ae68-4960-b694-bf4b59a40f10"
}

module "resource_group_eastus" {
  source = "./modules/resource_group"

  resource_group_name = "varonis-assignment-4"
  resource_group_location = "eastus"
  
}

module "network_eastus" {
  source = "./modules/network"

  az_rg_name = module.resource_group_eastus.az_rg.name
  az_rg_location = module.resource_group_eastus.az_rg.location
}

module "vm_eastus" {
  source = "./modules/vm"

  az_ni = module.network_eastus.az_ni
  az_rg_name = module.resource_group_eastus.az_rg.name
  az_rg_location = module.resource_group_eastus.az_rg.location

}

module "resource_group_northeurope" {
  source = "./modules/resource_group"

  resource_group_name = "varonis-assignment-4"
  resource_group_location = "northeurope"
  
}

module "network_northeurope" {
  source = "./modules/network"

  az_rg_name = module.resource_group_northeurope.az_rg.name
  az_rg_location = module.resource_group_northeurope.az_rg.location
}

module "vm_northeurope" {
  source = "./modules/vm"

  az_ni = module.network_northeurope.az_ni
  az_rg_name = module.resource_group_northeurope.az_rg.name
  az_rg_location = module.resource_group_northeurope.az_rg.location

}
