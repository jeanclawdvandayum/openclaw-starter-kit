---
name: git-hygiene
description: Sequential PR workflow for clean version history. Use for setting up new repos, creating PR chains, verifying with security review, and maintaining rebased branches. Invoke when asked about git workflow, PR sequences, branch management, or project setup for GitHub.
---

# Git Hygiene

Structured workflow for sequential PRs with security verification. Every PR has its own branch, stacks on the previous, and gets reviewed before merge.

## Core Workflow

```
main ← PR-01/feature-a ← PR-02/feature-b ← PR-03/feature-c
         (merged)          (review)          (draft)
```

### Branch Naming
```
PR-##/short-description
```
Examples: `PR-01/core-contracts`, `PR-02/reputation-system`, `PR-03/p2p-layer`

### PR Sequence

1. **Create branch from target** (main or previous PR branch)
2. **Implement feature** with atomic commits
3. **Self-review** — run tests, check for obvious issues
4. **Security review** — spawn Gildo for verification
5. **Fix issues** — if any, commit fixes, re-verify
6. **Submit PR** — create on GitHub with proper description
7. **Merge** — squash or rebase merge to keep history clean
8. **Rebase downstream** — update any stacked branches

## Commands

### Initialize New Project
```bash
# Create repo (if not exists)
gh repo create <owner>/<repo> --private --source=. --remote=origin

# Initial commit
git init
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

### Create PR Branch
```bash
# From main
git checkout main && git pull
git checkout -b PR-01/feature-name

# From previous PR (stacked)
git checkout PR-01/previous
git checkout -b PR-02/next-feature
```

### Submit PR
```bash
# Push branch
git push -u origin PR-01/feature-name

# Create PR
gh pr create --base main --head PR-01/feature-name \
  --title "PR-01: Feature Name" \
  --body "## Summary
- What this PR does

## Changes
- List of changes

## Testing
- How it was tested

## Security Review
- [ ] Reviewed by Gildo"
```

### Security Review Flow
```
1. Commit changes
2. Spawn Gildo: "Review PR-XX for security issues"
3. If issues found → fix → re-verify
4. If clean → proceed to merge
```

### Merge & Rebase Stack
```bash
# After PR-01 merges
gh pr merge PR-01/feature-name --squash

# Rebase downstream branches
git checkout PR-02/next-feature
git rebase main
git push --force-with-lease
```

## Gitignore Template

For Foundry/TypeScript projects:
```gitignore
# Dependencies
node_modules/
lib/

# Build artifacts
out/
cache/
broadcast/
artifacts/
typechain-types/

# Environment
.env
.env.*
!.env.example

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
```

## Project Structure (Desktop)
```
~/Desktop/projects/
├── froknet/           # Main project
├── other-project/     # Future projects
└── ...
```

## PR Checklist

Before submitting any PR:
- [ ] Tests pass locally
- [ ] No secrets/credentials committed
- [ ] Gitignore covers build artifacts
- [ ] Commit messages are clear
- [ ] Branch name follows convention
- [ ] Security review completed (for non-trivial changes)

## Rollback

If a merge causes issues:
```bash
# Revert last merge
git revert -m 1 HEAD
git push

# Or reset to specific commit (destructive)
git reset --hard <commit>
git push --force  # Only if you're sure
```

## Integration with Gildo

For security verification, spawn Gildo with context:
```
Task: Review [repo]/PR-XX for security vulnerabilities
Focus: [specific areas if any]
Report: List issues by severity (Critical/High/Medium/Low)
```

Gildo returns:
- PASS: No issues found
- ISSUES: List of findings with line numbers

Re-verify after fixes until PASS.
