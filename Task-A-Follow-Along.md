Task A — Follow-along: Define your agent purpose and scenario

Objective
- Produce a concise, testable agent purpose and a scoped scenario for the pilot: Automating product return handling (return triage + pre-approved label issuance).

Prerequisites
- Access to the project's repository or working folder.
- Credentials and read access to an order database (or a test CSV/DB) and a carrier label-generation API (or a sandbox API).
- SharePoint site or a simple logging store (Azure SQL / CSV) to record audit trails.
- Tools: Copilot Studio account (optional for prototype later), Logic Apps or any HTTP-capable automation, and a test Teams tenant for publishing.

Deliverables from this step
- One-sentence purpose statement for the agent.
- A clearly-scoped scenario (included/excluded items).
- List of grounding sources and APIs needed.
- Success criteria and target metrics.

Step-by-step walk-through
1) Choose the narrow problem and write the purpose (10–20 minutes)
   - Decision: "Automate the return triage process so customers receive an immediate eligibility decision and, when eligible, an automatically generated return shipping label."
   - Action: Save this sentence in a short doc `purpose.md` and include the owner and date.

2) Scope the scenario (20–30 minutes)
   - Write "Included" items: intake via email/web/chat, order validation, rule-based + light ML decision, label generation, email dispatch, audit logging.
   - Write "Excluded" items: physical inspection, refund processing beyond label, warehouse restocking, complex fraud.
   - Action: add these to `scenario_scope.md`.

3) Define inputs, grounding, and flow (30–60 minutes)
   - Inputs: order number, SKU, purchase date, reason, photos (optional), contact email.
   - Grounding: order DB (for validation), product policy docs (SharePoint or file), carrier label API.
   - Flow: intake → validate → apply rules/ML → eligible? create label & email : send templated denial → log transaction.
   - Action: model the flow in a simple diagram (draw.io or Markdown mermaid block). Save as `flow.md`.

4) Decision logic and example rules (30–60 minutes)
   - Implement a decision rubric as human-readable bullets: within 30 days, not final-sale, unopened unless damaged, photos indicate damage.
   - Create two example cases: one eligible, one ineligible (these will be used later for testing).
   - Action: Save as `decision_rubric.md` and include example test cases in `tests/cases.md`.

5) Success criteria and metrics (10–20 minutes)
   - Time to label issuance < 2 minutes for eligible cases (goal)
   - Eligibility precision ≥ 95% vs human baseline
   - Reduce manual volume by 60% in pilot
   - Action: Save as `metrics.md`.

6) Constraints, privacy, fallback (10 minutes)
   - Note assumptions: access to DB and label API; privacy and compliance handling; fallback route: ambiguous cases go to human agent.
   - Action: Save to `constraints.md`.

Quick checks (done after each sub-step)
- Purpose written and saved.
- Scope listed with included/excluded.
- Inputs and grounding sources enumerated.
- Two example cases created.
- Success metrics documented.

Optional quick implementations (low-risk)
- Create a small `sample_orders.csv` containing fake orders for testing.
- Create a dummy Logic App or mock HTTP endpoint that returns a sample label URL.

How to verify
- Run the two example cases through the manual rubric and confirm expected decisions.
- Confirm you can call the mock label endpoint and get a label URL.

Next steps
- Move to Task B: build a prototype in Copilot Studio using the artifacts created here (purpose, flow, rubric, test cases).