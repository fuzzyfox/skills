# Progress Bar

Use for **single-value progress against a target**: feature rollout %, fundraising progress, sprint burn-down. For multi-segment progress (e.g. status breakdown), use a single horizontal stacked bar instead.

## Native progress (single value)

QuickChart has a `progressBar` shorthand:

```
https://quickchart.io/chart?cht=pb&chd=t:65
```

Use it directly for the simplest case — no Chart.js config needed.

## Stacked-bar progress (multi-segment)

```json
{
  "type": "horizontalBar",
  "data": {
    "labels": ["Q1 plan"],
    "datasets": [
      { "label": "Done",       "data": [42], "backgroundColor": "#009E73" },
      { "label": "In progress","data": [18], "backgroundColor": "#F0E442" },
      { "label": "Blocked",    "data": [7],  "backgroundColor": "#D55E00" },
      { "label": "Todo",       "data": [33], "backgroundColor": "#eaeaea" }
    ]
  },
  "options": {
    "scales": {
      "x": { "stacked": true, "max": 100, "title": { "display": true, "text": "% of plan" } },
      "y": { "stacked": true, "display": false }
    },
    "plugins": {
      "title": { "display": true, "text": "Q1 plan: 60% complete, 7% blocked" },
      "legend": { "position": "bottom" }
    }
  }
}
```

Render at **800×80** for a slim progress strip.

## Tips

- Always show the target/total — a bar at 80% means nothing without "of $50k goal".
- For "X of Y" framing, normalise to percentages on the axis but keep the absolute total in the title.
- Avoid stacking more than four segments; merge tail categories.
- Use colour to encode status (green/amber/red), not to decorate.
