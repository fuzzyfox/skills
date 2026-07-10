# Gauge Charts

Use for a **single KPI** against a known range (utilisation, target progress, NPS). Two flavours:

- `radialGauge` — full circle, single value with optional centre label.
- speedometer (`doughnut` with QuickChart's gauge plugin) — half-circle with coloured zones.

## Radial gauge

```json
{
  "type": "radialGauge",
  "data": { "datasets": [{ "data": [72], "backgroundColor": "#0072B2" }] },
  "options": {
    "domain": [0, 100],
    "trackColor": "#eaeaea",
    "centerPercentage": 70,
    "roundedCorners": true,
    "centerArea": {
      "displayText": true,
      "fontColor": "#0072B2",
      "fontSize": 32,
      "text": "72%"
    },
    "plugins": { "title": { "display": true, "text": "Uptime (last 30d)" } }
  }
}
```

## Speedometer (half-circle with zones)

```json
{
  "type": "doughnut",
  "data": {
    "datasets": [{
      "data": [60, 25, 15],
      "backgroundColor": ["#009E73", "#F0E442", "#D55E00"]
    }]
  },
  "options": {
    "rotation": -90,
    "circumference": 180,
    "cutout": "70%",
    "plugins": {
      "doughnutlabel": {
        "labels": [
          { "text": "78", "font": { "size": 36 } },
          { "text": "NPS" }
        ]
      },
      "legend": { "display": false }
    }
  }
}
```

## Tips

- Always include the unit in the centre label (`72%`, `$2.4M`, `NPS 78`).
- For radial gauges, set `domain` explicitly. Don't let the API guess.
- Speedometer zones should be at most green/yellow/red. More zones lose meaning.
- Only gauge a metric with a meaningful min/max. For an unbounded count like "12,400 sessions", use a number badge instead.
