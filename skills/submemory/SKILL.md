---
name: submemory
description: Shadow agent memory system. Use when spawning shadow agents (sub-agents) that need their own memory continuity, or when a shadow needs to read/update its own memory. Provides the schema and bootstrap protocol for shadows at ~/clawd/shadows/<name>/.
---

# Submemory — Shadow Agent Memory System

Shadow agents have their own memory roots at `~/clawd/shadows/<name>/`. This skill defines the schema and bootstrap protocol.

## Memory Schema

Each shadow has:

```
shadows/<name>/
├── SOUL.md      # Identity, personality, domain expertise
├── MEMORY.md    # Long-term memory (compact, graph-style)
├── SKILLS.md    # Skill focus areas and preferences
└── memory/      # (optional) Daily logs if needed
    └── YYYY-MM-DD.md
```

### SOUL.md
Who the shadow is. Personality, philosophy, technical depth, how they work. This is their identity — read it first, embody it throughout.

### MEMORY.md
Compact knowledge graph. NOT a journal. Format:

```markdown
## Recent Context
- [YYYY-MM-DD] Brief note about what happened
- [YYYY-MM-DD] Another context line

## Domain Knowledge
- Topic: key facts, patterns, learned insights
- Another topic: relevant notes

## Open Questions
- Things still unresolved
```

### SKILLS.md
Which skills the shadow specializes in. Points to SKILL.md files they should load for their domain.

### memory/ (optional)
Daily logs for shadows that do ongoing work. Most shadows don't need this — MEMORY.md suffices for ephemeral summons.

## Bootstrap Protocol (For Shadows)

When spawned, execute this sequence BEFORE starting the task:

```
1. READ ~/clawd/shadows/{name}/SOUL.md
   → Embody this identity for the entire session

2. READ ~/clawd/shadows/{name}/MEMORY.md  
   → Load your accumulated context and knowledge

3. READ ~/clawd/shadows/{name}/SKILLS.md
   → Note which skills you specialize in

4. LOAD relevant SKILL.md files
   → Based on your SKILLS.md and the current task

5. PROCEED with task
   → Now you have context. Do the work.

6. UPDATE ~/clawd/shadows/{name}/MEMORY.md
   → Capture key learnings, decisions, findings
   → Compact format — this is a knowledge graph, not a journal
```

## Spawning Template (For Jean)

When summoning a shadow:

```
sessions_spawn(
  task="""You are {NAME}, a shadow agent.

BOOTSTRAP (do this first):
1. Read ~/clawd/shadows/{name}/SOUL.md — your identity
2. Read ~/clawd/shadows/{name}/MEMORY.md — your context
3. Read ~/clawd/shadows/{name}/SKILLS.md — your skills
4. Load any relevant SKILL.md files for this task

TASK: {description}

DELIVERABLES: {list expected output files/artifacts}

COMPLETION GATE (mandatory before finishing):
1. For each deliverable: run `ls -la {path}` and `wc -l {path}` — confirm it EXISTS and is non-empty
2. Re-read the TASK section above. For each requirement, confirm it is addressed in your output.
3. If ANY deliverable is missing or empty: you are NOT done. Create it now.
4. Only after all checks pass: update ~/clawd/shadows/{name}/MEMORY.md with key findings
5. Return results to Jean with evidence: file paths + line counts""",
  model="sonnet",  # or opus for complex work
  thinking="high"
)
```

### Completion Gate

Every sub-agent spawn MUST include `DELIVERABLES` and `COMPLETION GATE` sections. This prevents silent failures where agents exit without producing output. The agent self-verifies deliverables exist before finishing.

### Failure Recovery (Jean's side)

1. If runtime is 0s or < 5s → session crashed, don't trust output
2. Always `ls -la` expected deliverables after spawn returns
3. If failed: re-spawn once. If fails twice, do it in main session
4. Never spawn more than 2 retries of the same task

## Memory Update Guidelines

Shadows should write MEMORY.md updates that are:

- **Compact**: One line per insight, not paragraphs
- **Dated**: `[YYYY-MM-DD]` prefix for temporal context
- **Actionable**: Focus on what matters for future tasks
- **Deduplicated**: Don't repeat what's already there

Good update:
```markdown
## Recent Context
- [2026-02-05] Audited ClawdNet staking → 2 medium issues (reentrancy in withdraw, no slippage check)
```

Bad update:
```markdown
## Recent Context
- [2026-02-05] Today I was asked to audit the ClawdNet staking contract. I found two medium severity issues. The first issue was a reentrancy vulnerability in the withdraw function where...
```

## Catalog

See `~/clawd/shadows/CATALOG.md` for available shadows and their domains.

## Creating New Shadows

1. Create directory: `~/clawd/shadows/<name>/`
2. Write SOUL.md — personality, expertise, philosophy
3. Initialize MEMORY.md — empty or with seed knowledge
4. Write SKILLS.md — skill focus areas
5. Update `~/clawd/shadows/CATALOG.md`
