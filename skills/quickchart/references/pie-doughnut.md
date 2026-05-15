# Pie & Doughnut

Use only for **parts of a whole** with **≤6 slices**. If you need more, switch to a stacked or horizontal bar.

## Doughnut

```json
{
  "type": "doughnut",
  "data": {
    "labels": ["Search", "Direct", "Social", "Referral", "Email"],
    "datasets": [{
      "data": [42, 23, 18, 11, 6],
      "backgroundColor": ["#0072B2", "#E69F00", "#009E73", "#CC79A7", "#56B4E9"]
    }]
  },
  "options": {
    "plugins": { "title": { "display": true, "text": "Search is 42% of traffic" } }
  }
}
```

## Pie

Identical but `"type": "pie"`. Doughnut is usually preferred because the centre can hold a label.

## Doughnut centre label (QuickChart extension)

```json
{
  "type": "doughnut",
  "data": { ... },
  "options": {
    "plugins": {
      "doughnutlabel": {
        "labels": [
          { "text": "$2.4M", "font": { "size": 28 } },
          { "text": "Total revenue" }
        ]
      }
    }
  }
}
```

## Tips

- Order slices largest → smallest, clockwise from 12 o'clock.
- Group the long tail into "Other" before plotting.
- Avoid 3D, exploded slices, and shadows — they distort proportions.
- If users need to compare two pies side-by-side, replace them with a stacked bar.
