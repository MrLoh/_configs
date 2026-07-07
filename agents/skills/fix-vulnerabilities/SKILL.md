---
name: fix-vulnerabilities
description: Fix dependency CVEs in Poetry and Yarn projects.
---

# Fix Vulnerabilities

Guidelines for fixing security vulnerabilities in Poetry (Python) and Yarn (Node.js) projects with minimal, targeted changes.

## Fetching Dependabot alerts

You can fetch vulnerability scan results from Dependabot via the GitHub API. Requires `gh` CLI and a token with `repo` or `security_events` scope (e.g. `GH_TOKEN`). `gh api` auto-resolves `{owner}/{repo}` to the current repo's GitHub remote.

**List open alerts** (summary):

```bash
gh api repos/{owner}/{repo}/dependabot/alerts --paginate \
  -q '.[] | select(.state == "open") | {number, package: .dependency.package.name, ecosystem: .dependency.package.ecosystem, severity: .security_vulnerability.severity, manifest: .dependency.manifest_path, summary: .security_advisory.summary}'
```

**Filter by ecosystem** (e.g. pip, npm):

```bash
gh api "repos/{owner}/{repo}/dependabot/alerts?ecosystem=pip&state=open" --paginate
```

**Filter by severity** (low, medium, high, critical):

```bash
gh api "repos/{owner}/{repo}/dependabot/alerts?severity=high&state=open" --paginate
```

**Get full details for one alert** (includes patched versions, CVEs):

```bash
gh api repos/{owner}/{repo}/dependabot/alerts/ALERT_NUMBER
```

The response includes `security_vulnerability.first_patched_version` and `security_advisory.cves` for remediation.

**REST API reference**: [GitHub Dependabot alerts API](https://docs.github.com/en/rest/dependabot/alerts)

## Local vulnerability scans (Trivy)

If the monorepo uses [Trivy](https://aquasecurity.github.io/trivy/) to scan dependencies, install with `brew install trivy` or follow [Trivy installation](https://trivy.dev/latest/getting-started/installation/).

**Scan all subprojects** (from repo root, if using Nx or a similar task runner):

```bash
yarn vulnerabilities
# or
nx run-many -t vulnerabilities -p <project1> <project2> ...
```

**Scan a single subproject** (from the project directory): use whichever package manager the subproject uses, e.g. `poetry run vulnerabilities` for a Poetry project, `yarn vulnerabilities` for a Yarn project. Check the subproject's `pyproject.toml` / `package.json` scripts for the exact task name.

**Docker image scans** (requires built images): if the subproject exposes a `docker-vulnerabilities` script/target, run it from the project directory (e.g. `poetry run docker-vulnerabilities`, `yarn docker-vulnerabilities`).

Prefer running Trivy with `--scanners vuln --ignore-unfixed`. CVEs can be temporarily ignored via a `.trivyignore.yml` at the repo root (include `expired_at` and `statement` per policy).

## Principles

- **Minimal edits**: Prefer lockfile-only updates. Avoid unnecessary edits to `package.json` or `pyproject.toml` unless required.
- **Targeted updates**: Update only the vulnerable packages, not all dependencies.
- **Verify constraints**: After fixing, ensure `pyproject.toml` / `package.json` constraints prevent regression to vulnerable versions.

## Poetry (Python)

### Workspace layout

- **Root**: `pyproject.toml` declares workspace dependencies (e.g. `research = { path = "research", develop = true }`). Its `poetry.lock` aggregates dependencies from all child projects.
- **Child projects**: Each has its own `pyproject.toml` and optionally its own `poetry.lock`.

### Commands

- **Child project**: Run `poetry update <package>` in the child project directory to update only that package.
- **Root**: Run `poetry lock` in the root after updating children — do **not** run `poetry update` without a package name.

### Critical: avoid full `poetry update`

**Never** run `poetry update` without specifying a package. That updates *all* dependencies to latest compatible versions and causes:

- Massive lockfile changes
- Potential CI failures from unrelated transitive packages bumping to new major versions
- Unnecessary type-checker or runtime breakage

### Workflow

1. Identify the vulnerable package and the fixed version (e.g. from CVE or audit).
2. If the constraint in `pyproject.toml` allows the vulnerable version (e.g. `^3.9.1` when 3.9.2 is vulnerable), update the constraint to require the patched version (e.g. `^3.9.3`).
3. In the child project: `poetry update <package>`.
4. In the root: `poetry lock`.

### Example: NLTK

- Vulnerability fixed in 3.9.3.
- If `research/pyproject.toml` has `nltk = "^3.9.1"`, change to `nltk = "^3.9.3"` so future resolves cannot regress.
- Run `poetry update nltk` in `research/`, then `poetry lock` in the root.

## Yarn (Node.js)

### Strategies (in order of preference)

1. **Update parent**: If a direct dependency can be updated to a version that pulls in the patched transitive dependency, do that first.
2. **Lockfile-only**: Use resolution temporarily to update the lockfile, then remove it. Commit only `yarn.lock`.
3. **Resolutions** (permanent): Only when the parent's constraint forbids the patched version (e.g. `~6.14.0` when fix is 6.15.0).

### Workflow

- **Direct dependency:** `yarn add <package>@<fixed-version>`.
- **Transitive dependency:** Add `"resolutions": { "<package>": "<fixed-version>" }`, run `yarn install`, remove the resolution, run `yarn install` again. Commit only `yarn.lock`.

Note: `yarn add` + remove reverts the lockfile; use resolution + remove instead.

### Example: dompurify (transitive via maildev)

- Fixed in 3.2.7. Parent has `dompurify ^3.1.6`.
- Add resolution, `yarn install`, remove resolution, `yarn install`. Commit `yarn.lock` only.

### Example: qs (transitive via express)

- Fixed in 6.15.0. `express` constrains `qs` to `~6.14.0` (excludes 6.15.0).
- Keep resolution: `"qs": "6.15.0"` in `resolutions`.

## Verification

- Run `poetry lock --no-update` (or equivalent) to confirm lockfiles are consistent.
- **PR/changelog:** If the fix is lockfile-only (no `package.json` changes), say "lockfile update" or "pinned X to Y in lockfile" — not "added resolution".
- Run relevant tests and typecheck for affected projects.
- For Poetry: confirm the lockfile shows the patched version for the vulnerable package.
- For Yarn: confirm `yarn.lock` has the patched version and no vulnerable entries.

## Common pitfalls

- **Poetry**: Running `poetry update` without a package name — causes full dependency refresh and widespread changes.
- **Yarn**: Keeping `resolutions` when lockfile-only would work — add resolution, `yarn install`, remove it, `yarn install` again; commit only `yarn.lock`.
- **Poetry**: Forgetting to run `poetry lock` in the root after updating a child project.
- **Constraints**: Leaving `pyproject.toml` constraints that allow vulnerable versions — update the minimum version to the patched release.
