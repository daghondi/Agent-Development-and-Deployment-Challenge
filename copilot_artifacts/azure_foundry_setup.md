**Azure AI Foundry Setup Playbook**

Purpose: provide a clear set of prerequisites and instructions to create an Azure AI Foundry workspace for the ReturnBot project, and a PowerShell script to provision the required supporting resources.

Overview
- We'll provision the prerequisite resources (Resource Group, Storage Account, Key Vault, Cognitive Search, Log Analytics, Application Insights). Then you'll create the Azure AI Foundry workspace in the Azure Portal and connect these resources.
- I include a `azure_prereqs.ps1` script that creates the prerequisites. Creating the Foundry workspace is done in the portal (recommended) because the resource provider name and properties may vary by subscription/preview availability.

Before you run anything
- Ensure you have `az` CLI installed and you're logged in: `az login`.
- You must have permission to create resources in the subscription (Contributor or Owner role).
- Choose a subscription and region (example uses `eastus`).

Run the prerequisite provisioning script (PowerShell)
-----------------------------------------------
From the repo root run:

```pwsh
cd .\copilot_artifacts
pwsh .\azure_prereqs.ps1 -ResourceGroup rg-returnbot-dev -Location eastus -Prefix returnbot
```

What the script creates
- Resource Group: `rg-returnbot-dev`
- Storage Account: `<prefix>store<random>` (for grounding & artifact upload)
- Key Vault: `<prefix>-kv` (to hold secrets like OpenAI key)
- Log Analytics workspace & Application Insights (for monitoring)
- Cognitive Search service: `<prefix>-search` (for indexing `return_policy.md` and optionally CSVs)

Notes about Azure AI Foundry workspace creation
- Azure AI Foundry (sometimes in preview) may require registration of the resource provider. If you don't see Foundry in the portal, ask your subscription admin to register `Microsoft.AI` or `Microsoft.Foundry` as needed.
- Portal steps (preferred):
  1. Open the Azure Portal and go to Create a resource -> search for "Azure AI Foundry" (or "Foundry").
  2. Choose a name (e.g., `returnbot-foundry`) and select the same Resource Group `rg-returnbot-dev` and region `eastus`.
  3. On the configuration screen, when asked for storage, choose the storage account the script created.
  4. For secrets / keys, select the Key Vault created.
  5. For logging/monitoring, point to the Log Analytics workspace / Application Insights the script created.
  6. For model runtime, choose the Azure OpenAI resource if available (or skip and use an external model endpoint later). Save and create.

After creation
- In the Foundry workspace, open Settings / Connections and bind the Storage Account and Key Vault. Upload `data/grounding/*` into the storage container or configure ingestion from the storage container.
- Create or register a tool that calls the LabelService (use the ngrok URL during dev or the ACI URL when deployed). Use the OpenAPI spec `data/grounding/mock_label_api_openapi.json` to register the tool.

Validation steps
- From the Azure Portal, confirm the Foundry workspace status is `Succeeded` and that the storage and key vault connections are listed.
- Try a simple test: create a new notebook or prompt in Foundry that calls a model and confirm you can execute a model request.

If the Foundry resource is not available via Portal
- If your subscription doesn't show Foundry as a resource, follow one of these options:
  - Ask your subscription admin to register the required resource provider(s).
  - Use Azure AI Studio + Copilot Studio variant: create Cognitive Services / Azure OpenAI and then use Foundry-like orchestration via Logic Apps and Function apps.

Next steps I can do for you
- Run a pass that generates an ARM/Bicep template for the Foundry workspace once you confirm the exact Foundry resource type your tenant exposes.
- Create a small script to register the mock label OpenAPI tool inside Foundry (requires Foundry REST API access or portal manual steps).
