NGROK Quickstart — Expose the mock label service

Overview
--------
This guide shows how to run the local mock label service and expose it to the internet using `ngrok`. Copilot Studio or Azure AI Foundry can call the public ngrok URL during development to exercise the `GenerateLabel` action.

Prerequisites
-------------
- Python 3.10+ installed and on PATH
- `ngrok` installed and authenticated (https://ngrok.com/) if you want a stable URL
- From repo root: `requirements.txt` is present

Start the mock service and ngrok (PowerShell)
-----------------------------------------
1) Open PowerShell in the repo root.
2) Run the helper script (this will create a venv and start the mock service):

```pwsh
.\data\grounding\tools\run_with_ngrok.ps1
```

3) In a separate terminal, start ngrok to expose port 5002:

```pwsh
ngrok http 5002
```

4) Copy the HTTPS Forwarding URL shown by ngrok (for example `https://abcd-1234.ngrok.io`).
5) Test the endpoint with PowerShell:

```pwsh
$body = @{ order_id='ORD-001'; sku='SKU-ABC'; label_type='prepaid' } | ConvertTo-Json
Invoke-RestMethod -Uri 'https://abcd-1234.ngrok.io/generateLabel' -Method Post -ContentType 'application/json' -Body $body
```

Use the resulting URL in Copilot Studio or Azure Foundry as the base URL for the `LabelService` tool (e.g., `https://abcd-1234.ngrok.io`).

Notes
-----
- Free ngrok accounts produce ephemeral URLs that change each time you start ngrok. If you need a fixed URL, sign up and reserve a subdomain using ngrok's paid features.
- Keep the PowerShell session running while Foundry calls the endpoint.
