Task B — Follow-along: Build the agent in Copilot Studio

Objective
- Build, publish, and test a working prototype in Copilot Studio that triages returns and issues pre-approved labels for eligible requests.

Prerequisites
- Copilot Studio access and permissions to create projects/agents.
- The artifacts from Task A: purpose, scenario, decision rubric, sample orders, and mock label API.
- A Logic Apps environment or another HTTP-invokable automation tool.
- A SharePoint site (or Azure SQL) for audit logging.
- Teams tenant to publish and test the agent.

Deliverables from this step
- A Copilot Studio project and prototype agent (ReturnBot).
- At least two knowledge sources added to the agent.
- One Logic App (or HTTP tool) that generates labels.
- Audit logging action connected.
- A published Teams instance with test interactions and collected feedback.

Step-by-step walk-through
1) Prepare environment and knowledge sources (30–60 minutes)
   - Create a Copilot Studio project titled `ReturnBot-Pilot`.
   - Add SharePoint site containing return policy docs and templates as a knowledge source.
   - Add an order data source: either connect an Azure SQL, or upload `sample_orders.csv` as a file data source.
   - Action: Confirm that Studio can search and fetch facts from both sources.

2) Create prompts and system instruction (30–60 minutes)
   - System instruction (persona + goal): e.g., "You are ReturnBot... Always ask for order number, SKU..."
   - Create an intake prompt template and a decision template.
   - Add the decision rubric as part of the agent’s instructions so the LLM can use it deterministically.
   - Action: Save and test prompt templates with simulated inputs in Studio's test console.

3) Implement tool integrations (Logic Apps + SharePoint) (60–120 minutes)
   - Logic App: HTTP trigger accepting JSON {order, sku, labelType} → call carrier API (or return mock URL) → return {labelUrl, labelId}.
   - Copilot Studio action: add an action that calls the Logic App endpoint when the agent decides "ELIGIBLE".
   - Audit logging: add a SharePoint write action or Logic App step to append a record with decision, evidence, labelId, timestamp.
   - Action: Test the Logic App endpoint with sample payloads.

4) Add action mapping and output handling (30–45 minutes)
   - Map label API outputs to an email template and to SharePoint fields.
   - Ensure success/failure handling: if label API fails, agent should present a graceful message and route to human fallback.
   - Action: Add error-handling text in prompts and action configurations.

5) Publish to Microsoft Teams (30–60 minutes)
   - Use Copilot Studio publish wizard to expose ReturnBot as a Teams bot.
   - Test the bot in a private test team or dev tenant.
   - Action: Confirm the bot can receive an intake, validate order data from the data source, call the Logic App, and send a label link.

6) Test, collect feedback, and iterate (60–120 minutes)
   - Run the 10 test inputs (eligible/ineligible/missing/ambiguous). Log results into SharePoint.
   - Add a short post-interaction survey or quick reaction capture ("Was this helpful?").
   - Review logs and feedback and adjust prompts, rules, or tool mappings.
   - Action: Keep a change log for each iteration.

Example prompts & templates (copy into Studio)
- System: "You are ReturnBot..."
- Intake prompt: "Customer submitted return: order #{order}, SKU {sku}, date {date}, reason {reason}. Validate eligibility and respond with 'ELIGIBLE — generate label' or 'INELIGIBLE — reason and next steps'."

Testing checklist
- Knowledge sources accessible and returning expected facts.
- Logic App returns label URL for eligible cases.
- Audit entry created in SharePoint for each run.
- Published in Teams and tested for 10 cases.
- At least one real user feedback recorded.

Edge cases and hardening
- Missing or conflicting order information → agent asks clarifying questions.
- Label API intermittent failures → agent tries once, then queues for human review.
- Photo uploads for damage detection: if included, route to a photo-classifier microservice or mark for manual review.

How to verify
- Execute the two example cases from Task A and verify the same decisions.
- For an eligible case: ensure label URL email is received and SharePoint log contains labelId and evidence.
- For an ineligible case: ensure templated denial is sent and logged.

Next steps
- If the prototype is stable, move to Task C to rebuild/extend in Azure AI Foundry and prepare the presentation deliverables (video + document).