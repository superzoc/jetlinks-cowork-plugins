# Design References — {{FEATURE_NAME}}

> Status: `research` · Last updated: _YYYY-MM-DD_
>
> Working file produced by the design-research step of `spec-scaffold`.
> Not part of the CLI handoff contract — its job is to seed the requirements
> interview with prior-art context. Delete or keep as historical notes after
> Phase 4 verification.

## 1. Framing

_One sentence: how was this feature framed when searching for prior art?_
_e.g. "Per-tenant resource quota with hard enforcement in B2B SaaS."_

Search queries used:

- _query 1_
- _query 2_
- _query 3_

## 2. Mature designs surveyed

List 2–4 leading products that solve a similar problem. Cite URLs.
Note **what they do** and **what is worth borrowing or avoiding**.

### _Product A_

- Source: _URL_
- Design summary: _2–3 sentences_
- Worth borrowing: _bullet_
- Worth avoiding: _bullet_

### _Product B_

- Source: _URL_
- Design summary: _2–3 sentences_
- Worth borrowing: _bullet_
- Worth avoiding: _bullet_

## 3. UI / UX patterns spotted

Concrete interaction patterns observed across the surveyed designs.
Each pattern should be specific enough to be a yes/no decision for our
prototype.

- _Pattern 1 — e.g. "Show current usage inline next to the limit input as
  'X / Y used' with a progress bar"_
- _Pattern 2 — e.g. "On limit-exceeded action, return a structured error
  with the limit, current usage, and an upgrade CTA"_
- _Pattern 3_

## 4. Antipatterns / pitfalls

What the surveyed designs did badly, or what common pitfalls show up in
the discussion / docs. Worth surfacing in `requirements.md` Out-of-scope
or `plan.md` Risks.

- _Antipattern 1_
- _Antipattern 2_

## 5. Takeaways into the interview

3–5 bullet points the agent will use to seed the requirements interview.
Each should map to a concrete question or candidate acceptance criterion.

- _Takeaway 1 — implies question: "..."_
- _Takeaway 2 — implies acceptance criterion: "..."_
- _Takeaway 3_

## 6. Connector findings (optional)

If a Figma / Notion / Linear / Slack connector was queried, link the
findings here. Otherwise leave this section out.

- Figma: _link to relevant frames, or n/a_
- Notion / Linear: _links to similar past specs, or n/a_
- Slack: _related threads, or n/a_
