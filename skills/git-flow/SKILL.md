---
name: git-flow
description: Automated PR workflow using shadow agents. Orchestrates dev agents to implement PRs from a plan, auditing agents for review, GitHub integration for comments/PRs, and report generation. Use when executing a development plan, running PR pipelines, or automating code review cycles.
---

# Git Flow — Shadow Agent PR Pipeline

Automated workflow for executing development plans through shadow agents with review cycles.

## Pipeline Overview

```
DEV PLAN → For each PR:
  ┌─────────────────────────────────────────────────────┐
  │ 1. Summon dev agent(s) for task                     │
  │ 2. Agent creates branch: PR-##/description          │
  │ 3. Agent implements & pushes to GitHub              │
  │ 4. Summon audit agent(s) for review                 │
  │ 5. Auditor comments on GitHub with findings         │
  │ 6. Dev agent fixes issues, pushes again             │
  │ 7. Repeat 4-6 until no issues                       │
  │ 8. Write report to reports/PR-##-report.md          │
  │ 9. Create PR on GitHub                              │
  │ 10. Jean reviews → merge or escalate to scoopy      │
  └─────────────────────────────────────────────────────┘
```

## Agent Selection Matrix

| Task Type | Dev Agent(s) | Audit Agent(s) |
|-----------|--------------|----------------|
| Smart contracts | scrub | auditor (Gildo) |
| P2P / networking | architect (Buck) + nomad | auditor |
| Frontend / UX | imimim | architect |
| Backend / infra | butler | auditor, architect |
| Tokenomics | blockenth | vitalika, niccolo |
| Architecture | architect | auditor, vitalika |
| Security features | auditor | scrub (cross-review) |

## Branch Naming

```
PR-##/short-description
```

Examples:
- `PR-37/libp2p-core`
- `PR-38/did-identity`
- `PR-39/rep-staking`

## Implementation Flow

### Step 1: Parse Dev Plan

Read the project's dev plan (usually in `docs/` or spec file). Extract:
- PR number
- Title/description
- Required features
- Dependencies on previous PRs

### Step 2: Spawn Dev Agent

```javascript
sessions_spawn({
  task: `You are {AGENT}, a shadow agent.

BOOTSTRAP: Read ~/clawd/shadows/{agent}/ files (SOUL.md, MEMORY.md, SKILLS.md).
Load relevant skills: {skill-list}

PROJECT: {repo-path}
BRANCH: PR-{##}/{description}

TASK:
{task-description}

WORKFLOW:
1. cd {repo-path}
2. git checkout main && git pull
3. git checkout -b PR-{##}/{description}
4. Implement the feature (reference spec at {spec-path})
5. Run tests: {test-command}
6. git add -A && git commit -m "PR-{##}: {title}"
7. git push -u origin PR-{##}/{description}

ON COMPLETION: Update your MEMORY.md with implementation notes.
Report back: "PR-{##} implementation complete. Ready for review."`,
  model: "sonnet",
  thinking: "high"
})
```

### Step 3: Spawn Audit Agent

After dev agent reports completion:

```javascript
sessions_spawn({
  task: `You are auditor (Gildo), a shadow agent.

BOOTSTRAP: Read ~/clawd/shadows/auditor/ files.
Load skills: audit-context-building, github

PROJECT: {repo-path}
BRANCH: PR-{##}/{description}
PR URL: {pr-url}

TASK: Security review of PR-{##}

WORKFLOW:
1. cd {repo-path}
2. git fetch origin && git checkout PR-{##}/{description}
3. Review all changed files for:
   - Security vulnerabilities
   - Logic errors
   - Edge cases
   - Gas optimization (if Solidity)
   - Best practices violations
4. For each issue found:
   gh pr comment {pr-number} --body "**[{SEVERITY}]** {file}:{line}
   
   {description}
   
   Suggested fix: {suggestion}"
5. If no issues: comment "✅ Security review passed"

ON COMPLETION: Update your MEMORY.md with findings summary.
Report: "PASS" or "ISSUES: {count} ({critical}/{high}/{medium}/{low})"`,
  model: "sonnet", 
  thinking: "high"
})
```

### Step 4: Fix Loop

If auditor reports issues:

```javascript
sessions_spawn({
  task: `You are {AGENT}, a shadow agent.

BOOTSTRAP: Read your shadow files.

PROJECT: {repo-path}
BRANCH: PR-{##}/{description}

TASK: Address review feedback for PR-{##}

FEEDBACK:
{paste auditor comments or gh pr view {pr-number} --comments}

WORKFLOW:
1. cd {repo-path} && git checkout PR-{##}/{description}
2. For each issue:
   - Fix the code
   - Reply to comment: "Fixed in {commit-hash}"
3. git add -A && git commit -m "PR-{##}: Address review feedback"
4. git push

ON COMPLETION: Report "Fixes pushed. Ready for re-review."`,
  model: "sonnet",
  thinking: "high"
})
```

Then re-spawn auditor. Repeat until `PASS`.

### Step 5: Generate Report

After review passes:

```markdown
# PR-{##} Report: {Title}

**Date:** {YYYY-MM-DD}
**Dev Agent:** {agent}
**Reviewer:** {auditor}
**Branch:** PR-{##}/{description}

## Summary
{what was implemented}

## Files Changed
- `path/to/file.ts` — {description}
- ...

## Review Cycles
- **Round 1:** {X} issues ({breakdown})
- **Round 2:** {Y} issues
- **Round 3:** ✅ Passed

## Key Decisions
- {decision-1}
- {decision-2}

## Security Notes
{any security-relevant observations}

## Ready for Merge
☑️ Tests passing
☑️ Security review passed
☑️ Documentation updated
```

Save to: `{repo}/reports/PR-{##}-report.md`

### Step 6: Create/Update PR

```bash
# If PR doesn't exist yet
gh pr create --base main --head PR-{##}/{description} \
  --title "PR-{##}: {Title}" \
  --body "$(cat reports/PR-{##}-report.md)"

# If PR exists, update description
gh pr edit {pr-number} --body "$(cat reports/PR-{##}-report.md)"
```

### Step 7: Jean's Review

Jean (me) reviews the PR:

**Auto-merge if:**
- All tests pass
- Security review passed
- Changes match spec
- No architectural concerns

**Escalate to scoopy if:**
- Architectural deviation from spec
- New dependencies introduced
- Security findings that were "accepted"
- Unclear requirements
- Significant scope change

```bash
# Merge (keep branch for history)
gh pr merge {pr-number} --squash

# Or request human review
# Message scoopy: "PR-{##} ready for your review: {url}"
```

## GitHub Commands Reference

```bash
# List PRs
gh pr list

# View PR details
gh pr view {number}

# View PR comments
gh pr view {number} --comments

# Add comment
gh pr comment {number} --body "message"

# Request review
gh pr edit {number} --add-reviewer {user}

# Merge (keep branch for history)
gh pr merge {number} --squash

# Check CI status
gh pr checks {number}
```

## Running the Pipeline

To execute a full dev plan:

```
1. Read the dev plan (e.g., PROTOCOL-SPEC.md §8 Implementation Path)
2. For each PR in sequence:
   a. Identify task type → select agents
   b. Spawn dev agent with full context
   c. Wait for implementation
   d. Spawn audit agent
   e. Loop fixes until pass
   f. Generate report
   g. Create/update PR
   h. Review and merge (or escalate)
3. After merge, ensure downstream branches rebase if stacked
```

## State Tracking

Track pipeline state in `{repo}/.git-flow-state.json`:

```json
{
  "currentPR": 38,
  "status": "review",
  "reviewRound": 2,
  "devAgent": "architect",
  "auditAgent": "auditor",
  "issuesRemaining": 3
}
```

## Integration with Existing Skills

- **submemory** — For spawning shadow agents properly
- **github** — For gh CLI commands
- **git-hygiene** — For branch/PR conventions
- **audit-context-building** — For thorough code review
