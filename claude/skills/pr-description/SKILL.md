---
name: pr-description
description: Generate a PR title and description with changelog and review guide
---

# PR Description

Generate a PR title and description for the current branch. Only consider the code changes and ignore the commit messages.

Before writing anything, verify you have a complete picture of the changes. Do not rely on partial context from the conversation — the discussion may have only covered a subset of the work. Determine the base branch by running `.claude/skills/pr-description/find-base-branch.sh`, then run `git diff <base>...HEAD` to see the full diff. Compare the diff against what you already know: if there are files or changes you haven't seen or discussed, read them before proceeding. The description must cover all changes in the PR, not just the ones that came up in conversation.

If a PR already exists for this branch, fetch the current description with `gh pr view --json title,body` and use it as a starting point — add new changes, update what shifted, and remove anything that's no longer accurate or was reverted.

### Gathering design context

For medium/large PRs, after reading the diff, read the key changed files in full. Look for design decisions — not just what the code does, but choices that shaped it and the constraints behind them.

Then ask the author about decisions where the motivation isn't obvious from the code alone. Ground your questions in specific patterns you noticed in the code, not generic ones ("why this framework?"). Skip questions the code or comments already answer.

## Title

The PR title uses the format: `type: message`

- **Types**: `feat` (new feature), `fix` (bug fix), `misc` (everything else)
- The message should summarize the overall PR purpose in one succinct phrase

Examples:

- `feat: add invite revocation`
- `fix: prevent duplicate predictions on retry`
- `misc: upgrade FastAPI to 0.115`

## Changelog

The PR description must start with a `## Changelog` section that contains `### <Codebase>:` headings for all codebases affected by the PR. Each section should contain a list of changes. Each bullet point must start with a `-` and use one of the following past tense verbs:

- additions: "Added", "Adopted", "Allowed"
- fixes: "Fixed"
- removals: "Removed", "Deleted", "Deprecated"
- changes: "Changed", "Upgraded", "Merged", "Ensured", "Separated", "Simplified", "Updated", "Improved", "Renamed", "Refactored", "Moved", "Optimized", "Cleaned"

Valid codebases are: "Lighthouse", "Nautilus", "OrcaLib", "OrcaSDK", "OpenAPIHttpx" (nested library in OrcaSDK for OpenAPI code generation), "Infra", "CI", "Setup" (developer environment, repo-level tooling, IDE config like `.cursor/` and `.claude/`), "Research", "Demo", "Docs", "Customers"

When a change to Infra, CI, or Demo has relevant effects on another codebase it should be included in the changelog section for that codebase as well. Conversely, internal-only changes (e.g. test fixes, CI config, dev tooling) in a codebase like OrcaSDK or Lighthouse should go under CI or Setup, not under the codebase's own heading — reserve codebase headings for user-facing changes.

The descriptions should summarize the overall effect of the changes, not simply outline every code change. Be concise — only include changes relevant to the behavior of the software, not irrelevant refactorings with little to no effect on the user. If there is just one change, use a single bullet point. Aim for 1–4 bullets per codebase — group related changes into a single bullet rather than listing each file or tweak separately. Details and rationale belong in the Review Guide, not the changelog.

**Common mistakes** — the changelog is a release-notes-style summary for someone who uses the product, not a code-review manifest for someone reading the diff. Ask "would a user or deployer care about this?" for each bullet.

Bad (implementation-level, too many bullets, internal refactors listed):

```
### Nautilus:

- Added SAML 2.0 SP sign-in via `@node-saml/node-saml` — gated by `SAML_ENTRY_POINT`, `SAML_ISSUER`, and `SAML_IDP_CERT` env vars; uses Redis for `InResponseTo` validation; POST ACS handler at `/login/saml`
- Added "Continue with SSO" button on the login page when SAML is configured
- Extracted shared `resolveExternalAuth` helper for user lookup/create/link, used by both OAuth and SAML callbacks
- Simplified `getRedirectPath` to check both OAuth and SAML state cookies
- Removed noisy timezone cookie warning, inlined the fallback
```

Good (user-facing effect, grouped, no implementation details):

```
### Nautilus:

- Added SAML 2.0 single sign-on with any SAML-compatible identity provider
- Removed spurious timezone cookie warning from server logs
```

Why: the SSO button, env var gating, Redis caching, route handler, helper extraction, and redirect path cleanup are all implementation details of "added SAML SSO" — they belong in the Review Guide. Internal refactors (extracting helpers, simplifying functions) are invisible to users and don't belong in the changelog at all. The timezone warning removal is a separate user-visible behavior change, so it gets its own bullet — but described from the user's perspective (noisy logs), not the code's (`decodeTimeZoneCookie` inlined).

## Review Guide

After the changelog, add a `## Review Guide` section that helps reviewers understand the PR from the description so they can navigate directly to the right code instead of reading diffs in random alphabetical order.

**File links**: Use markdown links to make file references clickable: `[path/to/file.py](https://github.com/{owner}/{repo}/blob/{branch}/path/to/file.py)`. Line ranges are optional: append `#L10-L25` when pointing to specific code. Use the branch name (not a commit SHA) so links aren't hardcoded to a specific revision.

To construct these, run:

- `git remote get-url origin` to derive `{owner}/{repo}`
- `git branch --show-current` to get `{branch}`

**Inline code snippets**: To show actual code inline in the description (e.g. a key interface), put a GitHub blob permalink on its own line (not inside a markdown link). GitHub auto-renders it as an expandable code block. These links **must use a commit SHA** (not a branch name) — run `git rev-parse HEAD` to get it. Use sparingly — only for code that embodies a design decision.

The section uses optional `###` sub-headings that scale with PR complexity:

- **Trivial PRs** (1-2 files, obvious change): skip the Review Guide entirely
- **Small PRs** (few files): a sentence or two of context, no sub-headings
- **Medium/Large PRs**: use sub-headings as needed:
  - `### Design` — explain _why_ the approach was chosen: what problem it solves, what constraints shaped it, what trade-offs were made. Assume reviewers know the codebase — state the intent, don't explain existing architecture. Lead with motivations, not code walkthroughs. Reference files with clickable markdown links. Embed code snippets sparingly — only to illustrate a design choice (e.g. a new interface), not just because a file changed.
  - `### Highlights` — the critical code paths worth scrutinizing: tricky logic, non-obvious implementations, or areas where bugs are most likely. Use clickable file links with line ranges to point reviewers straight there.
  - `### Gotchas` — things that look wrong but are intentional, or subtle behavior changes that reviewers might flag unnecessarily. Omit this section rather than filling it with obvious observations.
  - `### Background` — (large PRs) what problem triggered this PR, prior context.
  - `### Follow-ups` — (large PRs) work intentionally deferred to a future PR.

## Example

For a medium PR on branch `mrloh/add-invite-revocation` (HEAD SHA `a1b2c3d`):

```
## Changelog

### Lighthouse:

- Added endpoint to revoke org invites

### Nautilus:

- Added revoke button to the org invitations list

## Review Guide

### Design

Reused the existing `DELETE /invites/:id` pattern rather than adding a new `/revoke` action, since the invite is fully removed on revoke. The service method checks org-level permissions and cascades cleanup to related notification records.

The new `revoke_invite` signature:

https://github.com/OrcaDB/orca/blob/a1b2c3d/lighthouse/src/invite/service.py#L30-L38

### Highlights

- Permission check in [`service.py#L32-L40`](https://github.com/OrcaDB/orca/blob/mrloh/add-invite-revocation/lighthouse/src/invite/service.py#L32-L40) — cascading delete of notification records is the tricky part
- Confirmation dialog in [`InviteList.tsx#L95-L110`](https://github.com/OrcaDB/orca/blob/mrloh/add-invite-revocation/nautilus/src/app/.../InviteList.tsx#L95-L110) — handles the edge case where the invite expires while the dialog is open

### Gotchas

- The revoke button is hidden for pending invites older than 7 days because they auto-expire — this is intentional, not a bug
- Email notification on revoke will be added in a follow-up PR
```

## Output Format

Output the title on its own line as plain text, then the description body inside a markdown code block (triple backticks) so the user can see and copy the raw markdown source. Do not put the title inside the code block — it needs to be separate so it can be copied independently.
