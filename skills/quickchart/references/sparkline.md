# Sparklines

Use as **inline mini trends** inside tables, sentences, or KPI tiles. No axes, no legend, no title — they live alongside text that provides context.

```json
{
  "type": "line",
  "data": {
    "labels": ["","","","","","","","","",""],
    "datasets": [{
      "data": [12, 14, 11, 15, 18, 17, 20, 22, 21, 25],
      "borderColor": "#0072B2",
      "borderWidth": 2,
      "fill": false,
      "pointRadius": 0,
      "tension": 0.3
    }]
  },
  "options": {
    "plugins": { "legend": { "display": false }, "title": { "display": false } },
    "scales": {
      "x": { "display": false },
      "y": { "display": false }
    },
    "elements": { "line": { "borderJoinStyle": "round" } }
  }
}
```

Render at **200×60** with `devicePixelRatio=2`:

```bash
node scripts/build-chart.js --config sparkline.json \
  --width 200 --height 60 --bg transparent --alt "sessions trend"
```

## Markdown table example

```markdown
| Team     | This week | Trend |
|----------|-----------|-------|
| Growth   | 412       | ![](https://quickchart.io/chart?w=120&h=30&c=...) |
| Platform | 287       | ![](https://quickchart.io/chart?w=120&h=30&c=...) |
```

## Tips

- Keep aspect ratio wide (3:1 or 4:1). Tall sparklines feel like proper charts.
- No markers. No grid. The line is the message.
- For win/loss style, use a tiny bar chart with positive/negative bars instead.
- Bake the value as text *next to* the sparkline, not inside it.
