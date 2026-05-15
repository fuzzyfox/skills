# Sankey Diagrams

Use for **flows between stages** where width encodes magnitude (user funnels, budget allocation, energy flow). Two stages minimum; three or more is where sankey shines.

```json
{
  "type": "sankey",
  "data": {
    "datasets": [{
      "data": [
        { "from": "Landing", "to": "Signup",     "flow": 1000 },
        { "from": "Landing", "to": "Bounce",     "flow": 600 },
        { "from": "Signup",  "to": "Onboarded",  "flow": 700 },
        { "from": "Signup",  "to": "Dropped",    "flow": 300 },
        { "from": "Onboarded","to": "Activated", "flow": 500 },
        { "from": "Onboarded","to": "Churned",   "flow": 200 }
      ],
      "colorFrom": "#0072B2",
      "colorTo":   "#009E73",
      "colorMode": "gradient"
    }]
  },
  "options": {
    "plugins": { "title": { "display": true, "text": "Activation funnel: 50% of signups activate" } }
  }
}
```

## Tips

- Sankey requires `chart.js-chart-sankey` which QuickChart bundles — just use `"type": "sankey"`.
- Order nodes so flows read left → right with minimal crossings.
- Don't have more than ~12 unique nodes total. Above that, group small flows into "Other".
- Always include totals in the title or surrounding prose — sankey communicates ratios, not absolutes.
- SVG output may have visual artifacts for sankey; prefer PNG.
