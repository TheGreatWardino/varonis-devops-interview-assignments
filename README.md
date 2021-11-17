# varonis-devops-interview-assignments

## Assignment 1:

- Components required:
    - Using `PowerShell 5.1`
    - Run `Install-Module -Name AzureAD`
    - Run `Install-Module -Name AzureADPreview -AllowClobber`
    - When using the `Connect-AzureAD` cmdlet, pass the `-TenantId` flag. Find your `TenantId` by going to: https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview

---

## Assignment 2:

### Testing URLs:
- https://varonis-assignment-2.azurewebsites.net/api/varonis-assignment-2/?name=VaronisAssignmentKv1
- https://varonis-assignment-2.azurewebsites.net/api/varonis-assignment-2/?name=VaronisAssignmentKv2
- https://varonis-assignment-2.azurewebsites.net/api/varonis-assignment-2/?name=VaronisAssignmentKv3

- Components required:
    - Install `Azure Functions Core Tools` from https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=v4%2Cwindows%2Ccsharp%2Cportal%2Cbash%2Ckeda#install-the-azure-functions-core-tools
    - Install `Python for Windows` from https://www.python.org/downloads/
- Additional Steps:
    - Enable Function App system identity:
        - Azure portal > Function app > Settings > Identity > On
    - Add secrets to the vault:
        - Azure portal > Key Vault > VaronisAssignmentKv1-3 > Access policies > `+ Add Access Policy` > Configure from template: `Secret Management` > Principal > `varonis-assignment-2` > Save
    - Add vault secrets to app configuration:
        - Azure portal > Key Vault > `VaronisAssignmentKv$num` > Secrets > `VaronisAssignmentSecret` > Current version > Secret identifier (copy these values to a temporary file)
        - Azure portal > Function app > Settings > Configuration
            - `+ New application setting` > Name: `VaronisAssignmentKv$num` > Value: `@Microsoft.KeyVault(SecretUri=<secret-identifier-value-from-VaronisAssignmentKv$num)` > Save

---

## Assignment 3:

### Separate Github repos:
- Application Code repo for Assignment 3: https://github.com/TheGreatWardino/varonis-devops-interview-assignment-3-app
- YAML File(s) repo for Assignment 3: https://github.com/TheGreatWardino/varonis-devops-interview-assignment-3-yaml

---

## Assignment 4:
- Terraform Modules:
    - `resource_group_eastus`
        - `source`= references a common module; this will create our location-specific `resource_group`
        - `resource_group_name`= assigns the value from `terraform.auto.tfvars` as this variable
        - `resource_group_location` = declares the location to use for this resource group (`eastus`)
    - `network_eastus`
        - `source`= references a common module; this will create our location-specific `network` infrastructure
        - `az_rg_name` = name of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_eastus`
        - `az_rg_location` = location of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_eastus`
        - `az_trf_man_profile` = name of the Azurerm Traffic Manager profile; this is referencing the output generated in `module:traffic`
    - `vm_eastus`
        - `source`= references a common module; this will create our location-specific `vm` infrastructure
        - `az_ni` = network interface(s) value of network_eastus; this is referencing the output generated in module:network_eastus
        - `az_rg_name` = name of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_eastus`
        - `az_rg_location` = location of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_eastus`
    - `resource_group_northeurope`
        - `source`= references a common module; this will create our location-specific `resource_group`
        - `resource_group_name`= assigns the value from `terraform.auto.tfvars` as this variable
        - `resource_group_location` = declares the location to use for this resource group (`northeurope`)
    - `network_northeurope`
        - `source`= references a common module; this will create our location-specific `network` infrastructure
        - `az_rg_name` = name of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_northeurope`
        - `az_rg_location` = location of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_northeurope`
        - `az_trf_man_profile` = name of the Azurerm Traffic Manager profile; this is referencing the output generated in `module:traffic`
    - `vm_northeurope`
        - `source`= references a common module; this will create our location-specific `vm` infrastructure
        - `az_ni` = network interface(s) value of network_northeurope; this is referencing the output generated in module:network_northeurope
        - `az_rg_name` = name of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_northeurope`
        - `az_rg_location` = location of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_northeurope`
    - `traffic`
        - `source`= references a common module; this will create our location-specific `traffic` infrastructure; note that we will still have both location-specific traffic endpoints generated by location-specific `network` infrastructure attached to our `traffic` infrastructure
        - `az_rg_name` = name of the Azurerm Resource Group; this is referencing the output generated in `module:resource_group_eastus`

- Azure Infrastructure:
    - `eastus`:
        - `resource-group`: varonis-assignment-4-eastus
        - `availability-set`: varonis-assignment-4-eastus
            - `virtual-machines`:
                - varonis-assignment-4-eastus-vm-0
                - varonis-assignment-4-eastus-vm-1
        - `load-balancer`: varonis-assignment-4-eastus
			- `load-balancer-rule`: varonis-assignment-4-eastus
			- `load-balancer-probe`: varonis-assignment-4-eastus
            - `backend-pools`: varonis-assignment-4-eastus
                - `virtual-machines`:
                    - varonis-assignment-4-eastus-vm-0
                    - varonis-assignment-4-eastus-vm-1
            - `public-ip-address`: varonis-assignment-4-eastus
        - `traffic-manager-profile`: varonis-assignment-4-eastus
            - `traffic_routing_method`: `Performance` - traffic is routed via the User's closest Endpoint (https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/traffic_manager_profile#Performance)
            - `traffic-manager-endpoints`:
                - varonis-assignment-4-eastus
                - varonis-assignment-4-northeurope
        - `virtual-network`: varonis-assignment-4-eastus
            - `network-interfaces`:
                - varonis-assignment-4-eastus-ni-0
                - varonis-assignment-4-eastus-ni-1
        - `virtual-machines`:
            - varonis-assignment-4-eastus-vm-0
                - `os-disk`: varonis-assignment-4-eastus-osdisk-0
                - `data-disk`: varonis-assignment-4-eastus-datadisk-0
                - `data-disk`: varonis-assignment-4-eastus-managed_datadisk-0
    - `northeurope`:
        - `resource-group`: varonis-assignment-4-northeurope
        - `availability-set`: varonis-assignment-4-northeurope
            - `virtual-machines`:
                - varonis-assignment-4-northeurope-vm-0
                - varonis-assignment-4-northeurope-vm-1
        - `load-balancer`: varonis-assignment-4-northeurope
			- `load-balancer-rule`: varonis-assignment-4-northeurope
			- `load-balancer-probe`: varonis-assignment-4-northeurope
            - `backend-pools`: varonis-assignment-4-northeurope
                - `virtual-machines`:
                    - varonis-assignment-4-northeurope-vm-0
                    - varonis-assignment-4-northeurope-vm-1
            - `public-ip-address`: varonis-assignment-4-northeurope
        - `virtual-network`: varonis-assignment-4-northeurope
            - `network-interfaces`:
                - varonis-assignment-4-northeurope-ni-0
                - varonis-assignment-4-northeurope-ni-1
        - `virtual-machines`:
            - varonis-assignment-4-northeurope-vm-0
                - `os-disk`: varonis-assignment-4-northeurope-osdisk-0
                - `data-disk`: varonis-assignment-4-northeurope-datadisk-0
                - `data-disk`: varonis-assignment-4-northeurope-managed_datadisk-0