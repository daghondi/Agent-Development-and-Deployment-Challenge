<#
Build and push Docker image for the mock label service.

Usage:
  1. Open PowerShell in the folder `data/grounding/tools/` or run from repo root.
  2. Set environment variables or provide parameters when prompted.
     - DOCKERHUB_USER (required if pushing to Docker Hub)
     - IMAGE_NAME (default: returnbot-mock)
     - TAG (default: latest)
  3. The script will run `docker build`, `docker login` (interactive), and `docker push`.

Notes:
 - If you prefer Azure Container Registry (ACR), build and push to ACR instead (see comments).
#>

param(
    [string]$DockerHubUser = $env:DOCKERHUB_USER,
    [string]$ImageName = "returnbot-mock",
    [string]$Tag = "latest"
)

if (-not $DockerHubUser) {
    $DockerHubUser = Read-Host "Enter Docker Hub username (or press Enter to use local image only)"
}

$fullImage = if ($DockerHubUser) { "$DockerHubUser/$ImageName:$Tag" } else { "$ImageName:$Tag" }

Write-Host "Building Docker image $fullImage..."
docker build -t $fullImage -f .\Dockerfile ..\..

if ($DockerHubUser) {
    Write-Host "Logging into Docker Hub (interactive)..."
    docker login
    Write-Host "Pushing $fullImage to Docker Hub..."
    docker push $fullImage
} else {
    Write-Host "Docker Hub username not provided — image built locally as $fullImage. You can push manually later."
}

Write-Host "Done. Image: $fullImage"

# ACR notes (optional):
# To push to ACR, create ACR and run:
# az acr login --name <acrName>
# docker tag $fullImage <acrName>.azurecr.io/$ImageName:$Tag
# docker push <acrName>.azurecr.io/$ImageName:$Tag
