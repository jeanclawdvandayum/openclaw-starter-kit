# LEARNING.md — Continuous Learning Loop

Drip-feed learning: one source per heartbeat cycle (~5 minutes).
Rotate through categories. Background enrichment, not firehose.

## Source Categories

Customize these to your domains:

| ID | Category | Sources |
|----|----------|---------|
| A | Industry News | HN, relevant newsletters, blogs |
| B | Standards & Specs | RFCs, W3C, relevant standards bodies |
| C | Security | CVEs, security advisories, post-mortems |
| D | Research | Papers, talks, conference proceedings |
| E | Tools & Infra | New tools, framework updates, benchmarks |
| F | Community | Discussions, open source, emerging patterns |

## Learning Cycle (ONE per heartbeat)

1. **SCOUT** — Check one source from the current category
2. **EVALUATE** — Is it novel? Useful? Relevant to our work?
3. **INTEGRATE** — Add to appropriate destination (topic file, skill, tools)
4. **CONNECT** — How does it relate to what we're building?
5. **ROTATE** — Move to next category, update state

## State

Track in `memory/learning-state.json`:
```json
{
  "nextCategoryIndex": 0,
  "totalCycles": 0,
  "lastCycleDate": null,
  "recentDiscoveries": []
}
```

## Inspiration Queue

Ideas and threads worth exploring deeper (but not now):

*Empty. Add items as you discover them.*

## Recent Discoveries

*Log what you find during learning cycles.*
