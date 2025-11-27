Task C — Follow-along: Rebuild and extend in Azure AI Foundry

Objective
- Recreate the return-triage scenario in Azure AI Foundry, register tools (OpenAPI/Logic App), add grounding sources, and deploy to Teams or a web app. Prepare the presentation deliverables (3-minute video + documentation).

Prerequisites
- Azure subscription with Foundry access and permissions to create projects and tool registrations.
- Artifacts from Task A & B: purpose, decision rubric, sample orders, Logic App (OpenAPI), and SharePoint logging.
- Any microservices used for image analysis if you plan to integrate damage detection.

Deliverables from this step
- Foundry project configured with an LLM deployment and instructions.
- Tools registered (OpenAPI spec for label generation, SharePoint or SQL logging tool).
- Published Teams or web-app integration and verified flows.
- Short demo video (≤3 minutes) and a documentation PDF/Word describing the solution.

Step-by-step walk-through
1) Create a Foundry project and deploy an LLM (30–60 minutes)
   - Create `returnbot-foundry` project in Azure AI Foundry.
   - Choose a conversational model (configure temperature, max tokens) and deploy to a runtime endpoint.
   - Save the deployment endpoint and credentials to your project secret store.

2) Configure system prompt, instructions, and grounding (30–90 minutes)
   - Add the same system instruction and decision rubric as in Task B.
   - Add grounding: (a) an Azure Cognitive Search index built from order DB and policy docs; (b) a SharePoint file source for templates.
   - Set retrieval settings to prefer recent policy docs and restrict scope to the product category.

3) Register tools (OpenAPI + logging) (45–90 minutes)
   - Publish your Logic App as an HTTP endpoint and create an OpenAPI 3.0 spec describing the label generation operation.
   - Register the OpenAPI tool in Foundry, map inputs and outputs (labelUrl, labelId).
   - Register logging tool: SharePoint write or Azure SQL insert (via an API wrapper if needed).
   - Test the tools in Foundry’s tool simulator with mock calls.

4) Add advanced extensions (optional, 60–180 minutes)
   - Semantic Kernel: create a conductor that calls a damage-detection microservice for cases with photos and passes results back to the LLM.
   - Microsoft 365 SDKs: for richer Teams cards, calendar follow-ups or orchestration.

5) Deploy and expose agent (30–90 minutes)
   - Publish the agent using Foundry’s publish workflow and select the Teams target (or create a web-app REST endpoint and embed a chat client).
   - Ensure the app registration and bot provisioning is complete and that the manifest has proper permissions.

6) Prepare presentation deliverables (60–120 minutes)
   - Video (≤3 minutes): 30s problem, 60s architecture & demo (one eligible + one ineligible), 30–60s results and next steps. Record the screen: Foundry console, a Teams chat demo, and Logic App run history.
   - Documentation: export a PDF/Word with the purpose, instructions, tools, grounding sources, OpenAPI spec snippet, challenges, and deployment steps.
   - Upload the video and document to the required platform.

Testing & verification
- For two canonical test cases: verify Foundry agent uses grounding to validate order and policy, calls the OpenAPI label tool when eligible, and logs audit entries.
- Confirm the Teams integration can authenticate and that users can receive label URLs.

Quick checklist before submission
- Grounding verified against search index and SharePoint.
- OpenAPI tool registered and tested in Foundry.
- Teams publish completed and tested in a dev tenant.
- One real user feedback captured in logs.

Next steps
- Finalize documentation and record the demo video.
- Prepare a short summary and timeline for project handoff (see `SUMMARY_NEXT_STEPS.md`).