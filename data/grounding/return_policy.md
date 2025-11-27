Return Policy and Upload Guidelines

Purpose
- This document contains the company's return policy rules and example email templates. Upload this file as a knowledge document to Copilot Studio (SharePoint/file source) and Azure AI Foundry (file grounding).

Policy summary
- Standard return window: 30 days from purchase date for most items unless marked final-sale.
- Final-sale items: any SKU with `final_sale: yes` in the product catalog cannot be returned.
- Condition: Items must be unused and in original packaging unless the return reason documents damage.
- Warranty exceptions: Items with warranty months may be eligible for a repair or replacement instead of a return.
- Photo evidence: For "Arrived damaged" or "Defective" reasons, photos are required; if photo shows clear damage, auto-eligible flow may apply.
- Frequent returner flag: For customers flagged as `frequent_returner = true`, route to manual review for potential fraud detection.

Decision rubric (human-readable, used by the agent)
1. Verify order exists and SKU matches purchase.
2. Check `final_sale` flag — if yes, mark INELIGIBLE.
3. Compute days between purchase_date and return_requested_date — if > 30 and not covered by warranty, INELIGIBLE.
4. If reason indicates damage and photo evidence exists, mark ELIGIBLE (unless warranty/repair policy applies).
5. If customer is `frequent_returner`, add "manual review" tag and route to human agent.

Email templates
- Eligible (label attached):
  Subject: Your return label for order {order_id}
  Body: Hi {customer_name},
  We have approved your return for order {order_id}. Please find your prepaid return shipping label here: {label_url}
  Steps: Pack the item securely, attach the label, and drop off at the carrier.

- Ineligible:
  Subject: Return request update for order {order_id}
  Body: Hi {customer_name},
  We’re unable to approve a prepaid return for order {order_id} because: {reason_explanation}. Please contact support for next steps.

Upload guidance
- Copilot Studio: add `return_policy.md` as a file knowledge source or upload to SharePoint and connect SharePoint as a grounding source.
- Azure AI Foundry: upload `return_policy.md` to the Foundry file store or index it in Azure Cognitive Search and point Foundry grounding to that index.
