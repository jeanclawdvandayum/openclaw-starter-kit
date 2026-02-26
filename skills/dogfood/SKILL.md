# Dogfood — Systematic Frontend QA & Bug Hunting

Systematically explore a web application, find bugs and UX issues, and produce a report with full reproduction evidence.

Use when asked to "dogfood", "QA", "test this", "find issues", "bug hunt", or review the quality of a web frontend. Also use after building/updating any frontend to verify it works.

## Setup

| Parameter | Default | Override example |
|---|---|---|
| **Target URL** | _(required)_ | `http://100.118.142.34:5201` |
| **Output directory** | `./dogfood-output/` | Any path |
| **Scope** | Full app | "Focus on the subscription page" |

Start immediately with defaults. Don't ask clarifying questions unless auth is mentioned but credentials missing.

## Workflow

```
1. Initialize    Set up output dirs, copy report template
2. Orient        Navigate, take initial snapshot + screenshot
3. Explore       Systematically visit pages and test features
4. Document      Screenshot each issue as found
5. Wrap up       Update summary counts, deliver report
```

### 1. Initialize

```
mkdir -p {OUTPUT_DIR}/screenshots
cp {SKILL_DIR}/templates/dogfood-report-template.md {OUTPUT_DIR}/report.md
```

Open the target:
- Use `browser` tool: `action=open`, `targetUrl={URL}`, `profile=openclaw`
- Wait for load, then take initial snapshot

### 2. Orient

```
browser action=snapshot (compact=true)
browser action=screenshot (save to {OUTPUT_DIR}/screenshots/initial.png)
```

Identify main navigation elements and map out sections to visit.

### 3. Explore

Read [references/issue-taxonomy.md](references/issue-taxonomy.md) for what to look for and the exploration checklist.

**Strategy — work systematically:**
- Start from main navigation. Visit each top-level section.
- Within each section, test interactive elements: click buttons, fill forms, open dropdowns/modals.
- Check edge cases: empty states, error handling, boundary inputs.
- Try realistic end-to-end workflows (create, edit, delete flows).
- Check the browser console for errors periodically.

**At each page:**
```
browser action=snapshot compact=true
browser action=screenshot (save as {page-name}.png)
browser action=console
```

Use judgment on depth. Spend more time on core features, less on peripheral pages. If you find a cluster of issues in one area, dig deeper.

### 4. Document Issues

Explore and document in a single pass. When you find an issue, stop and document immediately before moving on.

**For every issue:**
1. Take a screenshot showing the problem
2. Write description: what's wrong, what was expected, what actually happened
3. Write numbered repro steps
4. Append to report immediately (don't batch for later)
5. Increment issue counter (ISSUE-001, ISSUE-002, ...)

**Evidence levels:**
- **Interactive/behavioral bugs** (click something → breaks): Step-by-step screenshots showing before, action, and broken result
- **Static/visible bugs** (typos, layout, visual): Single screenshot is sufficient

### 5. Wrap Up

Aim for **5-10 well-documented issues**. Depth of evidence beats quantity.

1. Update summary severity counts in report to match actual issues
2. Tell user the report is ready: total issues, severity breakdown, most critical items

## Issue Categories

| Category | Examples |
|---|---|
| **Visual/UI** | Broken layout, clipped text, z-index, animation glitch, responsive issues |
| **Functional** | Broken links, buttons do nothing, form validation wrong, state not persisted |
| **UX** | Missing loading indicator, confusing navigation, no error feedback, dead ends |
| **Content** | Typos, placeholder text, truncated labels, wrong terminology |
| **Performance** | Slow loads (>3s), janky scroll, layout shifts, excessive requests |
| **Console** | JS exceptions, failed requests (4xx/5xx), unhandled rejections |
| **Accessibility** | Missing alt text, no keyboard nav, focus traps, missing ARIA |

## Severity Levels

| Severity | Definition |
|---|---|
| **Critical** | Blocks core workflow, data loss, crashes |
| **High** | Major feature broken, no workaround |
| **Medium** | Feature works with noticeable problems, workaround exists |
| **Low** | Minor cosmetic or polish |

## Exploration Checklist (per page)

1. **Visual scan** — Screenshot. Layout, alignment, rendering.
2. **Interactive elements** — Click every button/link/control. Works? Feedback?
3. **Forms** — Fill and submit. Empty, invalid, edge cases.
4. **Navigation** — All nav paths, breadcrumbs, back button, deep links.
5. **States** — Empty, loading, error, overflow states.
6. **Console** — JS errors, failed requests, warnings.
7. **Responsiveness** — Different viewport sizes if relevant.

## Guidance

- **Repro is everything.** Every issue needs proof — screenshot minimum.
- **Be thorough but use judgment.** Explore like a real user, not a script.
- **Write findings incrementally.** Append each issue as discovered. If session interrupts, findings are preserved.
- **Check the console.** Many issues are invisible in UI but show up as JS errors.
- **Test like a user, not a robot.** Try common workflows end-to-end.
- **Never read source code during dogfooding.** Test as a user only.

## References

| File | When to read |
|---|---|
| [references/issue-taxonomy.md](references/issue-taxonomy.md) | Start of session — full category list and checklist |
| [templates/dogfood-report-template.md](templates/dogfood-report-template.md) | Copy into output directory as report |
