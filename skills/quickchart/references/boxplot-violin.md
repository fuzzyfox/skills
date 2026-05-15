# Box Plot & Violin

Use for **distributions across groups** — latency by endpoint, salary by role, page-load by country. Box plot is more compact; violin shows shape.

Requires `version=2` (QuickChart bundles `chartjs-chart-box-and-violin-plot`).

## Box plot

```json
{
  "type": "boxplot",
  "data": {
    "labels": ["/api/login", "/api/search", "/api/checkout", "/api/profile"],
    "datasets": [{
      "label": "p50–p99 latency (ms)",
      "backgroundColor": "rgba(0,114,178,0.3)",
      "borderColor": "#0072B2",
      "data": [
        [110, 145, 180, 220, 410],
        [80, 95, 120, 160, 290],
        [250, 320, 410, 540, 980],
        [60, 75, 90, 110, 170]
      ]
    }]
  },
  "options": {
    "plugins": { "title": { "display": true, "text": "/api/checkout is the slowest path" } }
  }
}
```

Each inner array is `[min, q1, median, q3, max]`. You can also pass raw samples and let the plugin compute quartiles:

```json
"data": [
  [110, 120, 130, 140, 145, 150, 160, 180, 200, 220, 410]
]
```

## Violin

Same shape, just `"type": "violin"` (or `horizontalViolin`).

## Tips

- Sort groups by median for fast visual ranking.
- Use horizontal variants when group labels are long.
- Add the n per group in the label or prose (`"/api/login (n=1.2k)"`) — distributions without sample size mislead.
- For one or two groups, prefer a histogram. Box plots shine at ≥3.
