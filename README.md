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

