Mock grounding data — instructions and upload mapping

This folder contains synthetic / mock company data you can use as grounding sources for Copilot Studio and Azure AI Foundry when building the ReturnBot prototype.

Files included
- `sample_orders.csv` — sample order records (order_id, dates, customer, sku, reason, photo_url). Upload as a data table / CSV knowledge source.
- `product_catalog.csv` — product catalog (sku, name, category, price, returnable, final_sale). Use to validate SKUs and return rules.
- `customers.csv` — customer metadata (customer_id, name, email, frequent_returner flag).
- `return_policy.md` — human-readable policy, decision rubric, and email templates. Upload as a file knowledge source (SharePoint or Foundry file store).
- `mock_label_api_openapi.json` — small OpenAPI spec for a mock label generator. Register this as a tool in Foundry or use it to stub HTTP action in Copilot Studio.

Where to upload
- Copilot Studio:
  - Files (return_policy.md) -> File or SharePoint knowledge source.
  - Tables (sample_orders.csv, product_catalog.csv, customers.csv) -> Data sources (file upload or Azure SQL/CSV connector).
  - Tools -> Add an HTTP action that calls the endpoint described in `mock_label_api_openapi.json` (or stub it with a Logic App returning the same schema).

- Azure AI Foundry:
  - Files -> Upload `return_policy.md` to Foundry file store or index it in Azure Cognitive Search.
  - Data -> Index the CSVs into Azure Cognitive Search or upload as files and configure a grounding pipeline.
  - Tools -> Register `mock_label_api_openapi.json` as an OpenAPI tool and test via Foundry's tool simulator.

Quick test notes
- Use the two canonical example cases in the Task-A follow-along to validate the flow: one eligible, one ineligible.
- For label generation testing, run the `mock_label_service.py` (if you choose to spin it up) and point Studio/Foundry to its `/generateLabel` endpoint.

If you want, I can:
- Add a small Flask mock service and a PowerShell/Python test script that calls the agent flow and demonstrates label generation and logging.
