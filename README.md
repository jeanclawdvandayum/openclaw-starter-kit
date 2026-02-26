# OpenClaw Starter Kit

Curated upgrades for OpenClaw — 75 skills + workspace templates for meta-learning, knowledge management, and structured self-improvement.

## What's Inside

### 🧠 Workspace Templates
Drop-in files that give your assistant long-term memory, self-correction, and structured thinking:

| File | What It Does |
|---|---|
| `AGENTS.md` | Session startup protocol, memory system, sub-agent rules |
| `SOUL.md` | Personality template with epistemic honesty and creative mode |
| `USER.md` | Tell your assistant who you are (fill this in) |
| `LESSONS.md` | Failure-to-guardrail pipeline — mistakes become rules |
| `HOLDS.md` | Temporary context filters with expiry dates |
| `FRICTION.md` | Contradiction log — catches conflicting instructions |
| `PREDICTIONS.md` | Decision calibration tracker |
| `COMMANDS.md` | 24 vault commands (`/map`, `/bloom`, `/graduate`, `/contradict`, etc.) |
| `LEARNING.md` | Continuous drip-feed learning loop |
| `memory/_index.md` | Knowledge graph index (Obsidian-style wiki links) |

### 📦 75 Curated Skills
General-purpose skills across 9 categories. No blockchain or domain-specific content.

- **Productivity** (12): brainstorming, planning, git workflows, kanban, self-improvement
- **Code Quality** (14): reviews, testing, TDD, documentation, compliance checking
- **Languages** (14): JS, TS, Python, Go, Rust, C++, SQL, React, Next.js, Godot, etc.
- **Architecture** (6): API design, system architecture, cloud, GraphQL, MCP, CLI
- **DevOps** (3): CI/CD, monitoring, database optimization
- **Security** (11): OWASP, CodeQL, Semgrep, secure coding, constant-time analysis
- **Documents** (6): Word, PDF, PowerPoint, Excel, HTML slides, LaTeX-style pages
- **Research** (5): article extraction, API reverse engineering, YouTube transcripts
- **Debugging** (4): structured debugging, root cause analysis, browser automation

See `SKILLS.md` for the full list.

## Install

```bash
# Clone
git clone https://github.com/jeanclawdvandayum/openclaw-starter-kit.git
cd openclaw-starter-kit

# Install skills only
bash install.sh

# Install skills + workspace templates
bash install.sh ~/clawd
```

The installer:
- Copies skills to `~/.openclaw/skills/` (skips existing)
- Optionally copies workspace templates (skips existing files)
- Never overwrites your customizations

After installing, restart your OpenClaw gateway.

## Customize

1. **Edit `USER.md`** — tell your assistant who you are
2. **Edit `SOUL.md`** — give it a personality (or keep the defaults)
3. **Start using `/commands`** — try `/today`, `/map`, `/bloom`
4. **Let `LESSONS.md` grow** — every mistake becomes a rule

## The Meta-Learning System

The workspace templates implement 6 interconnected feedback loops:

```
Mistake → LESSONS.md (permanent rule)
                ↓
Contradiction → FRICTION.md (surface & resolve)
                ↓
Decision → PREDICTIONS.md (calibrate judgment)
                ↓
Context → HOLDS.md (temporary filters)
                ↓
Knowledge → memory/topics/ (growing graph)
                ↓
Discovery → LEARNING.md (continuous enrichment)
```

Each loop is lightweight. Together they compound into an assistant that gets meaningfully better over time.

## Credits

Built by [scoopy](https://x.com/scaboramanga) and Jean.
Skills sourced from the OpenClaw community, Trail of Bits, OWASP, and original work.
