---
name: compound
description: Reflect on corrections and patterns from a conversation to capture durable guidance. Use proactively at the end of conversations where the user corrected your approach or style.
---

# Capture Learnings

Reflect on the learnings from the conversation and decide if there are any new learnings that should be captured in rules, skills, or commands.

Be conservative in suggesting changes and when you do, carefully consider the existing setup and prioritize edits over additions.

## What We Mean by "Compounding"

Compounding means turning what you learned in **this** task into **durable guidance** so future work is faster and avoids repeated mistakes.

## How to Reflect

1. **Review corrections first** - Find places where the user had to correct you, ask "what are you doing?", or redirect your approach. These are the highest-value learnings. Look for:
   - Questions that indicate confusion about your approach
   - Suggestions to try a simpler/different method
   - Explicit redirects like "let's do X instead"
2. **Behavioral over technical** - Technical learnings (APIs, config values) are usually documented in the code itself. Behavioral learnings (when to ask, how to approach problems) are more valuable as rules.
3. **Review actual code changes** - Run `git diff` or `git log` to see what was changed, not just what was discussed. The conversation may only cover a fraction of the patterns established in the PR.
4. **Identify patterns** - Look for repeated corrections, anti-patterns that were cleaned up, or conventions established by the changes
5. **Check for preventable cleanup** - If code was simplified or dependencies removed, ask: what guidance would have prevented the complexity from being added in the first place?
6. **Be conservative** - Only capture learnings that will genuinely help future work; don't over-document

## Where Guidance Lives

- **`AGENTS.md`** (repo root): General rules for all work. Subdirectories (`lighthouse/`, `nautilus/`, `orcalib/`, `orca_sdk/`) have their own `AGENTS.md` for project-specific guidance.
- **`PYTHON.md` / `TYPESCRIPT.md`** (repo root): Language-specific style guides.
- **`.cursor/CLOUD_AGENTS.md`**: Cloud agent environment setup (only applies inside the container).
- **Skills** (`.claude/skills/`): Heavier reusable procedures, often with tool integrations.

## When Writing Rules

- **Read existing code first** - understand actual patterns before documenting conventions
- **Use real examples from the codebase** - don't make up examples
- **Keep rules concise** - avoid over-specifying; trust developers to apply judgment
- **Prefer editing existing files** - consolidate related guidance rather than creating new files
- **Place at the most specific scope** - project rules in the project's `AGENTS.md`, language rules in `PYTHON.md`/`TYPESCRIPT.md`, general rules only in the root `AGENTS.md`
- **Avoid heading proliferation** - add bullet points under existing headings rather than creating new subheadings for every specific tip unless a new section is warranted.
- **Generalize before placing** - don't write rules that are specific to one feature or one incident. Extract the underlying principle (e.g. "don't duplicate resolution logic in lighthouse for ignore_unlabeled" → "push default resolution down the call stack"). If the principle is language-specific, put it in the language file, not the project's `AGENTS.md`.
- **Don't overcorrect to the last instance** - when the user corrects you, extract the general principle rather than writing a rule that only prevents the exact mistake you just made.
- **Don't mix concerns** - a rule about typing patterns belongs in the language file, not a project's `AGENTS.md`. A rule about which layer owns business logic belongs in the project file. Ask: "would this apply if I were working on a different feature in the same project?" If yes, it's the right scope. If it would apply in a different project too, move it up.
- **Write for a stranger** - someone reading the rule should understand it without context from this conversation. Avoid referencing specific classes, fields, or features. If you can't explain the rule without a concrete example, the rule is too specific — generalize it or skip it.
