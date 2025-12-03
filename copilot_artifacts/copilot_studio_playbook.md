# Copilot Studio Import & Test Playbook — ReturnBot

This playbook walks you through importing the prompt templates, registering the mock OpenAPI tool, uploading grounding sources, wiring the `GenerateLabel` action, and running two canonical tests (eligible / ineligible). Use these clipboard-ready snippets inside Copilot Studio or adapt them to Azure AI Foundry.

Prerequisites
--------------
- A Copilot Studio workspace and permission to register tools/actions.
- Local repo checked out with the files in `data/grounding/` and `copilot_artifacts/`.
- Python 3.10+ and dependencies installed if you want to run the mock service locally (see `requirements.txt`).

Files referenced (repo paths)
-----------------------------
- `data/grounding/sample_orders.csv` — mock orders
- `data/grounding/product_catalog.csv` — SKU metadata
- `data/grounding/customers.csv` — customer metadata
- `data/grounding/return_policy.md` — policy + decision rubric
- `data/grounding/mock_label_api_openapi.json` — OpenAPI spec for the label tool
- `data/grounding/tools/mock_label_service.py` — simple Flask mock label service (for local testing)
- `copilot_artifacts/prompts.md` — system + intake prompt templates
- `copilot_artifacts/action_mappings.md` — notes on wiring `GenerateLabel`

High-level workflow
-------------------
1. Register the LabelService OpenAPI tool in Copilot Studio using `mock_label_api_openapi.json`.
2. Upload file knowledge sources (`return_policy.md`) and table sources (CSV files) as grounding sources.
3. Create the `GenerateLabel` action by exposing the `generateLabel` operation from the OpenAPI tool.
4. Add the system prompt and intake templates (copy from `copilot_artifacts/prompts.md`) into your agent's System and Intake configuration.
5. Configure action routing and retry/backoff per `copilot_artifacts/action_mappings.md`.
6. Test with two canonical cases in the Copilot sandbox.

Detailed steps
--------------

Step 1 — Register the OpenAPI tool
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. In Copilot Studio, open Tools > Add > Import OpenAPI (or similar).
2. Upload `data/grounding/mock_label_api_openapi.json`.
3. Set the tool name to `LabelService`.
4. Confirm the operation ID for POST /generateLabel is `generateLabel`. Expose that operation.
5. For the base URL, enter the hosted mock service URL (if you deployed it), or `http://127.0.0.1:5000` for local testing.

Step 2 — Upload grounding sources
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Files to upload:
- `return_policy.md` — add as a file-based knowledge source.
- `sample_orders.csv`, `product_catalog.csv`, `customers.csv` — upload as tabular grounding sources. If Studio supports indexing CSVs as structured data, use that option.

Indexing notes
- If Copilot Studio supports embeddings or vector indexing for file content, create a small index for `return_policy.md` (helps retrieval for ambiguous policy questions).
- For the CSVs, prefer structured ingestion (field-preserving) rather than plain text ingestion so the agent can query order rows directly.

Step 3 — Create the `GenerateLabel` action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. In the tool registry, map the OpenAPI operation `generateLabel` to the action name `GenerateLabel`.
2. Define the input schema as: { "order_id": string, "sku": string, "label_type": string }.
3. Map output fields `label_id` and `label_url` so the Studio can pass them back into the LLM context.
4. Configure error handling: retry up to 2 times on 5xx or network errors, with exponential backoff (e.g., 200ms -> 800ms), and escalate to human/manual review if repeated failures.

Step 4 — Paste the System instruction & Intake prompt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Open `copilot_artifacts/prompts.md` and copy/paste the System instruction into Copilot Studio's System prompt slot. Copy the Intake prompt template into the user prompt template section.

System instruction (clipboard-ready excerpt)
-------------------------------------------
You are ReturnBot, an assistant that decides return eligibility and issues prepaid labels when rules are met.

Required behavior:
- Always ask for order number, SKU, purchase date, customer email, reason for return, and optional photos when information is missing.
- If the order cannot be validated against the order data source, ask for clarification and do not call the label API.
- Apply the decision rubric from `return_policy.md`.
- If eligible, call the LabelService `GenerateLabel` action with {order_id, sku, label_type: "prepaid"} and record the returned label_id and label_url.
- If ineligible, return a templated denial with the reason and next-steps.
- For `frequent_returner = true` customers, add the tag "manual_review" and route to human fallback.

Intake prompt (clipboard-ready excerpt)
--------------------------------------
Customer submitted return: order #{order_id}, SKU {sku}, date {purchase_date}, reason {reason}. Photos: {photo_urls}

Instruction to the LLM:
1) Validate the order and SKU using the Orders knowledge source. If missing, ask for the missing field.
2) Apply the decision rubric. Output exactly one of the following formats:
   - ELIGIBLE — generate label
   - INELIGIBLE — {brief_reason} — {next_steps}
   - MANUAL_REVIEW — {brief_reason}
3) If ELIGIBLE, call the Copilot action `GenerateLabel` and then send the email template with the returned `{label_url}`.

Step 5 — Action routing, logging, and fallback
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Configure action logs to include request/response when the label API is called. Store `label_id` and `label_url` in the conversation metadata for audit.
- If customer has `frequent_returner=true`, automatically tag the case `manual_review` and escalate to a human.
- If API returns HTTP 4xx, return a concise user-facing error with human escalation steps.

Step 6 — Local testing (run the mock service)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
From the repo root, install dependencies and run the mock label service locally. Use PowerShell for commands below.

Install dependencies
```pwsh
python -m pip install -r .\requirements.txt
```

Start the mock service
```pwsh
python .\data\grounding\tools\mock_label_service.py
# Service will run on http://127.0.0.1:5000 by default
```

Quick curl-like test (PowerShell):
```pwsh
$body = @{ order_id = 'ORD-001'; sku = 'SKU-ABC'; label_type = 'prepaid' } | ConvertTo-Json
Invoke-RestMethod -Uri 'http://127.0.0.1:5000/generateLabel' -Method Post -ContentType 'application/json' -Body $body
```

You should receive a JSON response: { "label_id": "LBL-...", "label_url": "https://..." }

Step 7 — Copilot sandbox tests (two canonical cases)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Test case A — Eligible (happy path)
- Input:
  - order_id: ORD-001 (exists in `sample_orders.csv`)
  - sku: SKU-ABC (not final_sale)
  - purchase_date: <within 30 days>
  - reason: "Item arrived damaged"
  - photos: include a photo URL

Expected flow:
1. Agent validates order and SKU.
2. Applies rubric -> ELIGIBLE.
3. Calls `GenerateLabel` action. Receives `label_url`.
4. Replies to user with label link and next steps. Stores metadata.

Test case B — Ineligible (final sale)
- Input:
  - order_id: ORD-010
  - sku: SKU-FINAL (catalog has `final_sale = true`)
  - purchase_date: within typical window
  - reason: "Changed my mind"

Expected flow:
1. Agent validates order and SKU.
2. Applies rubric -> INELIGIBLE because SKU is final sale.
3. Agent returns templated denial with brief reason and next steps (appeal contact info).

Tips for debugging
------------------
- If the agent keeps calling `GenerateLabel` for ineligible cases, verify the decision rubric text in `return_policy.md` matches what you pasted into the System prompt (copy/paste consistency).
- If the OpenAPI tool fails in Studio but works locally, check base URL and CORS/network settings for the hosted mock service. For local testing, Studio must be able to reach your local host (consider ngrok or a hosted dev endpoint if Studio can't reach localhost).

Appendix — Example user messages for sandbox testing
--------------------------------------------------
Eligible example (copy into Sandbox):

{
  "order_id": "ORD-001",
  "sku": "SKU-ABC",
  "purchase_date": "2025-11-05",
  "reason": "Item arrived with a broken screen",
  "photo_urls": ["https://example.com/photo1.jpg"]
}

Ineligible example (final sale):

{
  "order_id": "ORD-010",
  "sku": "SKU-FINAL",
  "purchase_date": "2025-10-05",
  "reason": "Changed my mind",
  "photo_urls": []
}

What I added to the repo
------------------------
- `copilot_artifacts/copilot_studio_playbook.md` — this playbook file (you are reading it now).

Next recommended steps
----------------------
1. Import the OpenAPI tool into Copilot Studio and create `GenerateLabel` action.
2. Upload `return_policy.md` and CSVs as grounding sources.
3. Paste the System and Intake prompts from `copilot_artifacts/prompts.md` into the agent configuration.
4. Run the mock service locally and validate the `GenerateLabel` action via a curl/Invoke-RestMethod test.
5. Run the two canonical tests in the Copilot sandbox and iterate on prompt wording if decisions deviate.

If you want, I can next create the sample action YAML and a small Python test harness that calls the OpenAPI operation directly (option 1 from the earlier list). Say "create action YAML" and I will add it and run the local tests.
