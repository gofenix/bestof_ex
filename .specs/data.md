# Best of Elixir — Data & Query Specifications

> Database schema, seed strategy, and query patterns.

---

## 1. Schema

### projects

```sql
CREATE TABLE projects (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  description TEXT,
  repo_url    VARCHAR(500) NOT NULL UNIQUE,
  homepage_url VARCHAR(500),
  stars       INTEGER DEFAULT 0,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at  TIMESTAMP DEFAULT NOW()
);
```

### tags

```sql
CREATE TABLE tags (
  id   SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE
);
```

### project_tags

```sql
CREATE TABLE project_tags (
  project_id INTEGER REFERENCES projects(id),
  tag_id     INTEGER REFERENCES tags(id),
  PRIMARY KEY (project_id, tag_id)
);
```

### project_stats (star history for trending)

```sql
CREATE TABLE project_stats (
  id          SERIAL PRIMARY KEY,
  project_id  INTEGER REFERENCES projects(id),
  stars       INTEGER NOT NULL,
  recorded_at DATE NOT NULL,
  UNIQUE(project_id, recorded_at)
);

CREATE INDEX idx_stats_project_date ON project_stats(project_id, recorded_at);
CREATE INDEX idx_stats_date ON project_stats(recorded_at);
```

---

## 2. Key Queries

### 2.1 Hot Projects (star delta for a time period)

The core query that powers the homepage and trending page.

```sql
-- Hot projects: stars gained today
SELECT p.*, 
       (p.stars - COALESCE(ps.stars, p.stars)) AS star_delta
FROM projects p
LEFT JOIN project_stats ps 
  ON ps.project_id = p.id 
  AND ps.recorded_at = CURRENT_DATE - INTERVAL '1 day'
ORDER BY star_delta DESC
LIMIT 10;
```

**NexBase equivalent:**

```elixir
defp fetch_hot_projects(period) do
  interval = case period do
    "today" -> "1 day"
    "week"  -> "7 days"
    "month" -> "30 days"
    _       -> "1 day"
  end

  {:ok, rows} = NexBase.sql("""
    SELECT p.id, p.name, p.description, p.repo_url, p.homepage_url, p.stars,
           (p.stars - COALESCE(ps.stars, p.stars)) AS star_delta
    FROM projects p
    LEFT JOIN project_stats ps
      ON ps.project_id = p.id
      AND ps.recorded_at = CURRENT_DATE - INTERVAL '#{interval}'
    ORDER BY star_delta DESC
    LIMIT 10
  """)

  rows
end
```

### 2.2 Featured Projects (random sample)

```elixir
defp fetch_featured(count) do
  {:ok, rows} = NexBase.sql("""
    SELECT p.id, p.name, p.stars,
           (p.stars - COALESCE(ps.stars, p.stars)) AS star_delta,
           (SELECT t.name FROM tags t
            JOIN project_tags pt ON pt.tag_id = t.id
            WHERE pt.project_id = p.id
            LIMIT 1) AS primary_tag
    FROM projects p
    LEFT JOIN project_stats ps
      ON ps.project_id = p.id
      AND ps.recorded_at = CURRENT_DATE - INTERVAL '1 day'
    ORDER BY RANDOM()
    LIMIT $1
  """, [count])

  rows
end
```

### 2.3 All Projects (with sort + filter)

```elixir
defp list_projects(opts) do
  sort = opts[:sort] || "stars"
  tag = opts[:tag]
  q = opts[:q]

  order = case sort do
    "name" -> "p.name ASC"
    "trend" -> "star_delta DESC"
    _ -> "p.stars DESC"
  end

  tag_join = if tag, do: """
    JOIN project_tags pt ON pt.project_id = p.id
    JOIN tags t ON t.id = pt.tag_id AND t.slug = '#{tag}'
  """, else: ""

  search = if q && q != "", do: """
    AND (p.name ILIKE '%#{q}%' OR p.description ILIKE '%#{q}%')
  """, else: ""

  {:ok, rows} = NexBase.sql("""
    SELECT p.id, p.name, p.description, p.repo_url, p.homepage_url, p.stars,
           (p.stars - COALESCE(ps.stars, p.stars)) AS star_delta
    FROM projects p
    LEFT JOIN project_stats ps
      ON ps.project_id = p.id
      AND ps.recorded_at = CURRENT_DATE - INTERVAL '1 day'
    #{tag_join}
    WHERE 1=1 #{search}
    ORDER BY #{order}
  """)

  rows
end
```

> **Note**: In production, use parameterized queries (`$1`, `$2`) to prevent SQL injection.
> The above is simplified for spec clarity.

### 2.4 Project Tags

```elixir
defp get_project_tags(project_id) do
  {:ok, rows} = NexBase.sql("""
    SELECT t.name, t.slug
    FROM tags t
    JOIN project_tags pt ON pt.tag_id = t.id
    WHERE pt.project_id = $1
    ORDER BY t.name
  """, [project_id])

  rows
end
```

### 2.5 Tags with Counts

```elixir
defp list_tags_with_counts do
  {:ok, rows} = NexBase.sql("""
    SELECT t.id, t.name, t.slug, COUNT(pt.project_id) as project_count
    FROM tags t
    LEFT JOIN project_tags pt ON pt.tag_id = t.id
    GROUP BY t.id, t.name, t.slug
    ORDER BY project_count DESC, t.name ASC
  """)

  rows
end
```

### 2.6 Tag Projects

```elixir
defp get_tag_projects(slug) do
  {:ok, rows} = NexBase.sql("""
    SELECT p.id, p.name, p.description, p.stars, p.repo_url, p.homepage_url
    FROM projects p
    JOIN project_tags pt ON pt.project_id = p.id
    JOIN tags t ON t.id = pt.tag_id
    WHERE t.slug = $1
    ORDER BY p.stars DESC
  """, [slug])

  rows
end
```

---

## 3. Star Snapshot Strategy

### Daily Cron Job

Record current star counts daily to enable trending calculations:

```elixir
# seeds/snapshot.exs — run daily via cron
Nex.Env.init()
NexBase.init(url: Nex.Env.get(:database_url), ssl: true, start: true)

today = Date.to_iso8601(Date.utc_today())

{:ok, projects} = NexBase.from("projects")
|> NexBase.select([:id, :stars])
|> NexBase.run()

Enum.each(projects, fn %{id: id, stars: stars} ->
  NexBase.sql("""
    INSERT INTO project_stats (project_id, stars, recorded_at)
    VALUES ($1, $2, $3)
    ON CONFLICT (project_id, recorded_at) DO UPDATE SET stars = $2
  """, [id, stars, today])
end)

IO.puts("Snapshot recorded for #{length(projects)} projects")
```

### GitHub Star Sync (Future)

```elixir
# seeds/sync_stars.exs — fetch latest star counts from GitHub API
# For each project:
#   1. GET https://api.github.com/repos/{owner}/{repo}
#   2. Extract stargazers_count
#   3. Update projects.stars
#   4. Record snapshot in project_stats
```

---

## 4. Seed Data Categories

### Elixir Ecosystem Taxonomy

```
Web Framework     → Phoenix, Plug, Bandit, Ash
Database          → Ecto, Postgrex, EctoEnum, Flop
Real-time         → LiveView, Phoenix.PubSub
Machine Learning  → Nx, Axon, Bumblebee, Explorer, Scholar
Background Jobs   → Oban, Broadway, GenStage, Flow
Testing           → ExUnit, Mox, ExMachina, Wallaby, Bypass
Authentication    → Guardian, Pow, Ueberauth, Assent
HTTP Client       → Tesla, Finch, Req, Mint
DevTools          → Credo, Dialyxir, Livebook, Mix
Embedded/IoT      → Nerves, Circuits.GPIO, Vintage Net
GraphQL           → Absinthe, Dataloader
CQRS/ES           → Commanded, EventStore
Deployment        → Burrito, Bakeware
Parsing           → NimbleParsec, Floki, Sweet XML
Crypto            → Cloak, Comeonin, Bcrypt
CLI               → Owl, Optimus, CliSpinners
Monitoring        → Telemetry, PromEx, Flame
Multimedia        → Membrane, Image, Evision
```

---

## 5. Data Flow Summary

```
GitHub API  →  sync_stars.exs  →  projects.stars (updated)
                                      ↓
                               snapshot.exs (daily)
                                      ↓
                               project_stats (history)
                                      ↓
                               star_delta = current - past
                                      ↓
                               Hot Projects / Trending
```
