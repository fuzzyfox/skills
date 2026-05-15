# Mixed Charts (bar + line)

Use when you have **two related metrics with different scales or types** — volume + price, count + rate, requests + latency. Show bars for the magnitude metric, line for the rate metric, on a dual y-axis.

```json
{
  "type": "bar",
  "data": {
    "labels": ["Mon", "Tue", "Wed", "Thu", "Fri"],
    "datasets": [
      {
        "type": "bar",
        "label": "Requests (k)",
        "data": [120, 145, 138, 170, 210],
        "backgroundColor": "#56B4E9",
        "yAxisID": "y"
      },
      {
        "type": "line",
        "label": "p95 latency (ms)",
        "data": [180, 175, 190, 250, 310],
        "borderColor": "#D55E00",
        "backgroundColor": "transparent",
        "yAxisID": "y2",
        "tension": 0.3
      }
    ]
  },
  "options": {
    "plugins": { "title": { "display": true, "text": "Latency climbed as traffic grew" } },
    "scales": {
      "y":  { "beginAtZero": true, "title": { "display": true, "text": "Requests (k)" } },
      "y2": {
        "beginAtZero": true,
        "position": "right",
        "grid": { "drawOnChartArea": false },
        "title": { "display": true, "text": "p95 (ms)" }
      }
    }
  }
}
```

## Tips

- Only use dual axes when the relationship is the story. Otherwise produce two charts stacked vertically.
- Match each axis's colour to its dataset to disambiguate.
- `grid.drawOnChartArea: false` on the secondary axis prevents grid clutter.
- The line series should be the "rate" or "ratio" metric (latency, conversion %, price). Bars for counts/sums.
- Three series on one chart is the cap. Four is a dashboard, not a chart.
