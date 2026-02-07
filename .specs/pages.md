# Best of Elixir — Page Specifications

> Detailed specs for each page, ready for implementation.

---

## Page 1: Homepage (`/` → `src/pages/index.ex`)

### Mount Data

```elixir
def mount(_params) do
  %{
    title: "Best of Elixir",
    hot_projects: fetch_hot_projects("today"),
    featured: fetch_featured(5)
  }
end
```

### Layout

```
┌─────────────────────────────────────────────────────────┐
│                    Navigation Bar                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   The Best of  Phoenix|                                 │
│   A place to find the best open-source projects...      │
│                                                         │
├──────────────────────────────────┬──────────────────────┤
│                                  │                      │
│  🔥 Hot Projects     [Today ▾]   │  ⭐ Featured         │
│  By stars added yesterday        │  Random order  < >   │
│                                  │                      │
│  ┌──────────────────────────┐    │  ┌────────────────┐  │
│  │ [Ph] Phoenix  ⚡🏠 +352☆ │    │  │    [Logo]      │  │
│  │ Productive. Reliable...  │    │  │   Absinthe     │  │
│  │ [web] [realtime]         │    │  │    + 7☆        │  │
│  ├──────────────────────────┤    │  │   [graphql]    │  │
│  │ [Lv] LiveView ⚡🏠 +180☆ │    │  ├────────────────┤  │
│  │ Rich, real-time UX...   │    │  │    [Logo]      │  │
│  │ [web] [realtime]         │    │  │    Oban        │  │
│  ├──────────────────────────┤    │  │    + 12☆       │  │
│  │ [Nx] Nx       ⚡🏠  +95☆ │    │  │    [jobs]      │  │
│  │ Multi-dimensional...     │    │  ├────────────────┤  │
│  │ [ml]                     │    │  │    [Logo]      │  │
│  ├──────────────────────────┤    │  │   Livebook     │  │
│  │ ...more rows...          │    │  │    + 5☆        │  │
│  └──────────────────────────┘    │  │   [devtools]   │  │
│                                  │  └────────────────┘  │
└──────────────────────────────────┴──────────────────────┘
```

### Hot Projects Row Spec

```
[Avatar] ProjectName ⚡ 🏠                    + N☆
         One-line description text...
         [tag1] [tag2]
─────────────────────────────────────────────────
```

- Avatar: 40×40, letter-based with color from palette
- Project name: `text-primary font-semibold`, links to `/projects/:id`
- ⚡ = GitHub icon (links to repo_url)
- 🏠 = Homepage icon (links to homepage_url, only if exists)
- `+ N☆`: right-aligned, `text-accent font-semibold`
- Description: `text-sm text-base-content/60`, single line, `line-clamp-1`
- Tags: `badge badge-outline badge-sm`, links to `/tags/:slug`

### Time Filter (HTMX)

```html
<select hx-get="/" hx-target="#hot-list" hx-select="#hot-list"
        name="period" class="select select-sm">
  <option value="today">Today</option>
  <option value="week">This Week</option>
  <option value="month">This Month</option>
</select>
```

### Featured Sidebar Card

```
┌──────────────────┐
│                   │
│     [ Ab ]        │  ← 56×56 letter avatar
│                   │
│    Absinthe       │  ← font-semibold, link
│     + 7☆          │  ← text-accent text-sm
│                   │
│    [graphql]      │  ← single badge
│                   │
└──────────────────┘
```

- Card: `border border-base-300 rounded-xl p-4 text-center`
- Stacked vertically in sidebar
- 4-5 cards, randomly selected on each page load

---

## Page 2: Projects (`/projects` → `src/pages/projects/index.ex`)

### Mount Data

```elixir
def mount(params) do
  sort = params["sort"] || "stars"
  tag = params["tag"]
  q = params["q"]

  %{
    title: "All Projects - Best of Elixir",
    projects: list_projects(sort: sort, tag: tag, q: q),
    tags: list_all_tags(),
    sort: sort,
    current_tag: tag,
    query: q
  }
end
```

### Layout

```
┌─────────────────────────────────────────────────────────┐
│  All Projects                              [Search...] │
│                                                         │
│  Tags: [all] [web] [database] [ml] [testing] [auth]... │
│                                                         │
│  #   Project              Description        Stars  ⚡  │
│  ─────────────────────────────────────────────────────  │
│  1   Phoenix              Productive...      22.0k☆  ⚡  │
│      [web] [realtime]                                   │
│  ─────────────────────────────────────────────────────  │
│  2   Elixir               A dynamic...      24.0k☆  ⚡  │
│      [language]                                         │
│  ─────────────────────────────────────────────────────  │
│  3   LiveView             Rich, real...      6.5k☆  ⚡  │
│      [web] [realtime]                                   │
│  ─────────────────────────────────────────────────────  │
│  ...                                                    │
└─────────────────────────────────────────────────────────┘
```

### Search (HTMX)

```html
<input type="search" name="q" placeholder="Search projects..."
       hx-get="/projects" hx-target="#project-list"
       hx-trigger="keyup changed delay:300ms"
       hx-include="[name='sort'],[name='tag']"
       class="input input-bordered input-sm w-64" />
```

### Tag Filter Bar

```html
<div class="flex flex-wrap gap-2">
  <a href="/projects" class="badge badge-primary">All</a>
  <a :for={tag <- @tags}
     href={"/projects?tag=#{tag["slug"]}"}
     class={"badge #{if @current_tag == tag["slug"], do: "badge-primary", else: "badge-outline"}"}>
    {tag["name"]}
  </a>
</div>
```

### Sort Headers

Column headers are clickable to toggle sort:

```html
<th>
  <a hx-get={"/projects?sort=stars"} hx-target="#project-list">
    Stars {if @sort == "stars", do: "↓"}
  </a>
</th>
```

---

## Page 3: Project Detail (`/projects/:id` → `src/pages/projects/[id].ex`)

### Layout

```
┌─────────────────────────────────────────────────────────┐
│  ← Back to Projects                                     │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │                                                 │    │
│  │  [Ph]  Phoenix                         22.0k☆   │    │
│  │        Productive. Reliable. Fast.     GitHub ☆ │    │
│  │        A web framework that does not            │    │
│  │        compromise on speed...                   │    │
│  │                                                 │    │
│  │  [web framework] [realtime]                     │    │
│  │                                                 │    │
│  │  ──────────────────────────────────────         │    │
│  │                                                 │    │
│  │  ⚡ Repository    🏠 Homepage                    │    │
│  │  📦 Hex Package   📖 Documentation              │    │
│  │                                                 │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Links Section

- **Repository**: `repo_url` → GitHub
- **Homepage**: `homepage_url` → project site
- **Hex Package**: `https://hex.pm/packages/{name}` (lowercase)
- **Documentation**: `https://hexdocs.pm/{name}`

---

## Page 4: Tags (`/tags` → `src/pages/tags/index.ex`)

### Layout

```
┌─────────────────────────────────────────────────────────┐
│  All Tags                                               │
│                                                         │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│  │ Web Framework│ │ Database     │ │ Machine      │    │
│  │ 5 projects   │ │ 3 projects   │ │ Learning     │    │
│  │              │ │              │ │ 4 projects   │    │
│  └──────────────┘ └──────────────┘ └──────────────┘    │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│  │ Testing      │ │ Auth         │ │ HTTP Client  │    │
│  │ 3 projects   │ │ 2 projects   │ │ 4 projects   │    │
│  └──────────────┘ └──────────────┘ └──────────────┘    │
│  ...                                                    │
└─────────────────────────────────────────────────────────┘
```

- 3-column grid (responsive: 2 on tablet, 1 on mobile)
- Each card: tag name (bold) + project count (badge)
- Sorted by project count DESC
- Clickable → `/tags/:slug`

---

## Page 5: Tag Detail (`/tags/:slug` → `src/pages/tags/[slug].ex`)

### Layout

Same as Projects page but filtered by tag:

```
┌─────────────────────────────────────────────────────────┐
│  ← Back to Tags                                         │
│                                                         │
│  Web Framework                          5 projects      │
│                                                         │
│  #   Project              Description        Stars  ⚡  │
│  ─────────────────────────────────────────────────────  │
│  1   Phoenix              Productive...      22.0k☆  ⚡  │
│  2   Bandit               A pure Elixir...    1.7k☆  ⚡  │
│  3   Ash                  Declarative...      1.6k☆  ⚡  │
│  ...                                                    │
└─────────────────────────────────────────────────────────┘
```

---

## Page 6: Trending (`/trending` → `src/pages/trending.ex`)

### Layout

```
┌─────────────────────────────────────────────────────────┐
│  Trending Projects                                      │
│                                                         │
│  [Today] [This Week] [This Month]    ← tab buttons     │
│                                                         │
│  #   Project              Description       Δ Stars  ⚡  │
│  ─────────────────────────────────────────────────────  │
│  1   Phoenix              Productive...     + 352☆   ⚡  │
│      [web] [realtime]                                   │
│  2   LiveView             Rich, real...     + 180☆   ⚡  │
│      [web] [realtime]                                   │
│  3   Nx                   Multi-dim...      + 95☆    ⚡  │
│      [ml]                                               │
│  ...                                                    │
└─────────────────────────────────────────────────────────┘
```

### Tab Switching (HTMX)

```html
<div class="tabs tabs-boxed">
  <a :for={period <- ["today", "week", "month"]}
     hx-get={"/trending?period=#{period}"}
     hx-target="#trending-list"
     class={"tab #{if @period == period, do: "tab-active"}"}>
    {String.capitalize(period)}
  </a>
</div>
```

### Key Difference from Projects Page

- Shows **star delta** (`+ N☆`) instead of total stars
- Sorted by delta, not total
- Time period filter via HTMX tabs
