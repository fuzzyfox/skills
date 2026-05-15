# Radar Charts

Use for **multi-axis comparison** of one or two entities across the same dimensions (e.g. skills profile, product feature comparison). Avoid more than two overlaid polygons.

```json
{
  "type": "radar",
  "data": {
    "labels": ["Speed", "Reliability", "Cost", "Coverage", "Support", "Docs"],
    "datasets": [
      {
        "label": "Vendor A",
        "data": [8, 7, 5, 9, 6, 8],
        "borderColor": "#0072B2",
        "backgroundColor": "rgba(0,114,178,0.2)"
      },
      {
        "label": "Vendor B",
        "data": [6, 9, 8, 5, 7, 6],
        "borderColor": "#E69F00",
        "backgroundColor": "rgba(230,159,0,0.2)"
      }
    ]
  },
  "options": {
    "plugins": { "title": { "display": true, "text": "Vendor A vs B" } },
    "scales": { "r": { "beginAtZero": true, "max": 10 } }
  }
}
```

## Tips

- Set a fixed max (`scales.r.max`) so the polygons are comparable.
- Keep dimensions to 5–8. More becomes unreadable.
- Order dimensions so related axes are adjacent (you'll get cleaner shapes).
- Don't use for many entities — overlapping polygons turn into a mess.
