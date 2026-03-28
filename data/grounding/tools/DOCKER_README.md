Docker + ACI deployment guide for mock_label_service

Files added
- `Dockerfile` — container specification for `mock_label_service.py` (exposes port 5002)
- `build_and_push_image.ps1` — PowerShell helper to build and push the image to Docker Hub (interactive login)
- `deploy_to_aci.ps1` — PowerShell helper to deploy the pushed image to Azure Container Instances

Quick start (PowerShell)
-------------------------
1) Build and push the image (from repo root):

```pwsh
# from repo root
cd .\data\grounding\tools
.\build_and_push_image.ps1

# when prompted, enter Docker Hub username (or press Enter to only build locally)
```

2) Deploy to ACI (after image is pushed to Docker Hub or ACR). Example using Docker Hub image `youruser/returnbot-mock:latest`:

```pwsh
.\deploy_to_aci.ps1 -ResourceGroup rg-returnbot-dev -AciName returnbot-mock-aci -Image youruser/returnbot-mock:latest -Port 5002
```

3) Verify the ACI is running and get the FQDN:

```pwsh
az container show --resource-group rg-returnbot-dev --name returnbot-mock-aci --query "{Fqdn:ipAddress.fqdn,State:instanceView.state}" -o table
```

4) Test the endpoint (PowerShell example):

```pwsh
$body = @{ order_id='ORD-001'; sku='SKU-ABC'; label_type='prepaid' } | ConvertTo-Json
Invoke-RestMethod -Uri 'http://<FQDN>:5002/generateLabel' -Method Post -ContentType 'application/json' -Body $body
```

Notes & alternatives
- If you prefer Azure Container Registry (ACR) instead of Docker Hub:
  - Create an ACR: `az acr create --resource-group rg-returnbot-dev --name myacr --sku Basic`
  - Login to ACR: `az acr login --name myacr`
  - Tag & push: `docker tag youruser/returnbot-mock:latest myacr.azurecr.io/returnbot-mock:latest` and `docker push myacr.azurecr.io/returnbot-mock:latest`
  - Deploy to ACI using the ACR image; ACI can pull from ACR without Docker Hub.

Security
- Avoid publishing secrets in images. Use Key Vault or ACI environment variables for secrets.
