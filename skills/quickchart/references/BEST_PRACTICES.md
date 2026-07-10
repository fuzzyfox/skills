# Best Practices

## Choosing the right chart

| Goal | Use |
|---|---|
| Compare categories | bar (vertical if ≤8 labels, horizontal if longer labels) |
| Show trend over time | line, or sparkline for inline use |
| Show composition | doughnut/pie for ≤6 slices, stacked bar for >6 or multi-series |
| Show distribution | boxplot, violin, or histogram-style bar |
| Show correlation | scatter (2 dims), bubble (3 dims) |
| Show flow between states | sankey |
| Show a KPI vs target | gauge or progress bar |
| Show OHLC pricing | candlestick |
| Show several metrics with different scales | mixed (bar + line, dual axis) |

If in doubt: bar for comparison, line for trend, table for everything else.

## Sizing for markdown

Defaults (500×300, retina) work for README/PR body width. For inline placement in long-form docs use:

- **Hero / dashboard tile:** 800×400
- **Inline section chart:** 500×300 (default)
- **Email-safe:** keep `width ≤ 600`, format `png`

Sparklines are a special case — see [sparkline](sparkline.md) for their dimensions.

GitHub markdown caches images via a proxy. Image URLs are fetched once and served from the GitHub camo cache, so dynamic short URLs *will* eventually 404 once they expire upstream — see [Expiration](#expiration).

## Accessibility

- Always supply meaningful alt text in `![alt](url)`. Describe the takeaway, not the chart type. "Revenue grew 30% Q1→Q4" beats "Bar chart".
- Use colour-blind safe palettes. Default Chart.js colours are not. Suggested ordered palette (Okabe-Ito):
  - `#0072B2` blue
  - `#E69F00` orange
  - `#009E73` green
  - `#CC79A7` pink
  - `#56B4E9` sky
  - `#D55E00` vermillion
  - `#F0E442` yellow
  - `#000000` black
- Never encode meaning in colour alone — also vary shape (line dash, marker), order, or labels.
- Keep contrast high against the background. For dark-mode-friendly docs, set `backgroundColor: 'transparent'` and use mid-range colours that work on both.

## Titles, labels, legends

- Title should state the takeaway, not the dimension. "Q4 revenue beat target by 12%" not "Quarterly revenue".
- Drop the legend if there's only one series.
- Format numbers with thousand separators and units. Use `ticks.callback` (passed as a JS string under POST) for currencies and percentages.

## Performance and caching

- QuickChart caches identical requests at the edge. Reuse the same URL across renders to benefit.
- Short URLs (`/chart/render/<id>`) are also cached and faster than rendering inline POSTs each time.
- For documents committed to a repo, prefer **short URLs** so the markdown stays compact and diffs stay readable.
- For one-shot rendered output (e.g., a generated PDF or email), inline GET URLs are fine.

## Templated short URLs

Use this when you have one chart shape and many data variants (per-tenant dashboards, per-team reports):

1. POST a canonical config to `https://quickchart.io/chart/create`.
2. Save the returned `url`.
3. Override per render with query string params:
   - `title=` chart title
   - `labels=A,B,C` x-axis labels
   - `data1=1,2,3`, `data2=…` per-series values
   - `label1=Sales`, `label2=Costs` series names
   - `backgroundColor1=#0072B2`, `borderColor1=…` per-series colour

Structural changes (chart type, axes, plugins) require a new short URL.

## Expiration

| Tier | API short URL | Chart Maker short URL |
|---|---|---|
| Free | ~3 days | ~60 days (resets on render) |
| Paid | ~6 months | ~6 months |

For committed markdown that must outlive these windows, download the rendered image and commit it (see [Long-lived documents](#long-lived-documents)), or pay for QuickChart and use long-lived short URLs.

## Long-lived documents

If the document outlives the short-URL TTL (committed reports, books, PDFs, archived dashboards), render once and bundle the image:

```bash
node scripts/build-chart.js --config chart.json \
  --download docs/assets/charts/q4-revenue.png \
  --rel-to docs/reports \
  --alt "Q4 revenue beat target by 12%"
# → ![Q4 revenue beat target by 12%](../assets/charts/q4-revenue.png)
```

`--download` bypasses the auto-transport entirely and POSTs directly to `/chart` for a one-shot render — the rendered bytes never have to survive on QuickChart's side.

Decide up front: **short-lived (hotlink) or long-lived (download)?** Ask the operator if it's not obvious — getting this wrong means a broken image in three days, or unnecessary binaries in the repo.

Privacy: free-tier `/chart` requests still travel to QuickChart, so don't render anything you wouldn't paste into a public gist.

## Chart.js version

- `version=2` (default 2.9.4) — broadest plugin compatibility, what the QuickChart extensions are written against.
- `version=4` — modern Chart.js options, but breaks v2 plugin syntax. Don't mix in one config.
- Stick with v2 unless you specifically need a v4 feature.

## JS callbacks

Some advanced configs need JS (e.g. `ticks.callback`, `tooltip.label`). Rules:

- You **must** use POST.
- The `chart` field must be a **string** (not a parsed object) in the request body, so the JS isn't stripped.
- Keep JS minimal — formatting only. Don't try to compute data inside the chart.

## Output format

- `png` — default, safe everywhere.
- `svg` — crisp at any zoom; not all plugins support it (gauges, sankey may fall back).
- `webp` — smaller than png; fine for web markdown, avoid for email.
- `pdf` — for print/email pipelines.
- `base64` — embed directly with `data:` URLs; bloats markdown, avoid unless offline.

## Things to avoid

- Don't hand-build URLs by string-concatenating JSON — always encode via the helper script or `encodeURIComponent`.
- Don't put secrets or PII in chart data — URLs and short URLs are public. Push back hard if the operator attempts to do this.
- Keep charts flat and 2D so length and position map straight to magnitude.
- Reach for dual y-axes only when the relationship between the two metrics is the whole point of the chart.
- Don't rely on the free-tier short URL outliving your output. If uncertain ask the operator if this is short lived or long lived output.