# Best of Elixir — Design Specification

> Inspired by [bestofjs.org](https://bestofjs.org), adapted for the Elixir ecosystem.
> Built with Nex Framework + NexBase + DaisyUI + HTMX.

---

## 1. Brand Identity

- **Name**: Best of Elixir
- **Tagline**: The best open-source projects in the Elixir ecosystem
- **Primary Color**: Elixir Purple (`#4B275F`) — the iconic Elixir brand color
- **Accent Color**: Phoenix Orange (`#F59E0B`) — for stars, trends, highlights
- **Logo Text**: `bestof` (purple) + `ex` (orange) — nod to `.ex` file extension
- **Tone**: Developer-focused, data-driven, minimal

---

## 2. Layout Structure

### 2.1 Global Navigation

```
┌─────────────────────────────────────────────────────────┐
│  bestofex    Home  Projects  Tags  Trending    [Search] │
└─────────────────────────────────────────────────────────┘
```

- **Left**: Brand logo (`bestofex` styled text)
- **Center**: Nav links — Home, Projects, Tags, Trending
- **Right**: Search input with `⌘K` hint
- **Style**: Clean white bar, no heavy borders, subtle bottom shadow

### 2.2 Homepage — Two-Column Layout

```
┌──────────────────────────────────┬──────────────┐
│  Hero (full width)               │              │
├──────────────────────────────────┤              │
│                                  │  Featured    │
│  🔥 Hot Projects                 │  ⭐ Random   │
│  By stars added yesterday        │              │
│  ┌──────────────────────────┐    │  ┌────────┐  │
│  │ 🟣 Phoenix  ⚡ 🏠  +352☆ │    │  │  Logo  │  │
│  │ Web framework that...    │    │  │ Absin  │  │
│  │ [web] [realtime]         │    │  │ + 7☆   │  │
│  ├──────────────────────────┤    │  │[graphql]│  │
│  │ 🟣 LiveView ⚡ 🏠  +180☆ │    │  └────────┘  │
│  │ Rich, real-time UX...    │    │  ┌────────┐  │
│  │ [web] [realtime]         │    │  │  Logo  │  │
│  └──────────────────────────┘    │  │ Oban   │  │
│                                  │  │ + 12☆  │  │
│                                  │  │ [jobs] │  │
│                                  │  └────────┘  │
└──────────────────────────────────┴──────────────┘
```

- **Left column** (~70%): Hot Projects list
- **Right column** (~30%): Featured sidebar
- Responsive: stacks vertically on mobile

### 2.3 Other Pages

- **Projects**: Full-width ranked table
- **Tags**: Grid of tag cards with project counts
- **Tag Detail**: Filtered project list
- **Project Detail**: Full project info + tags + links
- **Trending**: Time-filtered ranked list

---

## 3. Component Specifications

### 3.1 Hero Section

```html
<section class="py-12 text-center">
  <h1 class="text-4xl font-bold">
    The Best of <span class="typing-effect">Phoenix|</span>
  </h1>
  <p class="text-base-content/60">
    A place to find the best open-source projects in the Elixir ecosystem:
    Phoenix, Ecto, LiveView, Nx, Nerves, Oban...
  </p>
</section>
```

- Title cycles through: `Phoenix`, `Ecto`, `LiveView`, `Nx`, `Nerves`, `Oban`
- Typing animation via CSS only (no JS, Nex-idiomatic)
- Subtitle lists key ecosystem names

### 3.2 Hot Projects Row

Each project row in the hot list:

```
┌─────────────────────────────────────────────────────┐
│  [Logo]  ProjectName  ⚡ 🏠     Description...  +N☆ │
│          [tag1] [tag2]                              │
└─────────────────────────────────────────────────────┘
```

- **Logo**: 40x40 rounded square (first letter fallback with purple bg)
- **Project Name**: Bold, purple link
- **Icons**: GitHub (⚡) and Homepage (🏠) as small gray icons
- **Description**: Single line, truncated, gray text
- **Star Delta**: Right-aligned, orange, `+ N☆` format
- **Tags**: Small outline badges below description
- **Divider**: Thin `border-b` between rows

### 3.3 Featured Card (Sidebar)

```
┌────────────────┐
│    [  Logo  ]   │
│   ProjectName   │
│     + 7☆        │
│    [tag]        │
└────────────────┘
```

- Centered layout
- Large logo (64x64)
- Project name below
- Star delta in orange
- Single primary tag
- Thin border, subtle hover shadow

### 3.4 Project Row (Projects Page)

```
#  Name              Description              Stars    Links
1  Phoenix           Productive. Reliable...  22.0k☆   ⚡ 🏠
   [web] [realtime]
```

- Rank number (gray, bold)
- Name as purple link
- Description truncated
- Total stars (not delta)
- GitHub + Homepage icons
- Tags as inline badges

### 3.5 Tag Badge

```html
<a href="/tags/web-framework" class="badge badge-outline badge-sm">
  web framework
</a>
```

- Outline style, no fill
- Small size
- Rounded corners
- Gray border, hover turns purple
- Clickable → tag detail page

### 3.6 Letter Avatar (Logo Fallback)

When a project has no logo image, generate a letter avatar:

```
┌──────┐
│  Ph  │   ← First 2 letters of project name
└──────┘
```

- Background: derived from project name hash → pick from palette
- Palette: Elixir purple shades + complementary colors
- Text: White, bold, centered
- Shape: Rounded square (rounded-lg)

---

## 4. Color Palette

| Token           | Value     | Usage                          |
|-----------------|-----------|--------------------------------|
| `--primary`     | `#4B275F` | Elixir purple — links, brand   |
| `--accent`      | `#F59E0B` | Star counts, trends, highlights|
| `--base-100`    | `#FFFFFF` | Page background                |
| `--base-200`    | `#F9FAFB` | Card backgrounds, alternating  |
| `--base-300`    | `#E5E7EB` | Borders, dividers              |
| `--base-content`| `#1F2937` | Primary text                   |
| `--neutral`     | `#6B7280` | Secondary text, descriptions   |

DaisyUI theme config (in layout `<html data-theme="bestofex">`):

```css
[data-theme="bestofex"] {
  --p: 280 40% 26%;    /* Elixir purple */
  --pf: 280 40% 20%;
  --a: 38 92% 50%;     /* Phoenix orange */
  --b1: 0 0% 100%;
  --b2: 210 20% 98%;
  --b3: 220 14% 90%;
  --bc: 220 13% 18%;
  --n: 220 9% 46%;
}
```

---

## 5. Typography

| Element       | Size    | Weight | Color            |
|---------------|---------|--------|------------------|
| Hero title    | 2.5rem  | 800    | base-content     |
| Section title | 1.25rem | 700    | base-content     |
| Project name  | 1rem    | 600    | primary (purple) |
| Description   | 0.875rem| 400    | neutral (gray)   |
| Star count    | 0.875rem| 600    | accent (orange)  |
| Tag badge     | 0.75rem | 500    | neutral          |
| Nav links     | 0.875rem| 500    | base-content     |

---

## 6. Data Model

### 6.1 Core Metric: Star Delta (趋势)

bestofjs 的核心不是总星数，而是**星标增量**：

```
star_delta = today_stars - yesterday_stars
```

- `project_stats` 表记录每日快照
- Hot Projects 按 `star_delta` 降序排列
- 支持 Today / This Week / This Month 时间窗口

### 6.2 Time Windows

| Filter    | Calculation                              |
|-----------|------------------------------------------|
| Today     | `stars_today - stars_yesterday`           |
| This Week | `stars_today - stars_7_days_ago`          |
| This Month| `stars_today - stars_30_days_ago`         |
| This Year | `stars_today - stars_365_days_ago`        |

### 6.3 Featured Projects

- Random selection from all projects
- Rotates on page load (server-side random)
- Shows 4-5 projects in sidebar
- Each with logo, name, star delta, primary tag

---

## 7. Page Specifications

### 7.1 Homepage (`/`)

| Section        | Data Source                    | Sort          |
|----------------|-------------------------------|---------------|
| Hero           | Static + CSS animation        | —             |
| Hot Projects   | `project_stats` JOIN projects | star_delta DESC|
| Featured       | Random sample from projects   | Random        |

### 7.2 Projects (`/projects`)

| Feature        | Implementation                |
|----------------|-------------------------------|
| Ranked list    | All projects, numbered        |
| Sort options   | Stars (default), Name, Trend  |
| Tag filter     | Click tag → filter list       |
| Search         | HTMX `hx-get` with debounce  |

### 7.3 Tags (`/tags`)

| Feature        | Implementation                |
|----------------|-------------------------------|
| Tag cards      | Grid layout, 3 columns        |
| Project count  | SQL COUNT via JOIN             |
| Sort           | By project count DESC          |

### 7.4 Trending (`/trending`)

| Feature        | Implementation                |
|----------------|-------------------------------|
| Time filter    | Today / Week / Month tabs     |
| Ranked list    | By star_delta for time window |
| HTMX tabs      | `hx-get="/trending?period=week"` |

### 7.5 Project Detail (`/projects/:id`)

| Section        | Content                       |
|----------------|-------------------------------|
| Header         | Name, description, star count |
| Links          | GitHub repo, Homepage         |
| Tags           | All associated tags           |
| Stats          | Star history (if available)   |

---

## 8. Elixir Ecosystem Flavor

### 8.1 Curated Project Categories

| Category          | Examples                              |
|-------------------|---------------------------------------|
| Web Framework     | Phoenix, Plug, Bandit                 |
| Database          | Ecto, Postgrex, Ecto.Enum            |
| Real-time         | LiveView, Phoenix.PubSub, Channels   |
| Machine Learning  | Nx, Axon, Bumblebee, Explorer        |
| Background Jobs   | Oban, Broadway, GenStage             |
| Testing           | ExUnit, Mox, ExMachina, Wallaby      |
| Authentication    | Guardian, Pow, Ueberauth             |
| HTTP Client       | Tesla, Finch, Req, Mint              |
| DevTools          | Credo, Dialyxir, Livebook            |
| Embedded          | Nerves, Circuits                     |
| GraphQL           | Absinthe                             |
| CQRS/ES           | Commanded, EventStore                |
| Deployment        | Burrito, Bakeware, Fly.io tools      |

### 8.2 Elixir-Specific UI Elements

- **Hex badge**: Link to hex.pm package page
- **Docs badge**: Link to hexdocs.pm
- **Elixir version**: Minimum supported Elixir version
- **OTP compatibility**: If relevant
- **Mix install snippet**: `{:phoenix, "~> 1.7"}` copyable

### 8.3 Letter Avatar Color Palette (Elixir-themed)

```
#4B275F  — Elixir Purple (deep)
#6B3FA0  — Elixir Purple (light)
#E44D26  — Phoenix Orange
#3B82F6  — Ecto Blue
#10B981  — Livebook Green
#8B5CF6  — Nx Violet
#EC4899  — Nerves Pink
#F59E0B  — Oban Amber
```

---

## 9. Responsive Breakpoints

| Breakpoint | Layout                                    |
|------------|-------------------------------------------|
| `< 640px`  | Single column, no sidebar, compact rows   |
| `640-1024px`| Single column, sidebar below main        |
| `> 1024px` | Two-column (70/30), full nav              |

---

## 10. HTMX Interaction Patterns

| Interaction          | Implementation                          |
|----------------------|-----------------------------------------|
| Time filter switch   | `hx-get="/hot?period=week" hx-target="#hot-list"` |
| Search projects      | `hx-get="/projects?q=..." hx-trigger="keyup changed delay:300ms"` |
| Tag filter           | `hx-get="/projects?tag=web" hx-target="#project-list"` |
| Featured rotation    | Server-side random on each page load    |
| Sort toggle          | `hx-get="/projects?sort=name" hx-target="#project-list"` |

All interactions follow Nex's HTMX-first principle: no JavaScript, server-rendered partials.
