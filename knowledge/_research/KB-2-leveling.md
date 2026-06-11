# KB-2 Leveling & Hierarchy — Research notes

Cited findings for the four KB-2 docs. Each bullet = one load-bearing claim. Sources are Microsoft Learn (authoritative for ADO) and recognized agile sources. Date checked: 2026-06-11.

## Work item types & hierarchy (Agile process)

- Agile process work item types: Epic, Feature, User Story, Task (plus Bug, Issue). User Stories and Tasks track work; Epics and Features group work under larger scenarios. — "About work items and work item types" / "Manage Agile requirements", https://learn.microsoft.com/azure/devops/boards/work-items/about-work-items?view=azure-devops (2026-06-11)
- The Agile backlog hierarchy is Epic → Feature → User Story → Task. — "Plan and track work in Azure Boards", https://learn.microsoft.com/azure/devops/boards/get-started/plan-track-work?view=azure-devops (2026-06-11)
- Product owners/program managers map User Stories to Features; when a team works in sprints they define Tasks that automatically link to user stories. — "Agile workflow in Azure Boards", https://learn.microsoft.com/azure/devops/boards/work-items/guidance/agile-process-workflow?view=azure-devops (2026-06-11)
- User Stories / backlog items "describe customer value." — "About work items and work item types", https://learn.microsoft.com/azure/devops/boards/work-items/about-work-items?view=azure-devops (2026-06-11)
- Epics and Features are the two default portfolio backlogs in the Agile process. — "Change a project process from Basic to Agile", https://learn.microsoft.com/azure/devops/organizations/settings/work/change-process-basic-to-agile?view=azure-devops (2026-06-11)

## Size / time-horizon (the rubric core)

- Feature: "a significant piece of functionality that delivers value to the user. It typically includes several user stories or backlog items and might take one or more sprints to complete." — "Define features and epics", https://learn.microsoft.com/azure/devops/boards/backlogs/define-features-epics?view=azure-devops (2026-06-11)
- Epic: "a large body of work that can be broken down into multiple features. It represents a major initiative or goal and might span several sprints or even releases." — same page (2026-06-11)
- "Generally, you should complete backlog items, such as user stories or tasks, within a sprint, while features and epics might take one or more sprints to complete." — same page (2026-06-11)
- Portfolio backlogs help "minimize size variability of your deliverables by breaking down a large feature into smaller backlog items." — same page (2026-06-11)
- Product owners define high-level goals as Epics or Features; feature teams break Epics/Features down into Stories for prioritization and development. — "Manage product and portfolio backlogs", https://learn.microsoft.com/azure/devops/boards/plans/portfolio-management?view=azure-devops (2026-06-11)

## Task specifics

- Tasks are defined at the start of a sprint to break down planned work; they can be development, testing, or other kinds of work; estimated via Remaining Work (hours/days). — "Agile workflow in Azure Boards / Define tasks", https://learn.microsoft.com/azure/devops/boards/work-items/guidance/agile-process-workflow?view=azure-devops (2026-06-11)
- "Size tasks to take no more than a day. If a task is too large, break it down." — "Add tasks to backlog items for sprint planning", https://learn.microsoft.com/azure/devops/boards/sprints/add-tasks?view=azure-devops (2026-06-11)
- Tasks inherit the parent's Area Path and Iteration Path and appear on sprint taskboards. — "Plan and track work in Azure Boards / Add tasks (child items)", https://learn.microsoft.com/azure/devops/boards/get-started/plan-track-work?view=azure-devops (2026-06-11)

## Parenting / hierarchy mechanics

- "You can only reparent backlog items under other features, and features under other epics." (Strict parent rule.) — "Organize your backlog and map child work items to parents", https://learn.microsoft.com/azure/devops/boards/backlogs/organize-backlog?view=azure-devops (2026-06-11)
- Parent/Child is the link type that forms the hierarchy; you can add a Parent or Child link, use the mapping pane, or drag in the tree. — "Link work items to objects", https://learn.microsoft.com/azure/devops/boards/backlogs/add-link?view=azure-devops (2026-06-11)
- "Each process defines default backlog levels (for example: requirement, feature, epic). Work item types assigned to those backlog levels naturally form parent-child relationships." — "Azure Boards FAQs", https://learn.microsoft.com/azure/devops/boards/faqs?view=azure-devops (2026-06-11)
- A Feature can be created under an existing Epic (e.g., "Create a feature called 'Payment Processing' under epic #50"). — "Organize your backlog / Use AI to organize", https://learn.microsoft.com/azure/devops/boards/backlogs/organize-backlog?view=azure-devops (2026-06-11)
- Tasks without a parent appear at the top of the Taskboard as "unparented"; you can drag them onto a backlog item to parent them. — "Add tasks to backlog items for sprint planning / Unparented tasks", https://learn.microsoft.com/azure/devops/boards/sprints/add-tasks?view=azure-devops (2026-06-11)

## Right-sizing / decomposition (general agile)

- INVEST heuristic: a story should be small enough that roughly 6–10 fit in a sprint; rule of thumb that no single story exceeds ~25–33% of the team's average velocity. — "Should your user stories fit into one sprint?" Agile Alliance, https://agilealliance.org/why-you-need-your-user-stories-to-fit-into-one-sprint/ (2026-06-11); Humanizing Work guide to splitting stories, https://www.humanizingwork.com/the-humanizing-work-guide-to-splitting-user-stories/ (2026-06-11)
- Split stories by VALUE (vertical slices), not by architectural layer (horizontal: UI/DB/API) — layer-splits fail INVEST's "independent + valuable." — Visual Paradigm vertical vs horizontal slicing, https://www.visual-paradigm.com/scrum/user-story-splitting-vertical-slice-vs-horizontal-slice/ (2026-06-11); Humanizing Work (2026-06-11)
- SPIDR — five common split techniques (Spike, Paths, Interfaces, Data, Rules), attributed to Mike Cohn. — itemis SPIDR, https://blogs.itemis.com/en/spidr-five-simple-techniques-for-a-perfectly-split-user-story (2026-06-11)

## Notes / could-not-source
- The specific "Epic→Feature→Story→Task" naming and the agent's read-only-Epic scope are project/agent design facts, stated descriptively. ADO docs confirm the hierarchy and that the Agile process exposes Epic + Feature portfolio backlogs; they do not prescribe which levels a given agent may create.
- No org-specific facts (area paths, iteration lengths, picklists, team names) were sourced or invented — those live in a separate team-authored source.
