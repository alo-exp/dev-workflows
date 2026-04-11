# Homepage Content Guidelines

A complete playbook for writing and structuring an Ālo Labs product homepage. All sections, their purpose, copy rules, and sequencing are captured here.

---

## Page Purpose

The homepage is a technical landing page for a developer tool. It answers five questions in order:

1. What is this? (Hero)
2. What problem does it solve? (Problem)
3. How does it work? (Solution / Architecture)
4. What are its features? (Feature sections)
5. How do I get it? (Install + CTA)

---

## Meta Tags

Required for every product site:

```html
<title>{Product} — {One-line descriptor}</title>
<meta name="description" content="{2–3 sentence description. Technical, specific. Mention key numbers.}">
<meta property="og:title" content="{Same as title}">
<meta property="og:description" content="{Slightly different cut — punchy, different angle}">
<meta property="og:type" content="website">
<meta property="og:url" content="https://{subdomain}.alolabs.dev">
<meta property="og:image" content="https://{subdomain}.alolabs.dev/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
```

OG image is a separate `og-card.html` file rendered to PNG at 1200×630 (2x DPR, downscaled with `sips`). See OG Image section below.

---

## Nav

**Left:** Product name (logo text, no image in nav).  
**Center:** 6–9 anchor links to page sections. Label them by function, not by section name. E.g., "How It Works" not "Solution". Use short nouns where possible.  
**Right:** Theme toggle + GitHub CTA pill.

Nav link labels used by Silver Bullet (reference):
`Problem` | `How It Works` | `Ecosystem` | `Quality Gates` | `Enforcement` | `Cost` | `Workflow` | `Install` | `Compare`

**Rule:** The nav mirrors the page section order exactly. No orphan links.

---

## Hero Section

### Layout
Full-width, centered, `text-align: center`. Background: themed gradient (`--bg-hero`). Two radial glow orbs via `::before` / `::after`.

### Content Order

1. **Product logo image** — the product's visual mark. Rendered as `<img>` inside the `<h1>`.
2. **Product name in chrome gradient** — `<span class="gradient">Product Name</span>` inside `<h1>`. The chrome gradient (`--chrome-gradient`) is the ONLY element on the page that uses this treatment.
3. **Alpha/Beta badge** — small superscript badge next to the product name. States: ALPHA, BETA, etc.
4. **Hero tagline caps** — `.hero-tagline-caps`. ALL CAPS, wide letter-spacing. Max 5 words. Must encapsulate the core action the product enables. Silver Bullet: `ORCHESTRATE. ENFORCE. SHIP.`
5. **Version/status badge** — `.version-badge` with animated live dot. Contains: live dot + descriptor noun phrase. E.g., `Agentic Process Orchestrator for AI-native Software Engineering & DevOps`.
6. **Authority quote block** — `.brooks-block`. A founding industry insight that frames the problem. Circular photo, italic quote, attribution with links. Grayscale 20%, border ring, soft shadow.
7. **Tagline** — `.tagline`. 5 words max. Directly responds to the quote above. Silver Bullet: `Brooks was right. Until now.`
8. **Subtitle** — `.subtitle`. 1–2 sentences. The value proposition. What does the product do that nothing else does? Max 580px wide.
9. **CTA group** — Primary button + outline button. Primary: `Get Started` → `#install`. Outline: `GitHub →` → external. Always together.
10. **Hero pills** — `.hero-pill`. Anchor links to key sections. List the top 3–5 numeric facts (skill count, workflow count, step count, enforcement layers). Font-mono for numbers. Monospaced gives technical credibility.

### Copy Rules

- **Tagline-caps:** Imperative verbs only. Never nouns. Never adjectives.
- **Subtitle:** Avoid superlatives ("best", "only"). State facts. Include one differentiating phrase.
- **Avoid:** "AI-powered", "cutting-edge", "revolutionary", "next-gen". Use specific technical terms instead.
- **Hero pills:** Show numbers whenever possible. Numbers anchor claims. E.g., `39 Skills` not `Many Skills`.

---

## Problem Section

**Purpose:** Create resonance with the reader's actual pain. Make them feel seen before presenting the solution.

**Structure:**
- `section-label`: "The Problem"
- `section-title`: Describes the symptom, not the cause. E.g., `AI Agents Skip Steps — And Lose Context`
- `section-desc`: One sentence stating the root cause.
- `grid-4` of feature-cards: 4 specific problem manifestations. Each card = one failure mode.
- `callout` at bottom: The insight that ties all 4 problems together and sets up the solution.

**Card copy pattern:**
- **Title:** Noun phrase naming the problem. `Skipped Planning`, `No Quality Gates`, `Context Rot`
- **Body:** 2–3 sentences. Concrete, specific. Name the exact behavior or consequence.

**Callout copy pattern:**  
`**The root cause:** [Insight that reframes the problem as solvable].`

---

## Solution Section

**Purpose:** State what the product IS. High-level architecture summary.

**Structure:**
- `section-label`: "The Orchestrator" (or equivalent for your product)
- `section-title`: Same as hero tagline-caps but in sentence case
- `section-desc`: 2–3 sentence architecture summary. Mention: what it curates/combines, how many pieces, what it delivers.
- `hero-pills` repeated (same stats as hero)
- `grid-4` of feature-cards: The 4 foundational capabilities

**Card copy pattern (solution cards):**
- Each card maps to one architectural pillar
- Title: Capability name + optional `<code>` command reference
- Body: Specific, technical. Name the mechanism. Count things.

---

## Feature Sections (Variable)

One section per major product differentiator. Each section:

```
section-label  →  short noun (2 words max)
section-title  →  benefit statement
section-desc   →  1–2 sentences, centered
feature-grid   →  3 or 4 cards
```

**When to use 3-col vs 4-col:**
- 3 cards: when the 3 things are of equal weight and need more space per card
- 4 cards: when the 4 things together form a complete system

**Section ordering principle:** Specific → meta. Start with the concrete capabilities (spec, artifacts, quality gates), then move to system properties (enforcement, cost, workflow orchestration).

---

## Ecosystem / Plugin Section

**Purpose:** Show what the product is built on and what it curates.

Use `ecosystem-grid` for the primary plugin set and `devops-grid` for secondary/DevOps-specific tools (5-col, cyan accent).

**Primary plugin card structure:**
- Optional `.primary-badge` or `.optional-badge`
- Logo (emoji or image)
- Plugin name (`font-weight: 800`)
- Role label (uppercase, `--accent-light` or `--cyan`)
- Description (2–3 sentences)
- Feature list (arrow bullets, `→`)
- Tags row (`.plugin-learn-more` pills)

**Highlight the "primary" card** (the orchestrator or main dependency) with `.primary-plugin` class: it gets a mint-tinted border and subtle background gradient.

---

## Enforcement / Architecture Section

**Purpose:** Show system rigor. This is what makes the product trustworthy.

Use `.layer-card` grid (2-col or full-width list) with numbered circles (`--btn-gradient`). Each card:
- Number (font-mono)
- Layer name (h3, `--heading-muted` in dark)
- Description of what enforces, what it catches, and what happens when it triggers

**Rule:** Be concrete about enforcement consequences. "This blocks X" is better than "This prevents X".

---

## Comparison Section

**Purpose:** Legitimate competitive positioning.

Use 3-col `.compare-grid`:
- Card 1: Main competitor or "raw Claude Code"
- Card 2: A middle option
- Card 3: This product (`.winner` class)

Each card: name → role label → score number → score bar → feature checklist with ✓/✗ marks.

**Copy rules:**
- Score is a number out of 10 (or percentage)
- Feature list items: factual capability statements, not marketing claims
- `.winner` card has distinct border + background tint

---

## Install Section

**Purpose:** Eliminate friction to first install. Make it look easy.

Use `.install-block` with syntax-highlighted commands. Structure:

```
# comment explaining what this does
command_1   # optional inline comment
command_2
command_3
```

Syntax classes: `.comment` (dim), `.cmd` (green), `.flag` (cyan/accent2).

**After the code block:** Add the "What's included" callout listing exactly what gets installed.

---

## CTA Section

Last section before the footer. Repeat the hero CTA.

- `section-label`: "Ready to {verb}?"
- `section-title`: The hero tagline in a different form
- `section-desc`: 1 sentence re-stating the key benefit
- `cta-group`: Same primary + outline button pair as hero

---

## Footer

Three-column flex:
- **Left:** `<span style="font-weight:700">Product Name</span>` alone
- **Center:** `Innovated at Ālo Labs` — link styled with `font-weight: 700; text-decoration: none;` (no chrome gradient)
- **Right:** Links: `Help` | `GitHub` | `MIT License`

`Ālo` is rendered as `&#256;lo` (Unicode Ā). Always use this encoding.

---

## OG Image (`og-card.html`)

A self-contained HTML file rendered to `og-image.png` at 1200×630.

**Stack:** Space Grotesk loaded via Google Fonts. Dark background (`#080c10`). Green top border stripe. Centered vertical layout.

**Content:**
1. Product logo image (100px wide, drop-shadow)
2. Label — uppercase eyebrow (green, `#39ff66` for OG brightness)
3. Product name — `<h1>` with chrome gradient (silver version for dark bg)
4. Sub-heading — the hero tagline-caps equivalent: `Orchestrate. Enforce. Ship.`
5. Description — the solution section overview copy (1–2 sentences)
6. Pill badges — the same 3–5 stats as hero pills

**Rendering:**
```bash
/Applications/Google\ Chrome.app/.../chrome \
  --headless --screenshot=og-image-2x.png \
  --window-size=1200,630 \
  --force-device-scale-factor=2 \
  og-card.html
sips -z 630 1200 og-image-2x.png --out og-image.png
```

---

## Section Labeling Convention

| Section purpose | Label |
|-----------------|-------|
| Problem/pain | "The Problem" |
| Solution overview | "The Orchestrator" / "The Solution" |
| A specific feature area | 2-word noun phrase (e.g., "Spec-Driven Development") |
| Data/comparison | "How It Compares" |
| Installation | "Get Started" |
| CTA | "Ready to Ship?" |
| Help center | "Documentation" |

---

## Numbers to Lead With

Always quantify. On every product site, identify:
- Skill/command count
- Workflow count
- Step counts (per workflow)
- Enforcement layer count
- Plugin/integration count

Cite these in: hero pills, solution section-desc, OG image badges, nav area if space permits.

---

## Tone of Voice

**Technical, not hype.** Write as if explaining to a senior engineer who has seen every productivity tool claim before.

| ✅ Do | ❌ Don't |
|------|---------|
| Name the mechanism | Claim without explaining |
| Use exact numbers | Say "many", "tons", "powerful" |
| Name the failure mode | Vaguely imply a problem |
| Cite the real thing (Brooks) | Make up authority |
| "Enforced by hooks" | "AI-powered enforcement" |
| "Dispatches 9 parallel agents" | "Fast parallel processing" |
