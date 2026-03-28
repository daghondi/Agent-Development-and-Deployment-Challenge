<#
Provision common prerequisite Azure resources for the ReturnBot project.

This script creates:
 - Resource Group
 - Storage Account (for grounding files)
 - Key Vault
 - Log Analytics Workspace
 - Application Insights
 - Cognitive Search service (basic)

Usage:
  pwsh .\azure_prereqs.ps1 -ResourceGroup rg-returnbot-dev -Location eastus -Prefix returnbot

Prereqs:
 - az CLI installed and `az login` run
 - You have rights to create resources in the subscription
#>

param(
    [string]$ResourceGroup = "rg-returnbot-dev",
    [string]$Location = "eastus",
    [string]$Prefix = "returnbot"
)

Write-Host "Creating resource group: $ResourceGroup in $Location"
az group create --name $ResourceGroup --location $Location | Out-Null

# Storage account
$saName = ("$Prefix" + "store" + (Get-Random -Minimum 1000 -Maximum 9999)).ToLower()
Write-Host "Creating storage account: $saName"
az storage account create --name $saName --resource-group $ResourceGroup --location $Location --sku Standard_LRS --kind StorageV2 | Out-Null

# Create a container for grounding
Write-Host "Creating blob container 'grounding'"
$key = az storage account keys list --resource-group $ResourceGroup --account-name $saName --query "[0].value" -o tsv
az storage container create --name grounding --account-name $saName --account-key $key --public-access off | Out-Null

# Key Vault
$kvName = "$Prefix-kv"
Write-Host "Creating Key Vault: $kvName"
az keyvault create --name $kvName --resource-group $ResourceGroup --location $Location | Out-Null

# Log Analytics
$lawName = "$Prefix-law"
Write-Host "Creating Log Analytics workspace: $lawName"
az monitor log-analytics workspace create --resource-group $ResourceGroup --workspace-name $lawName --location $Location | Out-Null

# Application Insights
$aiName = "$Prefix-ai"
Write-Host "Creating Application Insights: $aiName"
az monitor app-insights component create --app $aiName --location $Location --resource-group $ResourceGroup --kind web --workspace $(az monitor log-analytics workspace show --resource-group $ResourceGroup --workspace-name $lawName --query id -o tsv) | Out-Null

# Cognitive Search
$searchName = "$Prefix-search"
Write-Host "Creating Cognitive Search (Basic) service: $searchName"
az search service create --name $searchName --resource-group $ResourceGroup --sku basic --location $Location | Out-Null

Write-Host "Done. Created resources: `n  ResourceGroup: $ResourceGroup`n  StorageAccount: $saName`n  KeyVault: $kvName`n  LogAnalytics: $lawName`n  AppInsights: $aiName`n  CognitiveSearch: $searchName"

Write-Host "
Next: upload grounding files to the storage account's grounding container and then create the Azure AI Foundry workspace via the Portal (see copilot_artifacts/azure_foundry_setup.md)"
