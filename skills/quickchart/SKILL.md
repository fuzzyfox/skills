---
name: quickchart
description: Generate chart images for markdown documents using the QuickChart API. Use when writing reports, READMEs, changelogs, dashboards, or any markdown output that needs an embedded chart, graph, sparkline, gauge, or data visualisation.
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

1. **Pick a chart type.** See [Best practices](references/BEST_PRACTICES.md#choosing-the-right-chart) to match the data shape to the chart, then the per-type doc in `references/` for a ready-to-edit config.
2. **Compose the Chart.js config.** Start from the relevant reference file. Keep titles short, label series clearly, use accessible colours.
3. **Build the URL** with `scripts/build-chart.js`.
4. **Embed in markdown.** Paste the `![alt](url)` snippet.
5. **Verify the URL resolves.** `curl -sI` the generated URL and confirm a `200` and an image content-type before embedding; for `--download`, confirm the file was written and is non-empty.

## Chart types

Each reference file contains a working config you can copy, plus type-specific tips. To match data to type, see [Choosing the right chart](references/BEST_PRACTICES.md#choosing-the-right-chart).

- [bar](references/bar.md) — vertical, horizontal, grouped, stacked.
- [line](references/line.md) — multi-series, filled area.
- [pie-doughnut](references/pie-doughnut.md) — pie and doughnut.
- [radar](references/radar.md) — one or two entities across shared axes.
- [scatter-bubble](references/scatter-bubble.md) — scatter and 3-dim bubble.
- [gauge](references/gauge.md) — radial gauge and speedometer.
- [sparkline](references/sparkline.md) — inline mini trends for tables/prose.
- [sankey](references/sankey.md) — flows between stages.
- [progress-bar](references/progress-bar.md) — completion against a target.
- [boxplot-violin](references/boxplot-violin.md) — boxplot and violin.
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

- [scripts/build-chart.js](scripts/build-chart.js) — composes the config into a URL and picks the transport.
- [QuickChart official documentation](https://quickchart.io/documentation/) — upstream reference for chart types, parameters, and API endpoints if troubleshooting is required.
