#!/usr/bin/env python3
"""Gather yesterday's work from agent transcripts, git history, and GitHub PRs.

Outputs YAML with conversations (task + outcome from Cursor sessions),
commits (messages + files from git log --all), authored PRs, and reviewed PRs.
Weekend dates (Sat/Sun) snap back to the preceding Friday and cover Fri-Sun.

Requires: pyyaml (`pip install pyyaml`)

Usage:
    python3 analyze-transcripts.py                  # yesterday (or Fri-Sun on Mon)
    python3 analyze-transcripts.py --date 2026-03-04
    python3 analyze-transcripts.py --since 2026-03-01 --until 2026-03-05
"""

import argparse
import json
import os
import re
import subprocess
from datetime import datetime, timedelta
from pathlib import Path

import yaml

LOCAL_TRANSCRIPT_ROOT = Path.home() / ".cursor" / "projects"
REMOTE_HOSTS = ["shamu"]  # SSH hosts to also pull transcripts from
OUTPUT_DIR = Path.home() / ".standups"  # generated data lives outside the (version-controlled) skill dir
REMOTE_TRANSCRIPT_CACHE = OUTPUT_DIR / ".remote-cache"
LINE_COUNTS_PATH = OUTPUT_DIR / "line-counts.json"
CURSOR_WORKSPACE_STORAGE = Path.home() / "Library" / "Application Support" / "Cursor" / "User" / "workspaceStorage"


def build_title_index() -> dict[str, str]:
    """Build a composerId → conversation name index from all local Cursor workspace state dbs."""
    index: dict[str, str] = {}
    if not CURSOR_WORKSPACE_STORAGE.is_dir():
        return index
    import sqlite3
    for db_path in CURSOR_WORKSPACE_STORAGE.iterdir():
        state_db = db_path / "state.vscdb"
        if not state_db.exists():
            continue
        try:
            con = sqlite3.connect(str(state_db))
            cur = con.execute("SELECT value FROM ItemTable WHERE key='composer.composerData'")
            row = cur.fetchone()
            if row:
                data = json.loads(row[0])
                for composer in data.get("allComposers", []):
                    cid = composer.get("composerId")
                    name = composer.get("name")
                    if cid and name:
                        index[cid] = name
            con.close()
        except Exception:
            pass
    return index


def _fetch_remote_birthtimes(host: str) -> dict[str, float]:
    """SSH to remote host and return {uuid: birth_epoch} for all transcript files."""
    result = subprocess.run(
        ["ssh", host, "stat --format='%W %n' ~/.cursor/projects/*/agent-transcripts/*/*.jsonl"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        return {}
    index: dict[str, float] = {}
    for line in result.stdout.strip().splitlines():
        parts = line.split(" ", 1)
        if len(parts) != 2:
            continue
        try:
            index[Path(parts[1]).stem] = float(parts[0])
        except ValueError:
            pass
    return index


def sync_remote_transcripts() -> tuple[list[Path], dict[str, float]]:
    """Rsync transcripts and fetch remote birth times.

    Returns (cache_roots, uuid_to_birth_epoch).
    """
    roots = []
    birthtime_index: dict[str, float] = {}
    for host in REMOTE_HOSTS:
        dest = REMOTE_TRANSCRIPT_CACHE / host
        dest.mkdir(parents=True, exist_ok=True)
        birthtime_index.update(_fetch_remote_birthtimes(host))
        result = subprocess.run(
            [
                "rsync", "-a", "--quiet",
                "--include=*/", "--include=*.jsonl", "--exclude=*",
                f"{host}:~/.cursor/projects/", str(dest) + "/",
            ],
            capture_output=True, text=True,
        )
        if result.returncode == 0:
            roots.append(dest)
        else:
            print(f"Warning: could not sync transcripts from {host}: {result.stderr.strip()}", flush=True)
    return roots, birthtime_index


class _LiteralDumper(yaml.Dumper):
    pass


def _str_representer(dumper, data):
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


_LiteralDumper.add_representer(str, _str_representer)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--date", help="Single date (YYYY-MM-DD), defaults to yesterday")
    parser.add_argument("--since", help="Start date inclusive (YYYY-MM-DD)")
    parser.add_argument("--until", help="End date exclusive (YYYY-MM-DD)")
    args = parser.parse_args()

    if args.since and args.until:
        return datetime.strptime(args.since, "%Y-%m-%d"), datetime.strptime(args.until, "%Y-%m-%d")

    target = datetime.strptime(args.date, "%Y-%m-%d") if args.date else datetime.now() - timedelta(days=1)
    target = target.replace(hour=0, minute=0, second=0)
    weekday = target.weekday()
    if weekday >= 5:  # Sat/Sun -> snap back to Friday
        target -= timedelta(days=weekday - 4)
    days = 3 if target.weekday() == 4 else 1
    return target, target + timedelta(days=days)


def _workdays_back(date: datetime, n: int = 1) -> datetime:
    d = date
    for _ in range(n):
        d -= timedelta(days=1)
        while d.weekday() >= 5:
            d -= timedelta(days=1)
    return d


def _get_created_at(path: Path) -> datetime:
    """Best-effort file creation time. Uses birthtime on macOS, falls back to ctime."""
    st = os.stat(path)
    ts = getattr(st, "st_birthtime", None) or st.st_ctime
    return datetime.fromtimestamp(ts)


def find_transcripts(since: datetime, until: datetime) -> list[tuple[Path, bool]]:
    """
    Return (path, continued) tuples.

    A conversation is "new" only if it was *created* during the date range.
    If it was created earlier but still modified during the range (or the
    lookback window), it's marked continued=True.

    Uses macOS birthtime for local files and SSH stat for remote files
    (rsync doesn't preserve creation time).
    """
    remote_roots, remote_birthtimes = sync_remote_transcripts()
    all_roots = [LOCAL_TRANSCRIPT_ROOT] + remote_roots

    lookback = _workdays_back(since, 3)
    results: list[tuple[Path, bool]] = []
    for root in all_roots:
        if not root.is_dir():
            continue
        for project_dir in root.iterdir():
            transcript_dir = project_dir / "agent-transcripts"
            if not transcript_dir.is_dir():
                continue
            for conv_dir in transcript_dir.iterdir():
                for jsonl in conv_dir.glob("*.jsonl"):
                    mtime = datetime.fromtimestamp(jsonl.stat().st_mtime)
                    uuid = jsonl.stem
                    if uuid in remote_birthtimes:
                        created = datetime.fromtimestamp(remote_birthtimes[uuid])
                    else:
                        created = _get_created_at(jsonl)
                    if since <= mtime < until:
                        continued = created < since
                        results.append((jsonl, continued))
                    elif lookback <= mtime < since:
                        results.append((jsonl, True))
    return sorted(results, key=lambda t: t[0].stat().st_mtime)


def extract_user_query(text: str) -> str:
    """Pull the actual query from <user_query> tags, stripping system context."""
    match = re.search(r"<user_query>\s*(.*?)\s*</user_query>", text, re.DOTALL)
    query = match.group(1).strip() if match else text[:200].strip()
    return query[:200]


def derive_name(task: str) -> str:
    """Derive a short human-readable conversation name from the task text.

    Replaces @file references with just the filename, strips URLs and leading
    slash-commands, and truncates to ~60 chars.
    """
    text = task.strip()
    # Replace @path refs with just the basename (e.g. @src/foo.py → foo.py)
    text = re.sub(r"@(\S+)", lambda m: m.group(1).split("/")[-1].split(":")[0], text)
    # Remove URLs
    text = re.sub(r"https?://\S+", "", text)
    # Strip leading slash-commands (e.g. /standup, /pr-description)
    text = re.sub(r"^/\S+\s*", "", text)
    # Collapse whitespace
    text = " ".join(text.split())
    if len(text) > 60:
        text = text[:57].rstrip() + "..."
    return text or task[:60]


def project_name(jsonl_path: Path) -> str:
    """Extract a readable project name from the transcript path."""
    parts = jsonl_path.parts
    try:
        cache_parts = REMOTE_TRANSCRIPT_CACHE.parts
        if parts[:len(cache_parts)] == cache_parts:
            host = parts[len(cache_parts)]
            raw = parts[len(cache_parts) + 1]
            cleaned = raw.replace("home-tobias-", "").replace("Users-mrloh-", "").replace("-", "/")
            return f"{host}/{cleaned}"
    except IndexError:
        pass
    # Local paths: ~/.cursor/projects/<project>/...
    try:
        idx = parts.index("projects")
        raw = parts[idx + 1]
    except (ValueError, IndexError):
        return "unknown"
    cleaned = raw.replace("Users-mrloh-", "").replace("-", "/")
    return cleaned


def analyze_transcript(
    jsonl_path: Path,
    *,
    continued: bool = False,
    title_index: dict[str, str] | None = None,
    prev_line_counts: dict[str, int] | None = None,
) -> dict | None:
    lines = []
    with open(jsonl_path) as f:
        for raw_line in f:
            raw_line = raw_line.strip()
            if raw_line:
                lines.append(json.loads(raw_line))

    if not lines:
        return None

    user_messages = [l for l in lines if l["role"] == "user"]
    assistant_messages = [l for l in lines if l["role"] == "assistant"]

    if not user_messages:
        return None

    first_user_text = user_messages[0]["message"]["content"][0]["text"]
    task = extract_user_query(first_user_text)

    outcome = ""
    if assistant_messages:
        last_content = assistant_messages[-1]["message"]["content"]
        last_text = next((b["text"] for b in last_content if "text" in b), "")
        outcome_lines = last_text[:500].strip().splitlines()
        outcome = "\n".join(line.rstrip() for line in outcome_lines)

    total_turns = len(user_messages) + len(assistant_messages)

    conv_id = jsonl_path.stem
    cursor_title = (title_index or {}).get(conv_id)
    name = cursor_title if cursor_title else derive_name(task)

    prev = (prev_line_counts or {}).get(conv_id, 0)
    turns_in_range = max(total_turns - prev, 0)

    result = {
        "project": project_name(jsonl_path),
        "name": name,
        "task": task,
        "outcome": outcome,
        "turns": total_turns,
        "turns_in_range": turns_in_range,
        "substantial": total_turns > 6,
    }
    if continued:
        result["continued"] = True
    return result


def find_git_repos() -> list[Path]:
    """Find git repos under ~/Repos."""
    repos = []
    repos_root = Path.home() / "Repos"
    if not repos_root.is_dir():
        return repos
    for entry in repos_root.iterdir():
        if (entry / ".git").exists():
            repos.append(entry)
    return repos


def get_git_email(repo: Path) -> str:
    result = subprocess.run(
        ["git", "config", "user.email"],
        capture_output=True, text=True, cwd=repo,
    )
    return result.stdout.strip()


def git_commits(repo: Path, since: str, until: str, author: str) -> list[dict]:
    """Get commits with changed files from a repo across all branches."""
    try:
        result = subprocess.run(
            [
                "git", "log", "--all", f"--author={author}",
                f"--since={since}", f"--until={until}",
                "--oneline", "--no-merges", "--name-only",
            ],
            capture_output=True, text=True, cwd=repo,
        )
    except FileNotFoundError:
        return []

    if result.returncode != 0 or not result.stdout.strip():
        return []

    commits = []
    current = None
    for line in result.stdout.strip().split("\n"):
        if not line:
            continue
        # Commit lines have a hash prefix; file lines don't
        if re.match(r"^[0-9a-f]+ ", line):
            if current:
                commits.append(current)
            parts = line.split(" ", 1)
            current = {"hash": parts[0], "message": parts[1] if len(parts) > 1 else "", "files": []}
        elif current:
            current["files"].append(line)
    if current:
        commits.append(current)

    return commits


def _fetch_prs(repo: Path, state: str, search: str | None = None) -> list[dict]:
    cmd = [
        "gh", "pr", "list", f"--state={state}",
        "--json", "title,state,url,author,createdAt,updatedAt",
        "--limit", "20",
    ]
    if search:
        cmd += ["--search", search]
    else:
        cmd += ["--author=@me"]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=repo)
    except FileNotFoundError:
        return []
    if result.returncode != 0 or not result.stdout.strip():
        return []
    return json.loads(result.stdout)


def _in_range(pr: dict, since_date: str, until_date: str) -> bool:
    created = pr["createdAt"][:10]
    updated = pr["updatedAt"][:10]
    return since_date <= created < until_date or since_date <= updated < until_date


def gh_pull_requests(repo: Path, since: str, until: str) -> tuple[list[dict], list[dict], list[dict]]:
    """Return (date-filtered authored PRs, reviewed PRs, all currently open PRs)."""
    since_date = since[:10]
    until_date = until[:10]

    authored = [
        {"title": pr["title"].strip(), "url": pr["url"], "state": pr["state"],
         "is_new": since_date <= pr["createdAt"][:10] < until_date}
        for pr in _fetch_prs(repo, "all")
        if _in_range(pr, since_date, until_date)
    ]
    reviewed = [
        {"title": pr["title"].strip(), "url": pr["url"], "state": pr["state"],
         "author": pr["author"].get("name") or pr["author"]["login"]}
        for pr in _fetch_prs(repo, "all", search="reviewed-by:@me -author:@me")
        if _in_range(pr, since_date, until_date)
    ]
    currently_open = [
        {"title": pr["title"].strip(), "url": pr["url"], "updated": pr["updatedAt"][:10]}
        for pr in _fetch_prs(repo, "open")
    ]
    return authored, reviewed, currently_open


def main():
    since, until = parse_args()
    since_str = since.strftime("%Y-%m-%d %H:%M")
    until_str = until.strftime("%Y-%m-%d %H:%M")

    prev_line_counts: dict[str, int] = {}
    if LINE_COUNTS_PATH.exists():
        try:
            prev_line_counts = json.loads(LINE_COUNTS_PATH.read_text())
        except (json.JSONDecodeError, OSError):
            pass

    title_index = build_title_index()
    transcripts = find_transcripts(since, until)
    new_line_counts: dict[str, int] = {}
    conversations = []
    for path, continued in transcripts:
        analysis = analyze_transcript(
            path, continued=continued, title_index=title_index,
            prev_line_counts=prev_line_counts,
        )
        if analysis:
            new_line_counts[path.stem] = analysis["turns"]
            if continued and not analysis["substantial"]:
                continue
            conversations.append(analysis)

    # Merge new counts into manifest (preserve entries for conversations not in this run)
    merged_counts = {**prev_line_counts, **new_line_counts}
    LINE_COUNTS_PATH.write_text(json.dumps(merged_counts))

    repos = find_git_repos()
    seen_hashes = set()
    commits = []
    date_prs = []
    reviewed_prs = []
    open_prs = []
    seen_urls: dict[str, set] = {"authored": set(), "reviewed": set(), "open": set()}
    for repo in repos:
        author = get_git_email(repo)
        if not author:
            continue
        for c in git_commits(repo, since_str, until_str, author):
            if c["hash"] not in seen_hashes:
                seen_hashes.add(c["hash"])
                commits.append(c)
        authored, reviewed, currently_open = gh_pull_requests(repo, since_str, until_str)
        for pr in authored:
            if pr["url"] not in seen_urls["authored"]:
                seen_urls["authored"].add(pr["url"])
                date_prs.append(pr)
        for pr in reviewed:
            if pr["url"] not in seen_urls["reviewed"]:
                seen_urls["reviewed"].add(pr["url"])
                reviewed_prs.append(pr)
        for pr in currently_open:
            if pr["url"] not in seen_urls["open"]:
                seen_urls["open"].add(pr["url"])
                open_prs.append(pr)

    output = {
        "standup_date": until.strftime("%Y-%m-%d"),
        "data_range": {
            "since": since.strftime("%Y-%m-%d"),
            "until": until.strftime("%Y-%m-%d"),
        },
        "conversations": conversations,
        "commits": commits,
        "pull_requests": date_prs,
        "reviewed_prs": reviewed_prs,
        "open_prs": open_prs,
    }
    standup_date = until
    year = standup_date.strftime("%Y")
    week = standup_date.strftime("%W")
    week_dir = OUTPUT_DIR / year / f"W{week}"
    week_dir.mkdir(parents=True, exist_ok=True)
    output_path = week_dir / f"{standup_date.strftime('%Y-%m-%d')}.yaml"
    output_path.write_text(yaml.dump(output, Dumper=_LiteralDumper, default_flow_style=False, sort_keys=False, allow_unicode=True))
    print(f"Written to {output_path}")


if __name__ == "__main__":
    main()
