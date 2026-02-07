# Best of Elixir — Component Specifications

> Reusable UI components, mapped to Nex module structure.

---

## Component Map

| Component         | Location                          | Used In                    |
|-------------------|-----------------------------------|----------------------------|
| Letter Avatar     | `src/components/avatar.ex`        | All project lists          |
| Project Row       | `src/components/project_row.ex`   | Home, Projects, Tags, Trending |
| Featured Card     | `src/components/featured_card.ex` | Home sidebar               |
| Tag Badge         | `src/components/tag_badge.ex`     | All project lists          |
| Star Count        | inline helper                     | All project displays       |
| Section Header    | inline helper                     | Home, Projects, Trending   |

---

## C1: Letter Avatar (`src/components/avatar.ex`)

Generates a colored square with initials when no project logo is available.

### Interface

```elixir
defmodule BestofEx.Components.Avatar do
  use Nex

  @palette [
    "#4B275F", "#6B3FA0", "#E44D26", "#3B82F6",
    "#10B981", "#8B5CF6", "#EC4899", "#F59E0B",
    "#06B6D4", "#EF4444", "#14B8A6", "#A855F7"
  ]

  def render(assigns) do
    ~H"""
    <div class={"w-#{@size} h-#{@size} rounded-lg flex items-center justify-center text-white font-bold text-sm shrink-0"}
         style={"background-color: #{color_for(@name)}"}>
      {initials(@name)}
    </div>
    """
  end

  defp initials(name) do
    name
    |> String.split(~r/[\s_-]/)
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  defp color_for(name) do
    index = :erlang.phash2(name, length(@palette))
    Enum.at(@palette, index)
  end
end
```

### Usage

```elixir
<Avatar name="Phoenix" size="10" />
<Avatar name="Live View" size="14" />
```

### Sizes

| Context        | Size class | Pixels |
|----------------|------------|--------|
| Project row    | `w-10 h-10`| 40×40  |
| Featured card  | `w-14 h-14`| 56×56  |
| Project detail | `w-16 h-16`| 64×64  |

---

## C2: Project Row (`src/components/project_row.ex`)

A single project entry in a list. Used on Home (hot), Projects, Tags, Trending.

### Interface

```elixir
defmodule BestofEx.Components.ProjectRow do
  use Nex

  def render(assigns) do
    ~H"""
    <div class="flex items-start gap-4 py-4 border-b border-base-200">
      <Avatar name={@project["name"]} size="10" />

      <div class="flex-1 min-w-0">
        <div class="flex items-center gap-2">
          <a href={"/projects/#{@project["id"]}"} class="font-semibold text-primary hover:underline">
            {@project["name"]}
          </a>
          <a :if={@project["repo_url"]} href={@project["repo_url"]} target="_blank"
             class="text-base-content/30 hover:text-base-content/60">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">...</svg>
          </a>
          <a :if={@project["homepage_url"]} href={@project["homepage_url"]} target="_blank"
             class="text-base-content/30 hover:text-base-content/60">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor">...</svg>
          </a>
        </div>

        <p class="text-sm text-base-content/60 line-clamp-1 mt-0.5">
          {@project["description"]}
        </p>

        <div :if={@tags != []} class="flex flex-wrap gap-1.5 mt-2">
          <TagBadge :for={tag <- @tags} name={tag["name"]} slug={tag["slug"]} />
        </div>
      </div>

      <div class="text-right shrink-0">
        <span class="text-accent font-semibold text-sm">
          {format_star_value(@project, @mode)}
        </span>
      </div>
    </div>
    """
  end
end
```

### Props

| Prop      | Type   | Description                              |
|-----------|--------|------------------------------------------|
| `project` | map    | Project data from NexBase                |
| `tags`    | list   | Associated tags (optional, default `[]`) |
| `mode`    | atom   | `:total` shows `22.0k☆`, `:delta` shows `+ 352☆` |
| `rank`    | integer| Optional rank number (for Projects page) |

### Variants

**Hot Projects (Home)**: `mode: :delta`, no rank
```
[Ph] Phoenix ⚡ 🏠                              + 352☆
     Productive. Reliable. Fast...
     [web] [realtime]
```

**All Projects**: `mode: :total`, with rank
```
1  [Ph] Phoenix ⚡ 🏠                            22.0k☆
       Productive. Reliable. Fast...
       [web] [realtime]
```

**Trending**: `mode: :delta`, with rank
```
1  [Ph] Phoenix ⚡ 🏠                            + 352☆
       Productive. Reliable. Fast...
       [web] [realtime]
```

---

## C3: Featured Card (`src/components/featured_card.ex`)

Sidebar card for featured projects on the homepage.

### Interface

```elixir
defmodule BestofEx.Components.FeaturedCard do
  use Nex

  def render(assigns) do
    ~H"""
    <a href={"/projects/#{@project["id"]}"} class="block border border-base-300 rounded-xl p-4 text-center hover:shadow-md transition-shadow">
      <div class="flex justify-center mb-2">
        <Avatar name={@project["name"]} size="14" />
      </div>
      <div class="font-semibold text-primary text-sm">{@project["name"]}</div>
      <div class="text-accent text-xs font-semibold mt-1">
        + {@project["star_delta"] || 0}☆
      </div>
      <div :if={@tag} class="mt-2">
        <span class="badge badge-outline badge-xs">{@tag}</span>
      </div>
    </a>
    """
  end
end
```

### Props

| Prop      | Type   | Description                |
|-----------|--------|----------------------------|
| `project` | map    | Project data               |
| `tag`     | string | Primary tag name (optional)|

---

## C4: Tag Badge (`src/components/tag_badge.ex`)

Small clickable tag pill.

### Interface

```elixir
defmodule BestofEx.Components.TagBadge do
  use Nex

  def render(assigns) do
    ~H"""
    <a href={"/tags/#{@slug}"} class="badge badge-outline badge-sm hover:badge-primary transition-colors">
      {@name}
    </a>
    """
  end
end
```

### Props

| Prop   | Type   | Description      |
|--------|--------|------------------|
| `name` | string | Display name     |
| `slug` | string | URL slug         |

---

## Inline Helpers (in page modules)

### Star Formatting

```elixir
defp format_stars(n) when n >= 1000, do: "#{Float.round(n / 1000, 1)}k☆"
defp format_stars(n), do: "#{n}☆"

defp format_delta(n) when n > 0, do: "+ #{format_stars(n)}"
defp format_delta(n) when n < 0, do: "- #{format_stars(abs(n))}"
defp format_delta(_), do: "—"
```

### Section Header

```elixir
defp section_header(assigns) do
  ~H"""
  <div class="flex items-center justify-between mb-4">
    <div>
      <h2 class="text-xl font-bold flex items-center gap-2">
        <span>{@icon}</span> {@title}
      </h2>
      <p :if={assigns[:subtitle]} class="text-sm text-base-content/50">{@subtitle}</p>
    </div>
    <div :if={assigns[:right]}>{@right}</div>
  </div>
  """
end
```
