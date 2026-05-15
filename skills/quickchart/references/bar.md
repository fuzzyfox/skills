# Bar Charts

Use for **categorical comparisons**. Vertical if labels are short or ordered (time, size). Horizontal if labels are long or there are many categories. Stacked when each bar has subparts that sum to a meaningful total.

## Vertical bar

```json
{
  "type": "bar",
  "data": {
    "labels": ["Q1", "Q2", "Q3", "Q4"],
    "datasets": [{
      "label": "Revenue ($k)",
      "data": [120, 150, 180, 210],
      "backgroundColor": "#0072B2"
    }]
  },
  "options": {
    "plugins": { "title": { "display": true, "text": "Revenue grew 75% across FY26" } },
    "scales": { "y": { "beginAtZero": true } }
  }
}
```

## Horizontal bar

In Chart.js v2 use `"type": "horizontalBar"`. In v4 use `"type": "bar"` with `indexAxis: 'y'`.

```json
{
  "type": "horizontalBar",
  "data": {
    "labels": ["Engineering", "Product", "Design", "Ops", "Sales"],
    "datasets": [{ "label": "Headcount", "data": [42, 18, 9, 12, 25], "backgroundColor": "#009E73" }]
  }
}
```

## Grouped (multi-series)

```json
{
  "type": "bar",
  "data": {
    "labels": ["Jan", "Feb", "Mar", "Apr"],
    "datasets": [
      { "label": "2025", "data": [30, 35, 40, 38], "backgroundColor": "#56B4E9" },
      { "label": "2026", "data": [42, 48, 55, 60], "backgroundColor": "#0072B2" }
    ]
  }
}
```

## Stacked

Add `stacked: true` on both axes:

```json
"scales": {
  "x": { "stacked": true },
  "y": { "stacked": true, "beginAtZero": true }
}
```

## Tips

- Sort bars by value unless the axis is naturally ordered.
- Always start the y-axis at zero — truncating a bar chart lies.
- Cap to ~12 categories; beyond that, switch to horizontal or a treemap.
- For grouped bars with >2 series, consider small multiples instead.
