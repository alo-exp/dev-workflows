# Ālo Labs — Product Design System

A complete guide to replicating the visual language, component library, and content structure used across all Ālo Labs product sites. Derived from the Silver Bullet site as the reference implementation.

---

## Documents

| File | Contents |
|------|----------|
| [tokens.md](tokens.md) | Design tokens: colors, typography, spacing, radii, shadows, motion |
| [components.md](components.md) | Every UI component with variants, states, and code |
| [layout-patterns.md](layout-patterns.md) | Page skeletons, section patterns, grid systems |
| [content-guidelines-homepage.md](content-guidelines-homepage.md) | Homepage narrative structure, copy rules, section playbook |
| [content-guidelines-help-center.md](content-guidelines-help-center.md) | Help center architecture, page types, writing standards |

---

## Design Philosophy

**Dark-first, light-supported.** The dark theme (`#080c10` canvas) is the primary experience. Light theme (`#f6f4f0`) is a warm off-white, never pure white. Both are fully tokenized — zero hardcoded colors anywhere.

**Green as the single brand accent.** One accent color drives every interactive element: links, buttons, badges, borders, glows. It is perceptually matched across themes (lighter in light mode, slightly deeper in dark) so it reads identically regardless of theme.

**Space Grotesk + Fira Code.** The sans and mono pair is non-negotiable — they define the AI-native engineering aesthetic.

**Cards over prose.** Information is organized into scannable cards with consistent border/radius/hover treatment rather than long text blocks.

**Tokens, not values.** Every color, shadow, radius, and gradient references a CSS custom property. No exceptions. This is enforced via `site/tokens.css` — the single source of truth linked by every page.

---

## Token Architecture

```
site/tokens.css          ← shared across all pages (link this)
site/index.html <style>  ← homepage-only component CSS
site/help/**/index.html  ← help-page component CSS (scoped per page)
```

All pages link `tokens.css`. Component CSS lives inline in `<style>` per page. No external CSS framework.

---

## Theme Toggle

Every page implements identical theme logic:

```html
<!-- In <head> — prevents flash of wrong theme -->
<script>
  document.documentElement.setAttribute(
    'data-theme',
    localStorage.getItem('silver-bullet-theme') === 'light' ? 'light' : 'dark'
  );
</script>
```

```js
function applyTheme(dark) {
  document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light');
  document.getElementById('icon-sun').style.display = dark ? 'none' : '';
  document.getElementById('icon-moon').style.display = dark ? '' : 'none';
  localStorage.setItem('silver-bullet-theme', dark ? 'dark' : 'light');
}
function toggleTheme() {
  applyTheme(document.documentElement.getAttribute('data-theme') !== 'dark');
}
(function () {
  const s = localStorage.getItem('silver-bullet-theme');
  applyTheme(s === 'light' ? false : true);
})();
```

Default is **dark**. Light is opt-in via localStorage.
