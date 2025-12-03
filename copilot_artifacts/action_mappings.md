Action mapping and integration notes for Copilot Studio

Overview
--------
This document explains how the `GenerateLabel` Copilot action should be wired to the mock OpenAPI spec contained at `data/grounding/mock_label_api_openapi.json` and how to test it locally against `data/grounding/tools/mock_label_service.py`.

Action: GenerateLabel
---------------------
- Purpose: Request a prepaid shipping label for a return when the agent decides the return is eligible.
- Input (JSON): { "order_id": string, "sku": string, "label_type": string }
- Expected behavior: POST the input to the OpenAPI `POST /generateLabel` endpoint. On success the API returns { "label_id": string, "label_url": string }.
- Failure modes: HTTP 4xx -> validation/authorization problems; HTTP 5xx or network error -> retry up to 2 times with exponential backoff then escalate to human.
- Timeout: 5 seconds default before retry/backoff.

OpenAPI integration
-------------------
Use the provided OpenAPI document `data/grounding/mock_label_api_openapi.json` as the tool specification in Copilot Studio or your tool registry. Ensure the operationId is `generateLabel` and the request accepts an application/json body with fields `order_id`, `sku`, and `label_type`.

Testing locally
---------------
1. Install dependencies: `pip install -r requirements.txt` (from repo root).
2. Start the mock service:
   - `python data/grounding/tools/mock_label_service.py` (runs on http://127.0.0.1:5000 by default)
3. Example request (curl / Python): POST http://127.0.0.1:5000/generateLabel with JSON body {"order_id":"ORD-123","sku":"SKU-ABC","label_type":"prepaid"}

Copilot Studio notes
--------------------
- When you register the OpenAPI tool in Copilot Studio, name it `LabelService` and expose the `generateLabel` operation to the agent as `GenerateLabel`.
- Map the action to the LLM instruction in `copilot_artifacts/prompts.md` so that the agent calls `GenerateLabel` with the three required parameters.

Security
--------
This mock service is unauthenticated for prototype purposes. In production, require an API key and configure the tool in Copilot Studio to send the key via header (e.g., `Authorization: Bearer <KEY>`).
