# Help Center Content Guidelines

A complete guide to building and writing Ālo Labs help center pages. Covers architecture, page types, content structure, and writing standards.

---

## Help Center Architecture

Every product ships a help center at `/help/` under the product subdomain. The help center is a static site (same stack as the homepage) using shared tokens from `tokens.css`.

```
/help/
  index.html                    ← Help Center Home
  search.js                     ← Client-side search index
  getting-started/
    index.html
  concepts/
    index.html                  ← Core concepts overview
    cost-optimization.html      ← Sub-concept page
    preferences.html
    routing-logic.html
    session-startup.html
    verification.html
  dev-workflow/
    index.html
  devops-workflow/
    index.html
  workflows/
    index.html                  ← Workflow catalog
    silver-feature.html
    silver-bugfix.html
    silver-ui.html
    silver-devops.html
    silver-research.html
    silver-release.html
    silver-fast.html
  reference/
    index.html
  troubleshooting/
    index.html
```

---

## Page Types

### 1. Help Center Home (`/help/index.html`)

The entry point. Combines a search hero, quick-link grid, and large documentation cards.

**Sections:**
1. Hero with search input
2. Quick Links grid (10 items, 4-col)
3. Main Cards grid (all doc sections, 3-col)
4. Bottom callout
5. Footer

### 2. Long-Form Reference Doc

Dense, scrollable single page. Has sidebar navigation. Used for dev-workflow, devops-workflow, reference.

**Structure:**
- Page hero (title + 1-sentence description)
- `doc-layout` (220px sidebar + 1fr content)
  - Sidebar: sticky nav with section links
  - Content: h2s, step cards, phase headers, callouts, dividers
- Page bottom nav (prev/next)
- Footer

### 3. Concept Explainer

Medium-length page. No step cards. Uses prose + callouts + tables + code blocks. Examples: concepts/index.html, concepts/cost-optimization.html.

### 4. Quick Reference

Short page. Uses tables, code blocks, structured lists. Example: reference/index.html (command tables, config options).

### 5. Workflow Single Page

Describes one specific workflow (e.g., `/silver:feature`). Shows: what it does, when to use it, steps in order, outputs. Short to medium length.

---

## Help Center Home: Content Rules

### Hero

- Badge: `<i data-lucide="book-open"></i> Help Center`
- `<h1>`: `How Can We Help You?`
- `<p>`: 1 sentence. Describe scope: from first install to the most advanced use case.
- Search input: placeholder `Search topics, commands, concepts…`

### Quick Links Grid

10 links in a 4-col grid. Rules:
- Labels in **Title Case** (e.g., "Dev Workflow", not "dev workflow")
- Ordered logically: **entry → core concepts → workflows → reference**
- Standard ordering:
  1. Quick Start
  2. Installation
  3. What Are Skills?
  4. Session Modes
  5. Dev Workflow
  6. DevOps Workflow
  7. Workflows
  8. Enforcement Layers
  9. Command Reference
  10. Cost Optimization

Each link: icon + label. Icon from Lucide, chosen semantically:
- `rocket` → getting started / quick start
- `package` → installation
- `puzzle` → skills / concepts
- `sliders-horizontal` → session modes
- `settings` → dev workflow
- `hard-hat` → devops workflow
- `git-branch-plus` → workflows / orchestration
- `lock` → enforcement
- `clipboard-list` → reference / commands
- `cpu` → cost / optimization

### Main Card Grid

One card per doc section. 3-col grid. Each card:
- **Icon:** 2rem Lucide icon
- **Badge:** short label with color (see badge palette below)
- **Title:** The section name. Title case.
- **Description:** 1–2 sentences. What will the reader learn? What can they do after reading?
- **Topics list:** 4–6 bullet points, specific. These are actual section headings inside the page.
- **CTA:** `Read guide →` or `Browse reference →` or `Explore {topic} →`

**Card badge palette:**
| Color | Semantic |
|-------|---------|
| Green (`var(--green)`) | "Start here" — entry points |
| Gray (`var(--accent-light)`) | "Fundamentals", "Workflow", version labels |
| Amber (`var(--amber)`) | "Reference", "Commands" |
| Cyan (`var(--cyan)`) | "DevOps" |
| Red (`var(--red)`) | "Troubleshooting", issue count |

### Bottom Callout

One callout at the end. Encourages a reading sequence for beginners. Pattern:

```
**New to {topic}?** {Product} works best when... Start with [Getting Started], 
then [Core Concepts] before diving into workflows.
```

---

## Doc Page: Structural Rules

### Page Hero

```html
<div class="breadcrumb-nav"><a href="../">Help Center</a><span>/</span><span>Page Title</span></div>
<h1>Full Page Title</h1>
<p>One sentence. What does this page cover? Who should read it?</p>
```

The description should complete the pattern: "The complete X-step Y cycle — from A through B, C, and D."

### Sidebar Navigation

Groups:
1. **Overview** — "How It Works", "Overview", 1–2 orientation links
2. **[Content groups]** — mirror the major h2 sections on the page
3. **Rules** — anti-patterns, constraints, enforcement rules (if applicable)

Sidebar link labels follow the content exactly. If the h2 says "Project Initialization", the sidebar link says "Initialization" (can abbreviate but must not rename).

### Section Structure Inside Doc

```
h2 (major section)
  p (orientation text — 1–2 sentences setting up what follows)
  [optional: callout]
  [optional: ul/ol list]
  step-card OR content block
  step-card
  [optional: callout]
  divider (between major phases/sections)

h2 (next section)
  ...
```

### Dividers

Use `<div class="divider"></div>` between major logical groupings. Not between every card — only between phases or sections that represent a shift in context (e.g., between Initialization and Per-Phase Loop, between Finalization and Deployment).

### Page Bottom Nav

Always include `prev` and `next` links at the bottom:

```html
<div class="page-nav-bottom">
  <a href="../prev-page/">
    <span class="pnb-label">← Previous</span>
    <span class="pnb-title">Page Name</span>
  </a>
  <a href="../next-page/" style="text-align:right">
    <span class="pnb-label">Next →</span>
    <span class="pnb-title">Page Name</span>
  </a>
</div>
```

---

## Step Cards: Writing Rules

Used in workflow documentation pages (dev-workflow, devops-workflow, workflow single pages).

### Numbering

- Sequential integers: 0, 1, 2, 3…
- Sub-steps use letter suffixes: `17a`, `17b`, `17c` — where the letters represent ordered sub-steps within a phase, not versions.
- **Rule:** A lettered sub-step (e.g., `17a`) must NEVER be followed by the base integer (`17`). If gates precede a step, they take the lower letters; the main step takes the next letter or the next integer.
- Step 0 is allowed and conventional for "pre-condition" or "mode selection" that precedes formal numbering.

### Number Circle Colors

Color encodes phase:

| Phase | Gradient |
|-------|----------|
| Init / Finalization | `#374151 → #6b7280` (gray) |
| Session Setup | `#64748b → #475569` (slate) |
| Discuss | `var(--cyan) → #0891b2` |
| Quality Gates | `var(--red) → #b91c1c` |
| Plan / Post-Review | `var(--accent) → var(--accent2)` |
| Execute | `var(--green) → #047857` |
| Verify / Code Review | `var(--amber) → #b45309` |
| Artifact Gates | `#7c3aed → #5b21b6` (purple) |
| CI/CD / Deploy | `var(--cyan) → #0e7490` |
| Ship | `var(--green) → #047857` |

### Card Content

```
[step-num circle]  [step-title]  [badges: Required / GSD / Superpowers / Engineering / Conditional]
                   [step-desc: 2–4 sentences. What happens. How. Key constraint or output.]
                   [step-output: → Produces: specific file or artifact]
```

**Badge types:**
- `Required` (red): must not skip
- `GSD` (gray/accent): dispatches a GSD subagent
- `Superpowers` (green): uses Superpowers plugin
- `Engineering` (amber): human engineering judgment required
- `Conditional` (amber): only runs under specific conditions

### Phase Headers

A colored pill-shaped label that introduces a group of step cards:

```html
<div class="phase-header phase-discuss">Phase: Discuss</div>
```

CSS classes: `phase-discuss` | `phase-gates` | `phase-plan` | `phase-exec` | `phase-verify` | `phase-final` | `phase-deploy` | `phase-ship`

Phase headers sit 52px above their first step card and 24px below.

---

## Callout Types

| Type | Use when |
|------|----------|
| `callout-tip` | Suggesting a shortcut or best practice |
| `callout-info` | Adding context or explaining a nuance |
| `callout-warn` | Flagging a common mistake or anti-pattern |
| `callout-stop` | Hard rule that blocks proceeding — never skip |

Callout icon uses a Lucide icon: `zap` (tip), `lightbulb` (info), `triangle-alert` (warn), `ban` (stop).

**Stop callouts must use imperative language:**  
`**[Phase X] cannot start until [prerequisite] passes.** This is enforced by [mechanism].`

---

## Concept Pages: Writing Rules

### Concept Page Index (`concepts/index.html`)

One long page covering all core concepts. Each concept is a major h2 with:
- 1–2 paragraphs of explanation
- Optionally: a table, list, or code block
- Optional callout for a key rule or gotcha

Order: foundational → system-level → advanced.

### Concept Sub-Page

A single concept in depth. Structure:
- What it is (definition)
- Why it matters (motivation)
- How it works (mechanism — often a list or table)
- Configuration (if applicable — code block)
- Related concepts (links)

---

## Reference Page

A command/API reference uses tables as the primary structure:

```
h2: Category Name
  table: Command | Description | Notes
  
h2: Next Category
  ...
```

Table columns for commands:
- Command (font-mono, `--text-primary`, `font-weight: 600`)
- What it does
- When to use / notes

For config options:
- Key | Type | Default | Description

---

## Workflow Single Pages

One page per `/silver:{name}` workflow. Standard sections:

1. **What It Does** — 1 paragraph. Who uses it, what it produces.
2. **When to Use** — bulleted list. 3–5 scenarios where this workflow is correct.
3. **Steps** — step-card list or numbered prose. Brief per step (not the full dev-workflow detail).
4. **Outputs** — what artifacts are produced.
5. **Related** — links to related pages.

---

## Writing Standards

### Voice and Tone

- **Second person:** Write to "you" — the developer using the product.
- **Present tense:** "Claude runs the quality gates", not "Claude will run..."
- **Active voice:** "GSD dispatches parallel agents", not "Agents are dispatched by GSD"
- **Specific:** Name the exact file, command, or mechanism. No vague references.
- **No hedging:** Don't write "may", "might", "could" when describing how the system works. If it does X, say it does X.

### Body Text

- `color: var(--text-secondary)` (inherited via `p { color: var(--text-secondary) }`)
- **Never** apply `color: var(--green)` or any accent to body text. Body text is neutral.
- `line-height: 1.7`–`1.8`

### Code in Body

Inline code uses backtick-style in markdown but is rendered with:
```html
<code>/silver:feature</code>
```
Color: `var(--accent-light)`. Background: `var(--bg-code)`. Padding: `2px 6px`. Radius: `4px`.

### Links in Body

```css
.doc-content a { color: var(--accent-light); }
```

Use `style="color:var(--accent-light);font-weight:600"` for inline styled links in callouts.

### Lists

- `ul`/`ol` body text: `color: var(--text-secondary)`, `padding-left: 20px`
- `li` spacing: `margin-bottom: 5px`
- Feature/topic lists in cards: no bullet, use `→` pseudo-element

---

## Search Integration

The help center uses client-side search via `search.js`. Each page must have a `data-keywords` attribute on its card in `help/index.html`:

```html
<a href="dev-workflow/" class="help-card" data-keywords="workflow steps discuss plan execute verify ship">
```

Keywords should include: topic nouns, command names, file names, phase names, error messages users might search for.

---

## Footer (Help Pages)

Same structure as homepage footer. Three parts:
- Left: `<span style="font-weight:700">Product Name</span> Help Center`
- Center: `Innovated at Ālo Labs` (link: `font-weight:700; text-decoration:none`)
- Right: `Home` | `GitHub` | `MIT License`

"Home" link uses `../` (relative, goes to product homepage).

---

## Token File Requirement

Every help page must link `tokens.css`:

```html
<!-- From /help/page/index.html -->
<link rel="stylesheet" href="../../tokens.css">

<!-- From /help/index.html -->
<link rel="stylesheet" href="../tokens.css">
```

This is the single source of truth for all color tokens. Never redeclare `:root {}` or `[data-theme="dark"] {}` inline in help pages.

---

## Checklist: New Doc Page

- [ ] Links `tokens.css` at correct relative path
- [ ] Fixed nav with breadcrumb: `Product / Help / Page`
- [ ] `page-hero` with breadcrumb-nav + h1 + p
- [ ] Sidebar nav mirroring h2 sections
- [ ] All headings use `var(--heading-muted)` in dark mode (handled via `tokens.css`)
- [ ] Body text `color: var(--text-secondary)` — not green
- [ ] Step numbers sequential, no conflicts (17a/17b/17c pattern)
- [ ] Phase headers at correct spacing (52px top / 24px bottom)
- [ ] Step cards have 20px bottom margin
- [ ] No left-border on step cards
- [ ] Callout types match severity (stop for hard rules, warn for anti-patterns)
- [ ] Page bottom nav with prev/next
- [ ] Footer: correct Ālo Labs link format (no chrome gradient)
- [ ] `data-keywords` on the card in `help/index.html`
- [ ] Lucide icons initialized: `lucide.createIcons()`
- [ ] Theme toggle script included and functional
