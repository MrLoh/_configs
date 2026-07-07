---
name: standup
description: Use when the user wants to post a standup, write a daily standup update, or share what they did yesterday and plan for today in Slack
---

# Posting Standup to Slack

Post a daily standup as a threaded reply to Slackbot's daily reminder.

## Configuration

- **Standup channel**: `C05AU7P5MEG`

## Workflow

### 1. Find Today's Thread and Check for Existing Post

Use `slack_read_channel` on `C05AU7P5MEG` (limit 5). Find **today's** Slackbot message (match on today's date). Then use `slack_read_thread` on that message to check if the user already posted a reply today. If they did, tell the user and ask whether they want to edit it or skip.

### 2. Read Previous Day's Log

Read the most recent `.md` file from `~/.standups/` (the one before today's date, under `<year>/W<week>/`). Its *Today* section shows what was planned — use it as the starting point for yesterday's update. If no `.md` file exists yet, fall back to reading the previous day's Slackbot thread in Slack.

### 3. Gather Yesterday's Work

Run the analysis script. With no arguments it gathers **yesterday's** data (the previous working day — weekends snap to Friday).

```bash
python3 ~/.agents/skills/standup/analyze-transcripts.py
```

The output file is named after **today's date** (the standup date) and placed in `~/.standups/<year>/W<week>/<today>.yaml`. The file starts with a `standup_date` and `data_range` header showing exactly what period is covered. It has five data sections — the first four are filtered to the data range, the last one is always current:
- `conversations`: Cursor sessions active during the date range (focus on `substantial: true`). Conversations created before the date range but still active during it are marked `continued: true` — these represent ongoing multi-day work streams. Only conversations created during the date range are unmarked (new). Each conversation has `turns` (total lifetime) and `turns_in_range` (turns added since the previous run). For continued conversations, `turns_in_range` shows how much activity happened in this date range specifically — use it to distinguish conversations that were heavily active yesterday from ones that just had a trailing message.
- `commits`: git commits across all branches with files changed
- `pull_requests`: authored PRs created or updated in the date range (`is_new` = created, not just updated)
- `reviewed_prs`: PRs by others that the user reviewed in the date range
- `open_prs`: all currently open authored PRs regardless of date — for planning only, not "yesterday"

PRs include a `url` but not the body. Use `gh pr view <url>` to fetch details when needed. Do not re-run the script for a different date unless you have a specific reason — the default is correct for a normal standup.

**Prioritize conversations over PRs.** Substantial conversations (especially high-turn ones) represent the user's actual focus — lead with those. Start by scanning conversation **names** and **turn counts** to identify the main work streams before diving into details. High-turn new conversations are where the day's effort went; continued conversations with high turns are ongoing multi-day threads that provide context. PRs that were `is_new: false` and merely merged in the date range were likely completed earlier and just landed; don't list them as yesterday's work unless a conversation confirms active effort. Commits and PRs are supporting evidence, not the primary signal.

Treat work on skills, tooling, and developer workflows as first-class deliverables — not secondary to product features. If the user built or shipped a skill, it deserves a standup bullet just like any other shipped work.

Also incorporate anything the user mentions directly. Omit trivial items. Aim for 4–8 bullets that reflect where the user's time actually went, not an exhaustive list of everything that shipped.

### 4. Suggest Today's Plans

Before asking, propose a "Today" section based on available data:

- **Carry-overs**: Items from the previous standup's *Today* section that don't appear in yesterday's completed work
- **Open PRs**: Only PRs that clearly need action soon (recently updated, CI failures, pending reviews) — skip stale PRs that haven't been touched in days
- **Follow-ups**: Natural next steps from yesterday's substantial work (e.g. "continue X" if a conversation or PR was clearly in progress)

Present the suggestions as a draft list and ask the user to confirm, edit, or add items (meetings, focus work, blockers).

### 5. Format the Standup

The Slack MCP tools use standard markdown (not Slack mrkdwn):
- `**Yesterday**` / `**Today**` for bold section headers (single `*` renders italic)
- `-` for bullet items
- 4-space indent with `-` for sub-items
- Blank line before and after each section header
- No "Blockers" section unless explicitly mentioned

### 6. Post as Draft

**Always draft first** via `slack_send_message_draft` with `channel_id`, `message`, and `thread_ts`. Only send directly if the user explicitly asks.

### 7. Save Daily Log

Write a markdown file alongside the YAML: `~/.standups/<year>/W<week>/<today>.md`. Include:

1. **Standup** — the exact message posted to Slack
2. **Context** — a longer-form summary of yesterday's work with more detail than the standup bullets: what problems were solved, key decisions made, notable code changes, and anything else worth remembering

Keep the context concise but richer than the standup — a few sentences per topic rather than one-line bullets.

## Example

Standup message:

```
**Yesterday**

- Finished hyperparameter search integration in the training pipeline
- Finished CLI binary size experiment
- Worked on estimating memory limits and integrating the new search into the SDK

**Today**

- Client and partner meetings
- Roadmap meeting
- 1:1s
- Continue work on memory limit estimation and SDK integration
```

Daily log (`2026-03-04.md`):

```markdown
# 2026-03-04

## Standup

[same as above]

## Context

Integrated Optuna-based hyperparameter search into the embedding finetuning pipeline,
replacing the manual grid search. This required reworking the training loop to yield intermediate
metrics that Optuna can prune on. PR #2605.

The CLI binary size experiment showed ~15% size reduction with UPX but introduced a 3s startup
penalty. Decided not to ship it compressed — the download size savings aren't worth the cold-start
cost for CLI users.

Started on GPU batch size limit estimation for embedding models — the goal is to auto-detect
the largest batch that fits in VRAM rather than requiring users to configure it manually.
Got a working prototype using a binary search over dummy forward passes.
```

## Common Mistakes

- Using `*text*` for headers — renders as italic; use `**text**` for bold
- Using `•` unicode character instead of `-` for bullets
- Forgetting `thread_ts` — standup must be a thread reply
- Sending directly without drafting first
- Not checking if a standup was already posted today before drafting
- Confusing `open_prs` dates with the analysis date range — `open_prs` always reflects current state
- Treating "PR merged in date range" as "worked on that day" — PRs often land days after the actual work; cross-reference with conversations before including
- Listing every shipped artifact instead of focusing on where the user's time went — the standup should reflect effort and priorities, not a changelog
- Re-running the script for "today" — the default (yesterday) is what the standup needs
- Mentioning routine dependency update PRs and reviews of minor PRs — these aren't worth a standup bullet unless they were unusually involved
