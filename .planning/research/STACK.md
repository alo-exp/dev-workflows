# Stack Research

**Domain:** AI-driven spec creation, external artifact ingestion, multi-repo orchestration
**Researched:** 2026-04-09
**Confidence:** MEDIUM — MCP connector schemas verified via community sources and GitHub; official Atlassian tool listing incomplete in public docs

---

## Scope

This file covers ONLY the stack additions needed for the v0.14.0 milestone. The existing SB stack (Node.js, shell hooks, markdown skills, GSD/Superpowers/Engineering/Design plugins) is already validated and out of scope.

Four capabilities require stack investigation:

1. JIRA ingestion via MCP connector
2. Figma design extraction via MCP connector
3. Google Docs/PPT ingestion via MCP or CLI
4. Multi-repo spec referencing between main and mobile repos

---

## 1. JIRA Ingestion — Atlassian MCP Connector

### Recommended: Official Atlassian Remote MCP Server

| Item | Detail |
|------|--------|
| Source | `atlassian/atlassian-mcp-server` (official) or `sooperset/mcp-atlassian` (community, 72 tools) |
| Transport | SSE (deprecated after 2026-06-30) → migrate to API token + stdio |
| Auth | API token (stable, no re-auth mid-session) or OAuth 2.1 |
| Tool names (verified) | `jira_search` (JQL or natural language), `jira_get_issue`, `jira_create_issue`, `jira_update_issue`, `jira_transition_issue` |

**Data returned by `jira_get_issue`** (MEDIUM confidence — confirmed from community sources, not official schema):

- Issue key, summary, description (full text)
- Status, assignee, reporter, priority, labels, components
- Acceptance criteria field (separate from description in newer Jira projects)
- Epic metadata and custom fields
- Linked issues (issue keys + link type)
- Attachment *metadata* (filename, URL, MIME type) — **NOT attachment content**
- Embedded Confluence page URLs in description

**Critical gap — attachment content is not returned.** If a JIRA ticket links to a PDF or image attachment, the MCP returns metadata only. Actual content fetch requires a separate HTTP call or a dedicated Google Drive / Confluence MCP. Track issue: `sooperset/mcp-atlassian#589`.

**Confluence content** (linked pages from JIRA descriptions): fetched via `confluence_get_page` — returns full page markdown. This IS available.

### How SB Skills Invoke It

SB skills invoke MCP tools via natural-language instructions in SKILL.md. When a skill says "fetch JIRA ticket {key}", Claude identifies the configured MCP server and calls `jira_get_issue`. No custom Node.js wrappers needed — the MCP transport handles authentication and request lifecycle.

**Integration point:** Create a new `silver-spec-ingest` skill that:
1. Accepts JIRA ticket key as `$ARGUMENTS`
2. Calls `jira_get_issue` to pull ticket fields
3. Calls `confluence_get_page` for each linked Confluence URL found in the description
4. Assembles a structured context object (ticket summary, description, AC, linked Confluence pages)
5. Passes assembled context to the AI-driven spec creation skill as input

### Configuration (user-side, not SB-side)

SB does NOT configure MCP servers — that is Claude Desktop / Claude Code configuration owned by the user. SB skill instructions should include a prerequisite check:

```bash
# Skill prerequisite check pattern (inline in SKILL.md)
# Verify Atlassian MCP is configured before proceeding
```

Document the required Claude config in `silver-bullet.md` prerequisites section, not in SB code.

---

## 2. Figma Design Extraction — Figma MCP Server

### Recommended: Official Figma MCP Server (Remote)

| Item | Detail |
|------|--------|
| Source | Official Figma remote MCP server (not third-party) |
| Status | Beta — free during beta, usage-based paid after |
| Supported clients | Claude Code, VS Code, Cursor, Windsurf, Codex |
| Transport | Remote MCP (SSE) — no local install required |

**Tools / data available** (MEDIUM confidence — official docs light on schema):

- `get_design_context` — structured representation of a Figma selection (React + Tailwind approximation); translatable to any framework
- `get_variable_defs` — design tokens: color values, spacing, typography from selected frames
- Component names, layout structure, layer hierarchy
- FigJam diagram content
- Variables and styles used in a selection

**Key limitation:** Write-to-canvas (creating Figma content from code) requires the remote server and will become paid. For SB's purpose (reading/extracting design context into specs), read-only extraction is sufficient and the current free beta covers it.

**What Figma MCP does NOT return:**

- Full design file as exportable assets
- PNG/SVG renders of components (requires Figma REST API export, not MCP)
- Prototype flow definitions (partially — FigJam content is accessible but flow logic is limited)

### How SB Skills Invoke It

Same pattern as Atlassian: natural-language instructions in SKILL.md. "Extract design context from the selected Figma frame" triggers Claude to call `get_design_context`.

**Constraint:** The user must have the target Figma frame open and selected in Figma before invoking the skill. SB skill must include a prompt step: "Open the Figma file and select the frame(s) you want to extract, then continue."

**Integration point:** Create a `silver-spec-ingest` skill step (shared with JIRA ingestion) that includes an optional Figma branch:
1. Ask: "Do you have a Figma design to incorporate? (Y/N)"
2. If Y: prompt user to select frame in Figma, then call `get_design_context` + `get_variable_defs`
3. Append extracted design tokens and component structure to spec context object

---

## 3. Google Docs / PPT Ingestion

### Recommended: Community Google Drive MCP or Google Workspace CLI

Two viable options — choose based on user environment:

**Option A: Google Drive MCP Server (Claude Desktop)**

| Item | Detail |
|------|--------|
| Source | `piotr-agier/google-drive-mcp` or `a-bonus/google-docs-mcp` (community, not official Google) |
| Confidence | LOW — no official Google MCP server as of research date |
| Auth | OAuth 2.0 (requires user to grant access) |
| Transport | stdio (local Claude Desktop) |

Capabilities: read Google Docs content, Sheets data, Slides text, Drive file search/navigation, manage folders.

**Option B: Google Workspace CLI (recommended when Claude Code is the client)**

| Item | Detail |
|------|--------|
| Source | Google open-source Workspace CLI |
| Confidence | MEDIUM — Google-published, documented |
| Auth | Service account or OAuth |
| Transport | Shell subprocess from skill |

Capabilities: read Google Docs as structured markdown, read Sheets as CSV/JSON, Drive file listing. Better for agentic shell-based workflows than MCP.

**PPT/PPTX ingestion gap:** Neither option has strong PowerPoint native support. Google Slides content is readable as text via the Workspace CLI (slide text, speaker notes). Binary .pptx files from non-Google sources are not directly readable — convert to Google Slides first, or accept text-only extraction.

**Recommendation:** Default to community Google Drive MCP for Claude Desktop users. For Claude Code environments, use the Workspace CLI via Bash tool in skill steps. SB skill should detect the environment and branch accordingly, or document both paths in `silver-bullet.md`.

### Integration point

Add a `silver-spec-ingest` skill step for Google Docs:
1. Accept a Google Doc URL or file name as input
2. Call Drive MCP `read_document` (or Workspace CLI equivalent) to fetch content as markdown
3. Append to spec context object alongside JIRA and Figma content

---

## 4. Multi-Repo Spec Referencing

### Recommended: "Spine" / Virtual Monorepo Pattern (zero new tooling)

| Item | Detail |
|------|--------|
| Approach | CLAUDE.md context layering + explicit spec file paths |
| Tooling | None — standard git, markdown, and bash |
| Confidence | HIGH — well-documented community pattern, no experimental features |

**Pattern:**

Main repo (silver-bullet or project main repo) holds canonical specs in `.planning/specs/`. Mobile/secondary repos reference them by absolute path or relative-to-workspace path in their own `silver-bullet.md` or `CLAUDE.md`:

```markdown
## Spec Source of Truth
Main repo specs: ~/projects/main-repo/.planning/specs/
Reference before implementing: read the relevant spec file before writing any code.
```

**How it works in practice:**

1. Main repo spec creation produces `.planning/specs/FEATURE-NAME.md` (standardized format)
2. Mobile repo's `silver-bullet.md` includes a "Spec References" section pointing to main repo paths
3. When a mobile repo session starts, the SB `silver-init` hook or session preamble reads the referenced spec file
4. SB skill in the mobile repo reads the spec and uses it as ground truth for implementation

**No symlinks, no git submodules** — those have known issues with Claude Code's Glob/Grep/LS tools not traversing submodule boundaries. Plain file path references in markdown are simpler and more reliable.

**Alternative: Git subtree (read-only)** — pull specs from main repo into mobile repo's `.planning/specs/` as a git subtree sync. More operationally complex, useful only if mobile repo CI needs specs without main repo access. Avoid unless required.

### What NOT to use

| Avoid | Why |
|-------|-----|
| Git submodules for spec sharing | Claude Code tools don't traverse submodule boundaries; symlink discovery issues |
| Copying spec files manually | Drift risk; no single source of truth |
| Shared npm package with specs | Overkill; specs are text files, not code |

---

## Stack Summary: What SB v0.14.0 Actually Needs

| Need | Solution | New Code Required? |
|------|----------|--------------------|
| JIRA ticket ingestion | Official Atlassian MCP (user-configured) | No — new SKILL.md only |
| Confluence linked page fetch | `confluence_get_page` via same MCP | No — part of same skill |
| Figma design extraction | Official Figma remote MCP (user-configured) | No — new SKILL.md step |
| Google Docs ingestion | Community Google Drive MCP or Workspace CLI | No — new SKILL.md step |
| Multi-repo spec references | Plain path references in silver-bullet.md | No — documentation + silver-bullet.md template update |
| Spec output format | Standardized markdown files in `.planning/specs/` | New directory convention only |
| Orchestration skill | `silver-spec-ingest` skill + `silver-spec-create` skill | Yes — 2 new SKILL.md files |

**Zero custom API integrations.** All external data access goes through MCP connectors that the user configures in their Claude Desktop / Claude Code environment. SB's job is to orchestrate the calls via skill instructions, not to implement the transport layer.

---

## Skill Architecture for New Capabilities

New skills to create (SKILL.md only, no Node.js):

| Skill | Purpose |
|-------|---------|
| `silver-spec-ingest` | Ingest JIRA ticket + linked artifacts (Confluence, Figma, Google Docs) into a structured context object |
| `silver-spec-create` | AI-driven requirements elicitation + spec authoring, consuming context from silver-spec-ingest |

Both plug into the existing `silver-feature` workflow at Step 1c (before brainstorm), replacing or supplementing the brainstorm when a JIRA ticket or external artifacts are the primary inputs.

---

## Alternatives Considered

| Recommended | Alternative | Why Not |
|-------------|-------------|---------|
| Official Atlassian MCP | Custom JIRA REST API client (Node.js) | Custom integrations are explicitly out of scope per PROJECT.md; MCP handles auth, rate limiting, and permission scoping |
| Official Figma remote MCP | Third-party `arinspunk/claude-talk-to-figma-mcp` | Official is maintained by Figma; third-party requires WebSocket relay server setup |
| Community Google Drive MCP | Hardcoded Google Drive REST API calls | Same reason as JIRA — MCP pattern is consistent with project philosophy |
| Spine/path-reference pattern | Git submodules | Submodule boundaries block Claude Code's file traversal tools |

---

## What NOT to Build

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Custom JIRA REST client in Node.js | Reinvents what Atlassian MCP provides; violates PROJECT.md "Out of Scope" constraint | Atlassian MCP connector |
| Custom Figma REST export pipeline | Reinvents Figma MCP; adds maintenance burden | Figma remote MCP |
| Attachment content fetching for JIRA | Not supported by any MCP today; would require custom REST + storage | Document limitation; accept text fields only |
| .pptx binary parsing | No reliable Node.js approach; requires LibreOffice or cloud conversion | Accept Google Slides text extraction only; document limitation |
| Centralized spec sync daemon | Operational complexity; solves a problem users don't have if path references work | Plain markdown path references |

---

## Prerequisites for Users (document in silver-bullet.md)

Users must have these MCP servers configured before using JIRA/Figma/Google ingestion features:

1. **JIRA:** Atlassian MCP server configured in `~/.claude/claude_desktop_config.json` with valid API token
2. **Figma:** Figma remote MCP server connected to their Figma account
3. **Google Docs:** Google Drive MCP or Workspace CLI authenticated with OAuth
4. **Multi-repo:** Mobile repos must have `silver-bullet.md` updated with main repo spec path

SB `silver-spec-ingest` skill should include a prerequisite check step that verifies MCP connectivity before attempting ingestion.

---

## Sources

- [Atlassian Remote MCP Server (official)](https://www.atlassian.com/platform/remote-mcp-server) — capability overview, MEDIUM confidence
- [sooperset/mcp-atlassian GitHub](https://github.com/sooperset/mcp-atlassian) — 72 tools, community implementation, HIGH confidence for tool inventory
- [JIRA attachment limitation issue #589](https://github.com/sooperset/mcp-atlassian/issues/589) — confirmed attachment content not supported
- [Atlassian MCP attachment feature request #15](https://github.com/atlassian/atlassian-mcp-server/issues/15) — official server also lacks attachment download
- [Figma MCP Server guide (official)](https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server) — capabilities overview, MEDIUM confidence
- [piotr-agier/google-drive-mcp](https://github.com/piotr-agier/google-drive-mcp) — community Google Drive MCP, LOW confidence (unofficial)
- [Google Cloud MCP servers overview](https://docs.cloud.google.com/mcp/overview) — official Google MCP landscape
- [Virtual Monorepo Pattern](https://medium.com/devops-ai/the-virtual-monorepo-pattern-how-i-gave-claude-code-full-system-context-across-35-repos-43b310c97db8) — multi-repo context approach, MEDIUM confidence
- [Spine Pattern for multi-repo](https://tsoporan.com/blog/spine-pattern-multi-repo-ai-development/) — alternative multi-repo pattern reference

---
*Stack research for: Silver Bullet v0.14.0 — AI-driven spec, external artifact ingestion, multi-repo orchestration*
*Researched: 2026-04-09*
