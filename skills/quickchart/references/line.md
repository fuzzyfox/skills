# Line Charts

Use for **trends over time** or any ordered continuous x-axis. Multiple series allowed but keep it to ≤5 lines or the chart becomes spaghetti.

## Single series

```json
{
  "type": "line",
  "data": {
    "labels": ["Wk1", "Wk2", "Wk3", "Wk4", "Wk5", "Wk6"],
    "datasets": [{
      "label": "Active users",
      "data": [1200, 1450, 1380, 1610, 1820, 2100],
      "borderColor": "#0072B2",
      "backgroundColor": "rgba(0,114,178,0.1)",
      "fill": true,
      "tension": 0.3
    }]
  },
  "options": {
    "plugins": { "title": { "display": true, "text": "Active users +75% in 6 weeks" } },
    "scales": { "y": { "beginAtZero": true } }
  }
}
```

## Multi-series

```json
{
  "type": "line",
  "data": {
    "labels": ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],
    "datasets": [
      { "label": "Desktop", "data": [320,310,340,330,380,290,260], "borderColor": "#0072B2", "fill": false },
      { "label": "Mobile",  "data": [410,440,460,470,520,610,580], "borderColor": "#E69F00", "fill": false },
      { "label": "Tablet",  "data": [60,55,70,65,80,90,85],       "borderColor": "#009E73", "fill": false }
    ]
  }
}
```

## Filled area

Set `fill: true` and a translucent `backgroundColor`. For stacked area, set `fill: 'origin'` on dataset 1 and `fill: '-1'` on subsequent datasets, plus `scales.y.stacked: true`.

## Tips

- `tension: 0.3` softens lines. `0` is pure straight-segment.
- For sparse data (e.g. monthly), `pointRadius: 4` makes points readable.
- Use solid for the primary series, dashed (`borderDash: [6,4]`) for forecasts or comparisons.
- Don't fill multiple overlapping lines — readers can't see what's underneath.
