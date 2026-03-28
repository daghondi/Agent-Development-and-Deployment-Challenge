<#
Deploy the container image to Azure Container Instances (ACI).

Usage:
  Set variables below or pass them as parameters.

This script assumes you have:
 - run `az login` and have access to the target subscription
 - pushed the image to a registry reachable from Azure (Docker Hub or ACR)
#>

param(
    [string]$ResourceGroup = "rg-returnbot-dev",
    [string]$AciName = "returnbot-mock-aci",
    [string]$Image = $(throw "Please provide the full image name, e.g. youruser/returnbot-mock:latest"),
    [int]$Port = 5002
)

Write-Host "Deploying ACI $AciName in resource group $ResourceGroup using image $Image"

$dnsLabel = ("returnbot-mock-" + (Get-Random -Minimum 1000 -Maximum 9999)).ToLower()

az container create --resource-group $ResourceGroup --name $AciName --image $Image --cpu 1 --memory 1.5 --ports $Port --dns-name-label $dnsLabel --query "{Fqdn:ipAddress.fqdn,State:instanceView.state}"

Write-Host "To validate, run:"
Write-Host "  az container show --resource-group $ResourceGroup --name $AciName --query \"{Fqdn:ipAddress.fqdn,State:instanceView.state}\" -o table"
Write-Host "Then test the endpoint (PowerShell):"
Write-Host "  Invoke-RestMethod -Uri 'http://<FQDN>:$Port/generateLabel' -Method Post -ContentType 'application/json' -Body (@{order_id='ORD-001';sku='SKU-ABC';label_type='prepaid'} | ConvertTo-Json)"
