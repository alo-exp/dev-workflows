# Component Library

All components are implemented as plain HTML + CSS. No framework. Every color references a CSS custom property from `tokens.css`.

---

## Navigation

### Top Nav

Fixed, frosted-glass header. Height: `64px`. Z-index: `100`.

```css
nav {
  position: fixed; top: 0; left: 0; right: 0; z-index: 100;
  background: var(--nav-bg);        /* 92% opacity, theme-adaptive */
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--border);
  padding: 0 24px;
}
nav .nav-inner {
  max-width: 1200px; margin: 0 auto;
  display: flex; align-items: center; justify-content: space-between;
  height: 64px;
}
```

**Logo:** `font-weight: 800; font-size: 1.1rem; letter-spacing: -.02em;`

**Nav links:** `.875rem`, `font-weight: 500`, `color: var(--text-secondary)` → hover `var(--text-primary)`

**Nav CTA (pill button):**
```css
nav .nav-cta {
  background: linear-gradient(135deg, var(--grad-1), var(--grad-2));
  color: #fff; padding: 8px 20px; border-radius: 999px;
  font-size: .8rem; font-weight: 600;
  box-shadow: inset 0 1px 0 rgba(255,255,255,.14);
}
nav .nav-cta:hover {
  background: linear-gradient(135deg, var(--grad-2), var(--grad-4));
  box-shadow: 0 0 20px var(--accent-a25), inset 0 1px 0 rgba(255,255,255,.2);
}
```

**Theme toggle:** 40×40px circle button, `border: 1px solid var(--border)`, `background: var(--bg-card)`. Contains sun/moon Lucide icon, toggled via JS.

**Mobile collapse:** Nav links hidden at `≤768px`; hamburger toggle shows them stacked at `top: 64px` with solid background. Nav CTA hidden at `≤480px` — moved into the dropdown as `mobile-only` item.

### Help-Page Nav (simpler variant)

Fixed, same height/blur. Left side: logo + breadcrumb. Right side: search input + theme toggle. No nav links. No CTA.

```html
<span class="nav-breadcrumb">
  <span class="sep">/</span><a href="../">Help</a><span class="sep">/</span> Page Title
</span>
```

---

## Buttons

### Primary Button

```css
.btn {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 14px 28px; border-radius: 999px; font-size: .9rem; font-weight: 600;
  border: none; cursor: pointer; transition: all .25s; min-height: 44px;
}
.btn-primary {
  background: linear-gradient(135deg,
    var(--grad-1) 0%, var(--grad-2) 35%, #b0bec8 52%, var(--grad-2) 67%, var(--grad-1) 100%);
  background-size: 250% auto;
  color: #fff;
  box-shadow: 0 4px 20px var(--accent-a30), inset 0 1px 0 rgba(255,255,255,.18);
}
.btn-primary:hover {
  background-position: right center;
  box-shadow: 0 8px 30px var(--accent-a40), inset 0 1px 0 rgba(255,255,255,.25);
  transform: translateY(-2px);
}
```

The silver-shimmer stop at `52%` (`#b0bec8`) gives the hero button its distinctive finish.

### Outline Button

```css
.btn-outline {
  background: transparent; color: var(--text-primary);
  border: 1px solid var(--border-hover);
}
.btn-outline:hover { border-color: var(--accent); color: var(--accent-light); }
```

### Button Pairing

Primary and outline are always used together in a CTA group:
```html
<div class="cta-group">
  <a href="#install" class="btn btn-primary">Get Started</a>
  <a href="https://github.com/..." class="btn btn-outline" target="_blank">GitHub →</a>
</div>
```

`cta-group`: `display: flex; gap: 16px; justify-content: center; flex-wrap: wrap;`

---

## Cards

All cards share: `background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); transition: all .3s;`  
Hover: `border-color: var(--border-hover); box-shadow: var(--shadow-glow); transform: translateY(-4px);`

### Feature Card

Standard content card. Used in 4-col and 3-col grids.

```css
.feature-card {
  border-radius: var(--radius-lg); padding: 32px;
  position: relative; overflow: hidden;
}
/* Top-edge highlight line on hover */
.feature-card::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 2px;
  background: linear-gradient(90deg,
    transparent, var(--mint-a90), var(--accent-light), var(--mint-a90), transparent);
  opacity: 0; transition: opacity .3s;
}
.feature-card:hover::before { opacity: 1; }
```

**Icon:** 48×48px container, `border-radius: 12px`. Icon size: `1.4rem`. Color and background set inline per card.

**Heading:** `1.1rem`, `font-weight: 700`. Dark mode uses `--heading-muted`.

**Body:** `.9rem`, `color: var(--text-secondary)`, `line-height: 1.6`.

### Help Card (large)

Used in Help Center home grid. Same hover treatment but different internal structure.

```css
.help-card {
  border-radius: var(--radius-lg); padding: 32px;
  text-decoration: none; color: inherit; display: block;
  position: relative; overflow: hidden;
}
/* Same ::before top-highlight as feature-card */
.help-card::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
  background: var(--card-accent, linear-gradient(90deg, var(--accent), var(--accent2)));
  opacity: 0; transition: opacity .3s;
}
```

Internal structure: icon (2rem emoji or Lucide) → colored badge → `<h3>` → `<p>` description → `<ul class="card-topics">` bullet list → `<div class="card-cta">Text →</div>`

**Card topics list:**
```css
.help-card .card-topics li::before { content: '→'; color: var(--accent-light); font-weight: 700; }
```

**Card CTA:** `font-size: .82rem; font-weight: 600; color: var(--accent-light);` — text link with arrow.

### Ecosystem Card

For plugin/tool showcases.

```css
.ecosystem-card { border-radius: var(--radius-lg); padding: 28px; display: flex; flex-direction: column; }
.ecosystem-card.primary-plugin {
  border-color: var(--mint-a38);
  background: linear-gradient(160deg, var(--bg-card), var(--mint-a07) 40%, var(--accent-a04));
}
```

Internal: logo emoji → badge → name (`font-weight: 800`) → role label (uppercase, `--accent-light`) → description → feature list → tags row.

Feature list marker: `content: '→'; color: var(--accent-light);`

### Layer Card (Enforcement)

Horizontal layout with numbered circle.

```css
.layer-card {
  border-radius: var(--radius-lg); padding: 28px;
  display: flex; align-items: flex-start; gap: 16px;
}
.layer-num {
  min-width: 36px; height: 36px; border-radius: 50%; flex-shrink: 0;
  background: var(--btn-gradient);
  box-shadow: inset 0 1px 0 rgba(255,255,255,.18), 0 2px 8px rgba(0,0,0,.18);
  color: #fff; font-weight: 700; font-size: .85rem;
  display: flex; align-items: center; justify-content: center;
  font-family: var(--font-mono); margin-top: 2px;
}
```

### Compare Card

Comparison table card with score bar.

```css
.compare-card { border-radius: var(--radius-lg); padding: 32px; }
.compare-card.winner {
  border-color: var(--mint-a45);
  background: linear-gradient(160deg, var(--bg-card), var(--mint-a08) 35%, var(--accent-a04));
  box-shadow: 0 0 40px var(--mint-a10);
}
```

Score bar: `height: 6px; border-radius: 999px; background: var(--border);` track + gradient fill.

---

## Badges & Tags

### Section Label (Eyebrow)

```css
.section-label {
  text-transform: uppercase; font-size: .75rem; font-weight: 700;
  letter-spacing: .12em; color: var(--accent-light); margin-bottom: 12px;
}
```

### Tag Pills

```css
.tag {
  display: inline-block; padding: 7px 16px; border-radius: 999px;
  font-size: .75rem; font-weight: 600; letter-spacing: .03em;
}
.tag-green   { background: var(--green-a12);   color: var(--green); }
.tag-amber   { background: var(--amber-a12);   color: var(--amber); }
.tag-cyan    { background: var(--cyan-a12);    color: var(--cyan); }
.tag-red     { background: var(--red-a15);     color: var(--red); }
.tag-purple  { background: var(--accent-a15);  color: var(--accent-light); }
.tag-pink    { background: var(--accent3-a12); color: var(--accent3); }
```

### Hero Pills (anchor links)

```css
.hero-pill {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 8px 18px; border-radius: 999px;
  background: linear-gradient(135deg, var(--mint-a13), var(--accent-a08), var(--mint-a10));
  border: 1px solid var(--mint-a28);
  font-size: .8rem; font-weight: 700; color: var(--accent-light);
  letter-spacing: .02em; font-family: var(--font-mono); min-height: 40px;
}
a.hero-pill:hover {
  background: linear-gradient(135deg, var(--mint-a26), var(--accent-a18), var(--mint-a20));
  border-color: var(--mint-a55); color: #fff;
}
```

### Primary Badge / Optional Badge

Used in ecosystem cards:
```css
.primary-badge {
  background: var(--accent-a12); border: 1px solid var(--accent-a25);
  border-radius: 999px; padding: 3px 10px;
  font-size: .7rem; font-weight: 700; color: var(--accent-light); letter-spacing: .04em;
}
.optional-badge {
  background: var(--cyan-a10); border: 1px solid var(--cyan-a25);
  color: var(--cyan);
}
```

### Alpha Badge

Positioned superscript next to logo:
```css
.alpha-badge {
  background: var(--accent-a10); border: 1px solid var(--accent-a28);
  color: var(--accent-light); font-size: .55rem; font-weight: 700;
  letter-spacing: .08em; padding: 3px 7px; border-radius: 6px;
  position: absolute; top: 0; left: 100%; margin-left: 1px; transform: translateY(-55%);
}
```

### Phase Badges (workflow tables)

```css
.phase-badge { padding: 2px 10px; border-radius: 999px; font-size: .7rem; font-weight: 700; }
.phase-init        { background: var(--slate-a12);        color: var(--slate-text); }
.phase-discuss     { background: var(--cyan-discuss-a12); color: var(--cyan); }
.phase-planning    { background: var(--accent-a15);       color: var(--accent-light); }
.phase-execution   { background: var(--green-a12);        color: var(--green); }
.phase-verify      { background: var(--amber-a12);        color: var(--amber); }
.phase-finalization{ background: var(--accent3-a12);      color: var(--accent3); }
.phase-deployment  { background: var(--cyan-a12);         color: var(--cyan); }
.phase-ship        { background: var(--green-a15);        color: var(--green); }
```

---

## Step Cards (Workflow Pages)

Used in dev-workflow and devops-workflow documentation pages.

```css
.step-card {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius); padding: 20px 24px; margin-bottom: 20px;
  display: flex; gap: 16px; align-items: flex-start; transition: border-color .2s;
}
.step-card:hover { border-color: var(--border-hover); }
```

**Step number circle:**
```css
.step-num {
  min-width: 36px; height: 36px; border-radius: 50%;
  color: #fff; font-weight: 700; font-size: .82rem;
  display: flex; align-items: center; justify-content: center;
  font-family: var(--font-mono); flex-shrink: 0; margin-top: 1px;
  /* background set inline per phase */
}
```

Color by phase:
- Init/Finalization: `linear-gradient(135deg,#374151,#6b7280)`
- Discuss: `linear-gradient(135deg,var(--cyan),#0891b2)`
- Gates: `linear-gradient(135deg,var(--red),#b91c1c)`
- Plan/Post-review: `linear-gradient(135deg,var(--accent),var(--accent2))`
- Execute: `linear-gradient(135deg,var(--green),#047857)`
- Verify/Review: `linear-gradient(135deg,var(--amber),#b45309)`
- Deployment gates: `linear-gradient(135deg,#7c3aed,#5b21b6)`
- CI/CD: `linear-gradient(135deg,var(--cyan),#0e7490)`

**Phase header (section divider within workflow):**
```css
.phase-header {
  padding: 12px 20px; border-radius: var(--radius-sm);
  font-size: .8rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em;
  margin-bottom: 24px; margin-top: 52px;
}
```

Phase colors follow the same semantic palette as phase badges above.

---

## Callouts

### Homepage Callout (centered, large)

```css
.callout {
  background: linear-gradient(135deg, var(--mint-a14), var(--accent-a07) 50%, var(--neutral-a12));
  border: 1px solid var(--mint-a32);
  border-radius: var(--radius-lg); padding: 40px;
  text-align: center; max-width: 700px; margin: 0 auto;
  box-shadow: inset 0 1px 0 rgba(255,255,255,.08);
}
```

### Help Page Callouts (inline, 4 variants)

```css
.callout { border-radius: var(--radius); padding: 18px 22px; margin-bottom: 20px; display: flex; gap: 12px; }
.callout-info { background: rgba(107,114,128,.08); border: 1px solid rgba(107,114,128,.2); }
.callout-tip  { background: rgba(5,150,105,.06);   border: 1px solid rgba(5,150,105,.2); }
.callout-warn { background: rgba(217,119,6,.06);   border: 1px solid rgba(217,119,6,.2); }
.callout-stop { background: rgba(220,38,38,.06);   border: 1px solid rgba(220,38,38,.2); }
```

Icon (`.callout-icon`): `font-size: 1rem; flex-shrink: 0; margin-top: 2px;`  
Body: `font-size: .86rem; color: var(--text-secondary); line-height: 1.7;`

---

## Code & Terminal Blocks

### Enforcement Block (terminal-style)

```css
.enforcement-block {
  background: var(--bg-code); border: 1px solid var(--border);
  border-radius: var(--radius); overflow: hidden;
}
.enforcement-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 12px 20px; border-bottom: 1px solid var(--border);
}
.enforcement-body {
  padding: 20px 24px; font-family: var(--font-mono); font-size: .82rem;
  line-height: 1.9; color: var(--text-secondary);
}
```

Syntax classes: `.stop` (`var(--red)`), `.ok` (`var(--green)`), `.warn` (`var(--amber)`), `.dim` (`var(--text-dim)`), `.accent` (`var(--accent-light)`)

Header dots: three 10×10px circles (`border-radius: 50%`).

### Install Block

```css
.install-block {
  background: var(--bg-code); border: 1px solid var(--border);
  border-radius: var(--radius); max-width: 680px; margin: 0 auto;
}
.install-code {
  padding: 28px 32px; font-family: var(--font-mono); font-size: .85rem;
  line-height: 2.2; color: var(--text-secondary);
}
.install-code .comment { color: var(--text-dim); }
.install-code .cmd     { color: var(--green); }
.install-code .flag    { color: var(--accent2); }
```

### Inline Code

```css
code {
  font-family: var(--font-mono); font-size: .82em;
  background: var(--bg-code); padding: 2px 6px; border-radius: 4px;
  color: var(--accent-light);
}
```

---

## Tables

### Workflow Table

```css
.workflow-table { width: 100%; border-collapse: collapse; min-width: 640px; }
.workflow-table th {
  text-align: left; padding: 10px 16px;
  font-size: .7rem; text-transform: uppercase; letter-spacing: .08em;
  color: var(--text-dim); border-bottom: 2px solid var(--border);
}
.workflow-table td {
  padding: 10px 16px; font-size: .82rem;
  border-bottom: 1px solid var(--skill-phase-border);
  color: var(--text-secondary); font-family: var(--font-mono);
}
.workflow-table td:first-child { color: var(--text-primary); font-weight: 600; font-family: var(--font-sans); }
.workflow-table tr:hover td    { background: var(--table-row-hover); }
```

Wrapped in `overflow-x: auto` container for mobile scroll.

---

## Quick Links Grid (Help Center Home)

```css
.quick-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; }
@media(max-width:900px) { .quick-grid { grid-template-columns: repeat(2,1fr); } }

.quick-link {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius); padding: 16px 20px;
  text-decoration: none; color: var(--text-secondary);
  font-size: .85rem; font-weight: 500;
  display: flex; align-items: center; gap: 10px; transition: all .2s;
}
.quick-link:hover { border-color: var(--accent); color: var(--accent-light); transform: translateX(2px); }
.quick-link .ql-icon { font-size: 1.1rem; }
```

Labels must be **Title Case**. Ordered logically: entry → core concepts → workflows → reference.

---

## Search

### Hero Search (Help Center Home)

Full-width search input in the hero. Results appear below in a separate `#search-results-section`.

```css
.search-wrap { position: relative; max-width: 600px; margin: 32px auto 0; }
/* search-icon positioned absolutely left; input has left padding for it */
```

### Nav Search (Doc Pages)

Compact search in top-right of nav. Expands on focus.

```css
.nav-search-input {
  width: 180px; padding: 7px 14px; border-radius: 999px;
  border: 1px solid var(--border); background: var(--bg-code);
  color: var(--text-primary); font-size: .82rem; transition: border-color .2s, width .2s;
}
.nav-search-input:focus { border-color: var(--accent); width: 240px; }
```

Results dropdown: `width: 340px; max-height: 420px; overflow-y: auto;` positioned `top: calc(100% + 8px)`.

---

## Footer

Three-column flex layout. Collapses to column on mobile.

```css
footer {
  border-top: 1px solid var(--border); padding: 48px 0;
  color: var(--text-dim); font-size: .85rem;
}
footer .footer-inner {
  display: flex; justify-content: space-between; align-items: center;
  flex-wrap: wrap; gap: 16px;
}
footer a { color: var(--text-secondary); text-decoration: none; }
footer a:hover { color: var(--accent-light); }
footer .footer-links { display: flex; gap: 24px; }
```

**Standard structure:**
- Left: `<span style="font-weight:700">Product Name</span>` (optionally + " Help Center")
- Center: `Innovated at <a href="https://alolabs.dev" style="font-weight:700;text-decoration:none">Ālo Labs</a>` in `font-size:.9rem; color:var(--text-secondary); text-align:center`
- Right: `.footer-links` with Help, GitHub, MIT License links

**Ālo Labs link:** `font-weight: 700; text-decoration: none;` — inherits `color: var(--text-secondary)` from `footer a`. Do NOT apply chrome gradient here.

---

## Version / Live Badge

```css
.version-badge {
  display: inline-flex; align-items: center; gap: 8px;
  background: linear-gradient(135deg, var(--mint-a14), var(--accent-a08), var(--mint-a12));
  border: 1px solid var(--mint-a35);
  border-radius: 999px; padding: 6px 16px; font-size: .8rem;
  color: var(--accent-light); font-weight: 500;
}
.version-badge .dot {
  width: 6px; height: 6px; border-radius: 50%; background: var(--green);
  animation: pulse 2s infinite;
}
@keyframes pulse { 0%,100% { opacity:1 } 50% { opacity:.4 } }
```

---

## Workflow Tabs

Tab strip for switching between workflow views.

```css
.workflow-tabs { display: flex; gap: 8px; justify-content: center; margin-bottom: 32px; }
.workflow-tab {
  padding: 10px 24px; border-radius: 999px; font-size: .85rem; font-weight: 600;
  border: 1px solid var(--border); background: var(--bg-card); color: var(--text-secondary);
}
.workflow-tab.active {
  background: linear-gradient(135deg, var(--grad-1) 0%, var(--grad-2) 40%, var(--grad-3) 58%, var(--grad-1) 100%);
  color: #fff; border-color: transparent;
}
```

---

## Sidebar Navigation (Doc Pages)

```css
.doc-sidebar { position: sticky; top: 88px; height: fit-content; }
.sidebar-nav { list-style: none; display: flex; flex-direction: column; gap: 2px; }
.sidebar-nav li a {
  display: block; padding: 7px 12px; border-radius: var(--radius-sm);
  font-size: .85rem; color: var(--text-secondary); text-decoration: none;
}
.sidebar-nav li a:hover { background: var(--bg-code); color: var(--text-primary); }
.sidebar-nav li a.active { background: rgba(107,114,128,.1); color: var(--accent-light); font-weight: 600; }
.sidebar-nav .sidebar-section {
  font-size: .7rem; font-weight: 700; text-transform: uppercase; letter-spacing: .1em;
  color: var(--text-dim); padding: 16px 12px 4px;
}
```

Hidden on mobile (`@media(max-width:768px)`).

---

## Comparison Bar

Progress-bar style score display inside compare cards.

```css
.compare-bar-track { height: 6px; background: var(--border); border-radius: 999px; margin-bottom: 24px; overflow: hidden; }
.compare-bar-fill {
  height: 100%; border-radius: 999px;
  background: linear-gradient(90deg, var(--grad-1), #7a8ea0, #c8d8e4, #7a8ea0);
  background-size: 200% auto; transition: width .8s ease-out;
}
```
