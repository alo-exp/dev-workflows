# Layout Patterns

Page skeletons, section templates, and grid systems used across the site.

---

## Container

```css
.container { max-width: 1200px; margin: 0 auto; padding: 0 24px; }
```

Help pages use a narrower content container:
```css
.container      { max-width: 860px;  margin: 0 auto; padding: 0 24px; }  /* content */
.container-wide { max-width: 1100px; margin: 0 auto; padding: 0 24px; }  /* layout shell */
```

---

## Grid System

### Homepage Grids

```css
.grid   { display: grid; gap: 24px; }
.grid-2 { grid-template-columns: repeat(2,1fr); }
.grid-3 { grid-template-columns: repeat(3,1fr); }
.grid-4 { grid-template-columns: repeat(4,1fr); }

/* Collapse at 900px */
@media(max-width:900px) { .grid-2,.grid-3,.grid-4 { grid-template-columns: 1fr; } }
/* 2-col at 901–1100px for 3/4 col grids */
@media(min-width:901px) and (max-width:1100px) { .grid-3,.grid-4 { grid-template-columns: repeat(2,1fr); } }
```

Specialized grids:
```css
.feature-grid  { grid-template-columns: repeat(4,1fr); gap: 20px; }
.ecosystem-grid{ grid-template-columns: repeat(4,1fr); gap: 20px; }
.devops-grid   { grid-template-columns: repeat(5,1fr); gap: 16px; }
.compare-grid  { grid-template-columns: repeat(3,1fr); gap: 20px; }
```

### Help Center Grids

```css
/* Quick links — 10 items, 4 col */
.quick-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; }
@media(max-width:900px) { .quick-grid { grid-template-columns: repeat(2,1fr); } }

/* Help cards — 3 col */
.help-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 24px; }
@media(max-width:900px)  { .help-grid { grid-template-columns: 1fr; } }
@media(min-width:901px) and (max-width:1100px) { .help-grid { grid-template-columns: repeat(2,1fr); } }
```

---

## Page Skeletons

### Homepage

```
┌─ nav (fixed, 64px) ──────────────────────────────────────┐
├─ .hero (text-center, bg-hero gradient) ──────────────────┤
│  version-badge → h1 chrome-gradient → tagline-caps       │
│  brooks-quote block → tagline → subtitle → cta-group     │
│  hero-pills                                               │
├─ section (bg-page) ─ Problem ────────────────────────────┤
│  section-label + section-title + section-desc            │
│  grid-4 feature-cards                                     │
│  callout                                                  │
├─ section (bg-section-alt) ─ Solution ────────────────────┤
├─ section (bg-section-alt) ─ Spec-Driven ─────────────────┤
├─ section (bg-page) ─ Ecosystem ──────────────────────────┤
├─ section (bg-section-alt) ─ Review Analytics ────────────┤
├─ section (bg-page) ─ Quality Gates ──────────────────────┤
├─ section (bg-section-alt) ─ Enforcement ─────────────────┤
├─ section (bg-page) ─ Cost Optimization ──────────────────┤
├─ section (bg-section-alt) ─ Workflow Orchestration ───────┤
├─ section (bg-page) ─ Dev Workflow (tabs) ─────────────────┤
├─ section (bg-section-alt) ─ Compare ─────────────────────┤
├─ section (bg-page) ─ Install ─────────────────────────────┤
├─ .cta-section ────────────────────────────────────────────┤
└─ footer ──────────────────────────────────────────────────┘
```

**Section alternation:** `section:nth-child(even) { background: var(--section-alt) }`. Even sections get the subtle alt background automatically.

### Help Center Home

```
┌─ nav (fixed, compact — no nav links) ───────────────────┐
├─ .hero (bg-hero) ───────────────────────────────────────┤
│  badge pill → h1 → p → search-wrap                     │
├─ section — Quick Links ─────────────────────────────────┤
│  quick-grid (4×3, 10 items)                             │
├─ section — Main Cards ──────────────────────────────────┤
│  section-label + section-title + section-desc           │
│  help-grid (3 col × multiple rows)                      │
├─ section (bg-section-alt) — Callout ────────────────────┤
└─ footer ────────────────────────────────────────────────┘
```

### Doc Page (Dev Workflow, Reference, etc.)

```
┌─ nav (fixed, with breadcrumb + nav-search) ─────────────┐
├─ .page-hero (bg-hero) ──────────────────────────────────┤
│  breadcrumb-nav → h1 → p                               │
├─ .container-wide ───────────────────────────────────────┤
│  ┌─ .doc-layout (grid: 220px sidebar + 1fr) ──────────┐ │
│  │  aside.doc-sidebar (sticky)                        │ │
│  │    sidebar-nav (sections + links)                  │ │
│  │  article.doc-content                               │ │
│  │    [content: callouts, step-cards, dividers, h2s]  │ │
│  │  .page-nav-bottom (prev/next)                      │ │
│  └────────────────────────────────────────────────────┘ │
├─ footer ────────────────────────────────────────────────┘
```

Doc layout CSS:
```css
.doc-layout { display: grid; grid-template-columns: 220px 1fr; gap: 48px; padding: 64px 0; }
@media(max-width:768px) { .doc-layout { grid-template-columns: 1fr; } }
```

---

## Hero Section

### Homepage Hero

```css
.hero {
  background: var(--bg-hero); padding: 96px 24px 100px;
  position: relative; overflow: hidden; text-align: center;
}
/* Two radial glow orbs via ::before and ::after */
.hero::before {
  content: ''; position: absolute; top: -200px; right: -200px;
  width: 600px; height: 600px; border-radius: 50%;
  background: radial-gradient(ellipse at 55% 45%, var(--mint-a22) 0%, var(--mint-a10) 40%, transparent 72%);
}
.hero::after { /* mirror on bottom-left, smaller */ }
```

Content order (centered):
1. `<h1>` with product logo image + chrome-gradient "Silver Bullet" + alpha badge
2. `.hero-tagline-caps` — uppercase spacing caps: `ORCHESTRATE. ENFORCE. SHIP.`
3. `.version-badge` — live dot + descriptor text
4. `.brooks-block` — photo + quote + attribution
5. `.tagline` — bold one-liner: "Brooks was right. Until now."
6. `.subtitle` — 1–2 sentence value prop
7. `.cta-group` — primary + outline button pair
8. `.hero-pills` — stat/feature pills (anchor links)

### Help Center Hero

```css
.page-hero { background: var(--bg-hero); padding: 120px 24px 64px; position: relative; overflow: hidden; }
.page-hero::before { /* single glow orb top-right */ }
```

Content: `breadcrumb-nav` → `<h1>` → `<p>` description. Left-aligned.

---

## Section Anatomy

Standard section template:

```html
<section id="section-id">
  <div class="container">
    <!-- Optional: text-center wrapper -->
    <div class="section-label">Eyebrow Label</div>
    <h2 class="section-title">Section Heading</h2>
    <p class="section-desc centered">One or two sentences max. Sets up what follows.</p>
    <!-- Content: grid of cards, table, etc. -->
  </div>
</section>
```

```css
section { padding: 80px 0; }
section:nth-child(even) { background: var(--section-alt); }
.section-desc.centered { margin-left: auto; margin-right: auto; }
```

Max-width for description: `600px` (homepage), `560px` (doc pages).

---

## CTA Section

Full-width gradient stripe between main content and footer:

```css
.cta-section {
  background: linear-gradient(135deg,
    var(--accent-a14) 0%, var(--mint-a08) 40%, var(--mint-a10) 70%, var(--neutral-a10) 100%);
  border-top: 1px solid var(--mint-a20);
  border-bottom: 1px solid var(--mint-a20);
}
```

Content: section-label → section-title → section-desc → cta-group (centered).

---

## Page Bottom Navigation (Doc Pages)

Previous / Next links at the bottom of every doc page:

```css
.page-nav-bottom {
  display: flex; justify-content: space-between;
  margin-top: 56px; padding-top: 32px; border-top: 1px solid var(--border);
}
.page-nav-bottom a { display: flex; flex-direction: column; gap: 4px; max-width: 220px; }
.pnb-label { font-size: .75rem; text-transform: uppercase; letter-spacing: .08em; color: var(--text-dim); }
.pnb-title { font-size: .95rem; font-weight: 700; color: var(--accent-light); }
```

---

## Responsive Breakpoints

| Breakpoint | Behavior |
|------------|----------|
| `≤900px` | Grids collapse to 2-col or 1-col; `.ecosystem-grid` → 1-col |
| `≤768px` | Nav links hidden (hamburger); `.doc-sidebar` hidden; sections 72px padding |
| `≤600px` | Full single-column; hero CTA stacked; footer stacked; sections 60px padding |
| `≤480px` | Nav CTA hidden → moves into mobile dropdown menu |
| `≤375px` | Nav/container 12px horizontal padding; smallest font sizes |

---

## Utility Classes

```css
.text-center { text-align: center; }
.mt-2 { margin-top: 16px; }  .mt-3 { margin-top: 24px; }
.mt-4 { margin-top: 32px; }  .mt-6 { margin-top: 48px; }
.mt-8 { margin-top: 64px; }
.mb-2 { margin-bottom: 16px; } .mb-4 { margin-bottom: 32px; }
```

---

## Scroll Animations

```js
const observer = new IntersectionObserver(
  entries => entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); }),
  { threshold: 0.1 }
);
document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));
```

Apply `.fade-in` class to any element that should animate in on scroll. The `.visible` class triggers the CSS transition.

---

## Dividers

Simple horizontal rule inside doc pages:

```css
.divider { height: 1px; background: var(--border); margin: 36px 0; }
```

Used to visually separate major sections within a long document (e.g., between Initialization and Per-Phase Loop in dev-workflow).
