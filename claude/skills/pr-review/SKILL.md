---
name: pr-review
description: Produces a standalone, local review-guide document (file) for a PR — distinct from the pr-description skill, which generates the PR body (title, changelog, review section) for GitHub. Use when the user asks to review a pull request, generate a review guide for local use, or understand design decisions in a PR.
---

# PR Review Guide

Produces a markdown review guide document that a reviewer can use locally. The guide explains what changed, why, and where to look. Follow AGENTS.md and, for structure, align with the Review Guide section in [.claude/skills/pr-description/SKILL.md](.claude/skills/pr-description/SKILL.md).

## When to use

- User asks to "review PR #N", "generate a review guide", "help me review this PR", or "understand the design decisions in this PR".
- Output is a **standalone file** (e.g. `review-guide-pr-2623.md`) for local viewing, not the PR description body.

## Workflow

1. **Get PR scope** — `gh pr view <number> --json title,body,headRefName` or equivalent. If no number given, ask or use current branch vs base.
2. **Get full diff** — e.g. `git diff <base>...<pr-branch> --stat` then read key changed files. Determine which files are created (c), modified (m), or removed (r).
3. **Read key files** — For medium/large PRs, read the main changed files to extract design decisions, not just behavior.
4. **Write the guide** — Use the structure below. Prefer **local relative links** and **embedded code snippets** so the report is readable without opening GitHub.

## Document structure

Keep this order: design and code-first sections before user-facing or process sections.

1. **Header** — PR link, title, scope (codebases touched).
2. **Overview of touched files** — Filetree with status in the branch character:
   - **Legend:** (c) created, (m) modified, (r) removed.
   - In the tree use `├c─`, `├m─`, `└r─` (and `├──`, `└──` for directories or when status is not shown). Keep line comments short.
   - Below the tree, optional bullet list of the same files as clickable local links with (c)/(m)/(r) and one-line description.
3. **Changelog** — From the PR or derived; use repo codebase names (Lighthouse, Nautilus, OrcaLib, Customers, etc.).
4. **Design decisions that matter** — Per area or file:
   - Start with **Intent:** (what problem, what constraints, what trade-offs).
   - Point to files with local links. Embed small code snippets for the most important design choices.
5. **Highlights (where to scrutinize)** — Bullet list: file (local link) + what to check. Focus on tricky logic and likely bug areas.
6. **Key question** — When the user raises a specific question or hypothesis (e.g. "could the issue be X?"), give it a dedicated section. Investigate the question with evidence for and against, and state a verdict or recommended action. Omit if the user didn't raise a specific question.
7. **Gotchas** — Only non-obvious items: things that look wrong but are intentional, or subtle behavior. Omit if there are none.
8. **Production impact & breakage risk** — When the PR touches deployment, release workflows, production config, API contracts, or shared code used in production: assess blast radius (what runs where, who is affected), likelihood of introducing breakage (e.g. config changes, new failure modes, backward compatibility), and any rollback or mitigation (feature flags, staged rollout). Keep this section short; omit if the change is clearly dev-only, docs, or tests.
9. **Testing** — When the PR touches testable behavior: what to run, what's covered, what's missing. Important for many PRs; include when relevant.
10. **Customer-facing** — When relevant (e.g. notebooks, SDK surface, CLI, report output): what the user runs, what they see, key outputs. Often this is SDK or API design. Do not put this section first; keep design and code paths before user-facing narrative.
11. **What to review (checklist)** — Short list of correctness, API shape, **production impact and risk of breakage**, tests/runbook, dependencies, docs.

## Conventions

- **Links:** Use repo-root-relative paths so the guide works when viewed locally, e.g. `[data_prep_133.py](customers/pan/utils/data_prep_133.py)`.
- **Filetree status:** c = created, m = modified, r = removed. Use them in the tree and in the list (e.g. `(c)` after filenames).
- **Design:** Lead with motivations and intent; avoid long code walkthroughs. Use code blocks only for snippets that illustrate a design choice.
- **Tone:** Assume the reviewer knows the codebase; state intent and constraints, not basic architecture.
- **Formatting:** Avoid dense comparison tables with many columns or long prose in cells — they are hard to scan. Prefer short bullet lists, one subsection per option (e.g. "**Notebook A:** … **Notebook B:** …"), or a simple two-column table with very short cell text. If a table would have long paragraphs in cells, use prose or bullets instead.

## Output location

Write the guide to **`temp/`** at the repo root (e.g. `temp/review-guide-pr-<number>.md`). Create the directory if it does not exist.
