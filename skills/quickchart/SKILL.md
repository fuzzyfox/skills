---
name: quickchart
description: Generate chart images for markdown documents using the QuickChart API. Use when writing reports, READMEs, changelogs, dashboards, or any markdown output that needs an embedded chart, sparkline, gauge, or data visualisation. Covers bar, line, pie, radar, scatter, bubble, gauge, sparkline, sankey, progress bar, boxplot, candlestick, and mixed charts.
license: MIT
metadata:
  author: William Duyck
  version: "1.0"
compatibility: Requires network access to quickchart.io. Helper script needs Node.js 18+ (built-in fetch).
---

# QuickChart

Render charts as PNG/SVG images hosted by QuickChart and embed them in markdown via `![alt](url)`. Pick the right transport for the data size, pick the right chart type for the message, then embed the resulting URL.

## Quick start

For a small chart, build a config object and run the helper:

```bash
node scripts/build-chart.js --type bar --title "Sales" \
  --labels "Q1,Q2,Q3,Q4" --data "12,19,8,15"
```

It prints a markdown snippet like:

```markdown
![Sales](https://quickchart.io/chart?c=%7B...%7D)
```

For a complex chart, write the Chart.js config to a JSON file and pipe it:

```bash
cat chart.json | node scripts/build-chart.js --stdin --alt "Revenue by region"
```

The script auto-picks transport: GET (base64-encoded) for small configs, POST to `/chart/create` (short URL) for large ones.

## Workflow

1. **Pick a chart type.** Match the data shape to the chart — see [Best practices](references/BEST_PRACTICES.md) for guidance, and the per-type docs in `references/` for a ready-to-edit config.
2. **Compose the Chart.js config.** Start from the relevant reference file. Keep titles short, label series clearly, use accessible colours.
3. **Build the URL.** Use `scripts/build-chart.js`. Do not hand-encode JSON into URLs.
4. **Embed in markdown.** Paste the `![alt](url)` snippet. Always set meaningful alt text.
5. **Verify.** Open the URL in a browser or include the image in a preview before shipping.

## Chart types

Each reference file contains a working config you can copy, plus type-specific tips:

- [bar](references/bar.md) — categorical comparisons, stacked, horizontal, grouped.
- [line](references/line.md) — trends over time, multi-series, filled area.
- [pie-doughnut](references/pie-doughnut.md) — parts of a whole, ≤6 slices.
- [radar](references/radar.md) — multi-axis comparison of one or two entities.
- [scatter-bubble](references/scatter-bubble.md) — correlations, 3-dim with bubble.
- [gauge](references/gauge.md) — single KPI, radial gauge or speedometer.
- [sparkline](references/sparkline.md) — inline mini trends inside tables/prose.
- [sankey](references/sankey.md) — flows between stages or categories.
- [progress-bar](references/progress-bar.md) — completion against a target.
- [boxplot-violin](references/boxplot-violin.md) — distributions across groups.
- [financial](references/financial.md) — OHLC and candlestick.
- [mixed](references/mixed.md) — bar + line combo (e.g. volume + price).

## Transport: when to use what

| Situation | Use | Why |
|---|---|---|
| Small config, < 1.5KB JSON | GET, URL-encoded | Simplest, no extra request. |
| Medium config, 1.5–6KB | GET, `encoding=base64` | Avoids escaping issues. |
| Large config or contains JS callbacks | POST `/chart` (inline render) | No URL limits; functions stay intact. |
| Reusable across many renders or want a stable short link in the markdown | POST `/chart/create` → short URL | Returns a clean `quickchart.io/chart/render/<id>` URL. |
| Templated dashboards (same shape, varying data) | POST once to `/chart/create`, override with `?title=…&labels=…&data1=…` | One config, many renders. |
| Long-lived document (committed report, book, PDF) | `--download path/to.png` | Save the rendered bytes; embed the local path. Survives short-URL expiration. |

The helper script handles the first four automatically. Pass `--download` for long-lived documents (see [Best practices](references/BEST_PRACTICES.md#long-lived-documents)). For templated dashboards see [Best practices](references/BEST_PRACTICES.md#templated-short-urls).

## See also

- [Best practices](references/BEST_PRACTICES.md) — accessibility, colour, sizing, caching, expiration gotchas.
- [scripts/build-chart.js](scripts/build-chart.js) — the only utility you should need.
