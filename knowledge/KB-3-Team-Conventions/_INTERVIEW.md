# KB-3 Interview — the facts only the team can supply. Answer each; fills the templates.

## 3.1 Area Paths
- List every valid area path in [PROJECT].
- Which area is the DEFAULT when the user doesn't specify one?
- Which area maps to which team/component?
  (Find in ADO: Project Settings > Project configuration > Areas)

## 3.2 Iteration Paths
- Current/active iteration(s) and the naming scheme.
- Default iteration when the user doesn't specify (backlog? current sprint?).
- How far ahead may the agent assign?
  (Find in ADO: Project Settings > Project configuration > Iterations)

## 3.3 Field Reference & Picklists  (closes Architecture §7.8)
- Which process template? (Agile / Scrum / CMMI / custom inherited)
- Confirm the ADO reference name for each field in Architecture §4.11.1:
  Title, Description, AcceptanceCriteria, ValueArea, StoryPoints, Priority, Risk, Effort.
- The "Team" field — derived from Area Path, or a custom field? If custom, its reference name.
- Custom fields' exact reference names: Release notes, Deploy notes, Feature-flag notes.
- ValueArea picklist values (e.g. Business / Architectural) — and how "enabler" maps.
- Is Story Points exposed on Feature in your template? Is Effort exposed on User Story?
  (Find in ADO: Org Settings > Process > [your process] > [work item type] > Fields;
   or REST: GET {org}/{project}/_apis/wit/fields)

## 3.4 Tags & the Requested-By convention
- Standard tag taxonomy.
- Exact format of the requested-by stamp (e.g. `requested-by:user@org.com`).
- Do you want a queryable `RequestedBy` custom field, or tag/description line only? (§7.4)

## 3.5 Naming Standards
- Title prefixes/conventions per type.
- Ticket-number conventions.
- Casing rules.

## 3.6 Ownership & Escalation
- Who owns / creates Epics? (the Epic owner)
- The `[ORG: contact]` for fallback/help (Topics T2 & T5).
- Epic write policy (§7.10): fully read-only, or may the agent COMMENT on (never create/retype) Epics?
- The `[PROJECT]` name (§7.6).
