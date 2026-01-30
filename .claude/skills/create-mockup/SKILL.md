---
name: create-mockup
description: Use when designing user interfaces. Creates visual HTML mockups that render in Chrome for realistic UI preview. Start with text diagrams, then offer HTML mockups.
---

# Create Mockup

## Overview

Create visual UI mockups using inline HTML/CSS rendered in Chrome via Playwright. This provides a realistic preview of designs without leaving the conversation.

**Announce at start:** "I'm using the create-mockup skill to create visual mockups."

## When to Use

- During brainstorming when UI/UX decisions are being made
- When presenting navigation options, layouts, or component designs
- When text diagrams aren't sufficient to convey the design
- When the user asks to "see" or "show" a design visually

## The Flow

### Step 1: Text Diagram First

Start with ASCII/text diagrams for quick iteration:

```
┌─────────────────────────────────────┐
│  Header                    [User]   │
├────────┬────────────────────────────┤
│ Sidebar│  Content Area              │
│        │                            │
└────────┴────────────────────────────┘
```

### Step 2: Offer HTML Mockup

Once structure is agreed, offer:

> "Would you like me to show you a quick HTML mockup? It renders in Chrome and gives a more realistic feel."

### Step 3: Create Mockup

Use Playwright to render inline HTML:

```
mcp__playwright__browser_navigate with url: data:text/html,<HTML_CONTENT>
mcp__playwright__browser_take_screenshot
```

## HTML Template (Dark Mode)

```html
<!DOCTYPE html>
<html>
<head>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: system-ui, -apple-system, sans-serif;
  background: #0a0a0a;
  color: #e5e5e5;
  height: 100vh;
}

/* Layout */
.app { display: flex; height: 100vh; }
.sidebar {
  width: 200px;
  background: #111;
  border-right: 1px solid #222;
  display: flex;
  flex-direction: column;
}
.main { flex: 1; display: flex; flex-direction: column; }
.header {
  padding: 12px 20px;
  border-bottom: 1px solid #222;
  background: #111;
}
.content { flex: 1; padding: 20px; overflow-y: auto; }

/* Navigation */
.nav-item {
  padding: 10px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
}
.nav-item:hover { background: #222; }
.nav-item.active { background: #166534; color: #4ade80; }

/* Cards */
.card {
  background: #161616;
  border: 1px solid #222;
  border-radius: 8px;
  padding: 12px 16px;
  cursor: pointer;
}
.card:hover { background: #1a1a1a; border-color: #333; }

/* Badges */
.badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 12px;
}
.badge-success { background: #052e16; color: #4ade80; }
.badge-warning { background: #422006; color: #eab308; }
.badge-danger { background: #450a0a; color: #ef4444; }
.badge-neutral { background: #222; color: #888; }

/* Forms */
.input {
  width: 100%;
  background: #222;
  border: 1px solid #333;
  border-radius: 6px;
  padding: 8px 12px;
  color: #e5e5e5;
  font-size: 14px;
}

/* Buttons */
.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
}
.btn-primary { background: #166534; color: #4ade80; }
.btn-primary:hover { background: #1a7a3e; }

/* Slide-over panel */
.slide-over {
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 400px;
  background: #111;
  border-left: 1px solid #222;
  box-shadow: -4px 0 20px rgba(0,0,0,0.3);
}
</style>
</head>
<body>
  <!-- Your mockup content here -->
</body>
</html>
```

## Common Patterns

### Sidebar Layout
```html
<div class="app">
  <aside class="sidebar">
    <div class="sidebar-header">App Name</div>
    <nav>
      <div class="nav-item active">Dashboard</div>
      <div class="nav-item">Settings</div>
    </nav>
  </aside>
  <main class="main">
    <header class="header">Page Title</header>
    <div class="content">Content here</div>
  </main>
</div>
```

### Card List
```html
<div class="card-list">
  <div class="card">
    <div class="card-title">Item Title</div>
    <div class="card-meta">
      <span class="badge badge-success">Active</span>
    </div>
  </div>
</div>
```

### Slide-over Panel
```html
<div class="slide-over">
  <div class="slide-header">
    <h2>Panel Title</h2>
    <button class="close-btn">×</button>
  </div>
  <div class="slide-body">
    Panel content
  </div>
</div>
```

## URL Encoding

When using data URLs, encode special characters:
- `#` → `%23`
- `%` → `%25`
- Space → `%20` (or use %25 for literal space in values)

## Tips

1. **Keep it simple** - Focus on layout and key interactions, not pixel-perfect design
2. **Use system fonts** - `system-ui, -apple-system, sans-serif` renders well
3. **Dark mode default** - Most developer tools use dark mode
4. **Screenshot after render** - Always capture with `browser_take_screenshot`
5. **Multiple views** - Create separate mockups for different states/pages

## Integration with Brainstorming

This skill is typically used during **superpowers:brainstorming** sessions when:
- Exploring navigation options
- Presenting component layouts
- Showing task detail views, modals, or slide-overs
- Comparing visual approaches side by side

Reference: "I'm using create-mockup to show you a visual preview."
