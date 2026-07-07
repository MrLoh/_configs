---
name: pr-communication
description: Send Slack messages about pull requests — either DMs to reviewers asking for reviews, or announcements of new PRs in the engineering channel. Use when the user wants to follow up on PR reviews, nudge reviewers, announce PRs, or send review reminders.
---

# PR Slack Messages

Send concise Slack messages about pull requests: review followups to assigned reviewers, or announcements to the engineering channel.

## Configuration

Channel IDs are defined in `config.json` alongside this skill. Read it to get the engineering channel ID before drafting an announcement.

## Shared Steps

**Use `slack_send_message_draft` by default** — this creates a draft in the user's Slack UI where they can review and send it themselves. Only use `slack_send_message` (direct send) when the user explicitly says "send it" **after** reviewing the drafted text.

### Identify PRs

If the user doesn't specify PRs, list their open PRs:

```bash
gh pr list --author=@me --state=open --json number,title,url,updatedAt,headRefName
```

### Gather PR Context

For each PR, read the review guide section from the PR description:

```bash
gh pr view <number> --json body
```

Extract the key design decisions, tradeoffs, or risk areas from the review guide. Skip implementation details the reviewer will see in the diff (e.g. "uses library X" or "bootstraps service Y"). The goal is to communicate *what judgment calls to evaluate*, not *what the code does*.

### Tone Rules

- Direct — state what's needed, no greetings ("Hey", "Hi") or filler
- No exclamation marks, no "Thanks!"
- End naturally after the last piece of information

## Mode: Review Follow-up

DM assigned reviewers to nudge them on open PRs.

### 1. Fetch Reviewers

```bash
gh pr view <number> --json title,reviewRequests
```

Group PRs by reviewer so each person gets a single message.

### 2. Find Slack IDs

Use `slack_search_users` to find each reviewer's Slack user ID by name.

### 3. Draft and Send

- One line asking them to review
- A bullet per PR with the GitHub link and a brief description
- One sentence of review focus per PR — the key design decision or risk area
- If PRs are related, note the relationship (e.g. "X is the base, Y builds on top")

**Example:**

```
Could you review these two PRs? 2616 is the base, 2626 builds on top with the CI workflow.
- https://github.com/<org>/<repo>/pull/2616 — bundles the CLI as a standalone macOS executable. Key design call: job discovery refactored from filesystem scanning to pkgutil.walk_packages since source files don't exist in frozen builds
- https://github.com/<org>/<repo>/pull/2626 — adds macOS build job to release CI, fully independent of other jobs so it can't block releases
```

Use `slack_send_message_draft` with the reviewer's user ID as `channel_id`. The draft appears in the user's Slack "Drafts & Sent" for review before sending.

## Mode: PR Announcement

Post to the engineering channel to announce new or notable PRs.

### 1. Draft Message

- Brief context on what the PR(s) address and why they matter
- A bullet per PR with the GitHub link and a one-line summary
- One sentence on the key design approach or tradeoff — enough for someone to decide if they want to look closer

**Example:**

```
Couple of PRs up for the macOS executable:
- https://github.com/<org>/<repo>/pull/2616 — PyInstaller bundling with embedded Postgres, enables Apple Silicon GPU acceleration without Docker
- https://github.com/<org>/<repo>/pull/2626 — CI job to build and publish the executable via ORAS
```

### 2. Confirm and Send

Use `slack_send_message_draft` with the engineering channel ID from `config.json`. The draft appears in the user's Slack "Drafts & Sent" for review before sending.
