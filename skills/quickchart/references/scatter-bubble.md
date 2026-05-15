# Scatter & Bubble

Use **scatter** to show correlation between two continuous variables. Use **bubble** when you need a third dimension encoded as point size.

## Scatter

```json
{
  "type": "scatter",
  "data": {
    "datasets": [{
      "label": "Sessions vs revenue",
      "data": [
        {"x": 120, "y": 14},
        {"x": 340, "y": 38},
        {"x": 510, "y": 42},
        {"x": 800, "y": 61},
        {"x": 950, "y": 90}
      ],
      "backgroundColor": "#0072B2"
    }]
  },
  "options": {
    "scales": {
      "x": { "title": { "display": true, "text": "Sessions" } },
      "y": { "title": { "display": true, "text": "Revenue ($k)" } }
    }
  }
}
```

## Bubble

`r` is the bubble radius in pixels (Chart.js does not scale it automatically).

```json
{
  "type": "bubble",
  "data": {
    "datasets": [{
      "label": "Teams: size × velocity × happiness",
      "data": [
        {"x": 5,  "y": 22, "r": 12},
        {"x": 12, "y": 35, "r": 24},
        {"x": 8,  "y": 28, "r": 8},
        {"x": 20, "y": 41, "r": 30}
      ],
      "backgroundColor": "rgba(0,114,178,0.5)"
    }]
  },
  "options": {
    "scales": {
      "x": { "title": { "display": true, "text": "Team size" } },
      "y": { "title": { "display": true, "text": "Velocity (pts/sprint)" } }
    }
  }
}
```

## Tips

- Pre-scale radii so the biggest bubble is ~30px and smallest ~6px. Square-root scaling makes area proportional to value.
- Always label both axes — scatter without axis labels is unreadable.
- For >100 points, set `pointRadius: 2` and translucent fill so density is visible.
- A bubble chart with 3 well-chosen dimensions can beat three separate bar charts.
