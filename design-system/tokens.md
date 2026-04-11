# Design Tokens

All tokens live in `site/tokens.css`. Every page links this file. The homepage (`site/index.html`) also declares tokens inline in `<style>` — they are kept in sync with `tokens.css`.

---

## Color — Background

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `--bg-page` | `#f6f4f0` | `#080c10` | Body background |
| `--bg-card` | `#ffffff` | `#0f1520` | Card surfaces |
| `--bg-card-hover` | `#f0ece6` | `#162030` | Card hover state |
| `--bg-code` | `#ece8e0` | `#060a0e` | Code blocks, install blocks |
| `--bg-hero` | Warm linen gradient | Deep navy gradient | Hero section background |
| `--nav-bg` | `rgba(246,244,240,.92)` | `rgba(8,12,16,.92)` | Frosted nav |
| `--nav-mobile-bg` | `rgba(246,244,240,.99)` | `rgba(8,12,16,.99)` | Mobile nav dropdown |
| `--section-alt` | `rgba(236,230,220,.55)` | `rgba(12,20,16,.7)` | Alternating section bg |

### Background Gradients

```css
/* Light hero */
--bg-hero: linear-gradient(160deg,
  #eae4da 0%, #eee8de 25%, #f4f0e8 48%,
  #f6f2ea 62%, #f0ece4 80%, #eae6dc 100%);

/* Dark hero */
--bg-hero: linear-gradient(160deg,
  #040608 0%, #060c14 25%, #08101e 48%,
  #0a1226 62%, #070d1a 80%, #03050a 100%);
```

---

## Color — Brand Accent (Green)

The brand accent is perceptually matched across themes — numerically lighter in light mode because the warm background makes colors appear brighter.

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `--accent` | `#00c834` | `#00a82e` | Primary brand color, borders, fills |
| `--accent-light` | `#009a28` | `#00a82e` | Link text, label text, interactive text |
| `--accent-glow` | `rgba(0,200,52,.18)` | `rgba(0,168,46,.13)` | Glow shadows |
| `--green` | `#00c834` | `#00a82e` | Semantic: success, go, positive |

### Accent Opacity Helpers

Pre-computed `color-mix` variants for overlays and tints:

```css
--accent-a04  --accent-a07  --accent-a08  --accent-a10
--accent-a12  --accent-a14  --accent-a15  --accent-a18
--accent-a25  --accent-a28  --accent-a30  --accent-a35  --accent-a40
```

Usage pattern: `background: var(--accent-a12)` for light tint; `border: 1px solid var(--accent-a28)` for subtle border.

### Mint Tint Helpers (soft green overlays)

```css
--mint-a07  --mint-a08  --mint-a10  --mint-a12  --mint-a13  --mint-a14
--mint-a18  --mint-a20  --mint-a22  --mint-a26  --mint-a28  --mint-a32
--mint-a35  --mint-a38  --mint-a45  --mint-a55  --mint-a90
```

Mint is `rgba(160,210,180, α)`. Used for hero glows, card top-borders, Brooks quote border, hero pills.

---

## Color — Semantic

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `--amber` | `#a86000` | `#ffaa00` | Warning, cost, verify phase |
| `--red` | `#aa1830` | `#c44060` | Error, stop, required badge |
| `--cyan` | `#006fa8` | `#00ccff` | Info, DevOps phase, discuss phase |
| `--accent2` | `#006fa8` | `#00ccff` | Secondary accent (same as cyan) |
| `--accent3` | `#6b21d4` | `#a855f7` | Tertiary accent (purple) |
| `--slate-text` | `#64748b` | `#64748b` | Muted labels (same both themes) |

### Semantic Opacity Helpers

```css
--cyan-a06  --cyan-a10  --cyan-a12  --cyan-a25  --cyan-a30
--amber-a12  --amber-a15
--red-a12   --red-a15
--green-a12  --green-a15
--accent3-a12
--slate-a10  --slate-a12
--cyan-discuss-a12   /* rgba(8,145,178,.12) — discuss phase bg */
--neutral-a10        /* rgba(75,85,99,.10) */
--neutral-a12        /* rgba(180,194,210,.12) */
```

---

## Color — Text

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `--text-primary` | `#050f08` | `#e2e8f0` | Headlines, strong text |
| `--text-secondary` | `#0d3a1a` | `#94a3b8` | Body text, descriptions |
| `--text-dim` | `#285c38` | `#64748b` | Labels, captions, placeholders |
| `--heading-muted` | `var(--text-primary)` | `#b8c4cc` | Dark-mode heading softening |

**Dark-mode heading rule:** In dark theme, `.section-title`, `.feature-card h3`, `.layer-card h3` use `--heading-muted` (`#b8c4cc`) instead of full `--text-primary` (`#e2e8f0`) to reduce harshness.

---

## Color — Border

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `--border` | `#8cc4a4` | `#112218` | Default borders |
| `--border-hover` | `#4a9464` | `#1a3824` | Hover/active borders |

---

## Color — Button Gradient Stops

```css
/* Light */
--grad-1: #005818   /* darkest green */
--grad-2: #008a24   /* mid green */
--grad-3: #6aaa80   /* light green (unused in btn) */
--grad-4: #00c034   /* bright green */

/* Dark */
/* btn-gradient uses absolute values, not vars */
```

### Button Gradients

```css
/* Light — primary button & nav CTA */
--btn-gradient: linear-gradient(135deg, var(--grad-1) 0%, var(--grad-2) 50%, var(--grad-1) 100%);
--btn-gradient-hover: linear-gradient(135deg, var(--grad-2) 0%, var(--grad-4) 50%, var(--grad-2) 100%);

/* Dark */
--btn-gradient: linear-gradient(135deg, #007a20 0%, #00a82e 50%, #007a20 100%);
--btn-gradient-hover: linear-gradient(135deg, #009428 0%, #00c034 50%, #009428 100%);
```

---

## Color — Chrome / Silver Gradient

Applied to the "Silver Bullet" product name in hero and OG image. Changes completely between themes.

```css
/* Light — dark steel */
--chrome-gradient: linear-gradient(90deg,
  #2a2a2a 0%, #585858 9%, #383838 18%, #282828 27%,
  #505050 36%, #444444 43%, #303030 51%, #484848 59%,
  #343434 68%, #242424 76%, #404040 86%, #1e1e1e 100%);

/* Dark — bright chrome/silver */
--chrome-gradient: linear-gradient(90deg,
  #a8a8a8 0%, #ffffff 9%, #c0c0c0 18%, #909090 27%,
  #efefef 36%, #ffffff 43%, #cccccc 51%, #909090 59%,
  #e8e8e8 68%, #b8b8b8 76%, #888888 86%, #a0a0a0 100%);
```

Usage: `background: var(--chrome-gradient); -webkit-background-clip: text; -webkit-text-fill-color: transparent;`

**Note:** Do NOT apply chrome gradient to body text or links. It is reserved exclusively for the product name display treatment.

---

## Typography

### Typefaces

| Role | Family | Source |
|------|--------|--------|
| Sans-serif | Space Grotesk | Google Fonts |
| Monospace | Fira Code | Google Fonts |

```html
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Fira+Code:wght@400;500;600&display=swap" rel="stylesheet">
```

```css
--font-sans: 'Space Grotesk', system-ui, sans-serif;
--font-mono: 'Fira Code', monospace;
```

### Type Scale

| Element | Size | Weight | Letter-spacing | Notes |
|---------|------|--------|----------------|-------|
| Hero h1 | `clamp(2.2rem, 5vw, 4rem)` | 900 | `-.04em` | Chrome gradient on product name |
| Section title | `clamp(1.8rem, 3vw, 2.5rem)` | 800 | `-.03em` | `--heading-muted` in dark |
| Card h3 | `1.1rem` | 700 | — | `--heading-muted` in dark |
| Doc h1 | `clamp(1.8rem, 3.5vw, 2.8rem)` | 900 | `-.04em` | Help page heroes |
| Doc h2 | `1.4rem` | 800 | `-.03em` | Doc section headings |
| Doc h3 | `1rem` | 700 | — | Doc sub-headings |
| Section label | `.75rem` | 700 | `.12em` | Uppercase eyebrow text |
| Body | `1rem` | 400 | — | `line-height: 1.7` |
| Body small | `.875rem` | 400 | — | Card descriptions |
| Caption / dim | `.8rem` | — | — | Metadata, timestamps |
| Code | `.82rem` | 400 | — | `font-family: var(--font-mono)` |
| Nav links | `.875rem` | 500 | — | |
| Badges / tags | `.7rem`–`.75rem` | 700 | `.04em`–`.1em` | Uppercase |
| Hero tagline caps | `.82rem` | 700 | `.22em` | All-caps, accent-light color |

### Heading Rendering

```css
html { -webkit-font-smoothing: antialiased; }
body { line-height: 1.7; }
```

---

## Spacing

No spacing scale token — spacing uses literal `px` values following this rhythm:

| Context | Values |
|---------|--------|
| Inline gap (flex) | `6px`, `8px`, `10px`, `12px`, `16px`, `20px`, `24px`, `28px` |
| Card padding | `24px`–`32px` (compact), `28px`–`40px` (standard) |
| Section vertical | `80px 0` (desktop), `72px 0` (tablet), `60px 0` (mobile) |
| Container horizontal | `24px` padding, `12px` on ≤375px |
| Stack margin | `8px`, `12px`, `14px`, `16px`, `20px`, `24px`, `32px`, `40px`, `48px`, `56px` |

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | `8px` | Small pills, badges, sidebar items |
| `--radius` | `12px` | Standard cards, inputs, step cards |
| `--radius-lg` | `20px` | Feature cards, ecosystem cards, help cards |
| `999px` (literal) | — | Pills, buttons, nav CTA, badges |
| `50%` (literal) | — | Circular elements (step numbers, avatars) |

---

## Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `--shadow-lg` | Light: `0 20px 60px rgba(0,0,0,.10)` / Dark: `0 20px 60px rgba(0,0,0,.7)` | Floating panels |
| `--shadow-glow` | Light: `0 0 40px rgba(0,170,46,.08)` / Dark: `0 0 40px rgba(0,255,65,.06)` | Card hover glow |

Card hover: `box-shadow: var(--shadow-glow); transform: translateY(-4px)`.

---

## Motion

| Token | Value | Usage |
|-------|-------|-------|
| Theme transition | `.25s` | Background, border, color, box-shadow |
| Card hover | `.3s` | All transitions |
| Button hover | `.25s` | All transitions |
| Fade-in | `.6s ease-out` | Scroll-triggered opacity + translateY |
| Pulse animation | `2s infinite` | Version badge live dot |
| Gradient slide | `.8s ease-out` | Comparison bar fill |

### Fade-in Pattern

```css
.fade-in { opacity: 0; transform: translateY(20px); transition: all .6s ease-out; }
.fade-in.visible { opacity: 1; transform: translateY(0); }
```

Triggered by IntersectionObserver at 10% visibility threshold.

### Theme Transition Targets

```css
body, nav, section, .feature-card, .skill-card, .platform-pill,
.install-block, .code-block, .arch-diagram, .callout,
.comparison-table td, .comparison-table th, .enforcement-block {
  transition: background .25s, background-color .25s, border-color .25s,
              color .25s, box-shadow .25s;
}
```

---

## Icons

Lucide icons via CDN. Version pinned at `0.469.0`.

```html
<script src="https://unpkg.com/lucide@0.469.0/dist/umd/lucide.min.js"></script>
<script>lucide.createIcons();</script>
```

```css
svg.lucide {
  display: inline-block; vertical-align: middle;
  width: 1em; height: 1em;
  stroke-width: 1.5; stroke: currentColor;
  fill: none; stroke-linecap: round; stroke-linejoin: round;
}
```

Icons inherit `color` from parent — no hardcoded stroke colors.
