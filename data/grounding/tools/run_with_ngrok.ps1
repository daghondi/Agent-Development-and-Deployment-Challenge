<#
Run the mock label service locally and expose it via ngrok.

Usage (PowerShell):
  1. Open a PowerShell window in the repo root.
  2. Run this script: `.\\<path>\data\grounding\tools\run_with_ngrok.ps1`

This script will:
 - Create a venv (if not present)
 - Install `requirements.txt` into the venv
 - Launch the mock label service on port 5002
 - Print instructions to start ngrok (you must have ngrok installed)

Notes:
 - The mock service listens on port 5002 by default (see `mock_label_service.py`).
 - Keep this terminal open while testing. Use ngrok to obtain a public URL for Copilot Studio / Foundry.
#>

Set-StrictMode -Version Latest

$repoRoot = Resolve-Path "..\..\.."
Push-Location $repoRoot

if (-not (Test-Path -Path .venv)) {
    Write-Host "Creating virtual environment .venv..."
    python -m venv .venv
}

Write-Host "Activating virtual environment and installing dependencies..."
& .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r .\requirements.txt

Write-Host "Starting mock label service (background)..."
$svc = Start-Process -FilePath python -ArgumentList 'data\grounding\tools\mock_label_service.py' -NoNewWindow -PassThru
Start-Sleep -Seconds 1

if ($svc -and !$svc.HasExited) {
    Write-Host "Mock service started (PID=$($svc.Id)). Listening on http://0.0.0.0:5002"
} else {
    Write-Host "Failed to start mock service. Check output above." -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "Next: start ngrok in a separate terminal to expose port 5002:" -ForegroundColor Green
Write-Host "  ngrok http 5002" -ForegroundColor Yellow
Write-Host "After ngrok starts, copy the HTTPS forwarding URL (https://xxxx.ngrok.io) and use {that_url}/generateLabel as your endpoint in Copilot Studio or Azure Foundry." -ForegroundColor Green
Write-Host "Test the endpoint locally (PowerShell example):" -ForegroundColor Cyan
Write-Host "  $body = @{ order_id='ORD-001'; sku='SKU-ABC'; label_type='prepaid' } | ConvertTo-Json" -ForegroundColor Yellow
Write-Host "  Invoke-RestMethod -Uri 'https://<ngrok-host>/generateLabel' -Method Post -ContentType 'application/json' -Body $body" -ForegroundColor Yellow

Write-Host "When finished, stop the mock service by PID or closing this terminal." -ForegroundColor Gray
Pop-Location
