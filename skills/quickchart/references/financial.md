# Financial Charts (OHLC & Candlestick)

Use for **price movement over time** with open/high/low/close per period. QuickChart bundles `chartjs-chart-financial`.

## Candlestick

```json
{
  "type": "candlestick",
  "data": {
    "datasets": [{
      "label": "ACME share price",
      "data": [
        { "x": "2026-05-09", "o": 142.10, "h": 145.80, "l": 141.50, "c": 144.20 },
        { "x": "2026-05-10", "o": 144.30, "h": 147.10, "l": 143.90, "c": 146.70 },
        { "x": "2026-05-11", "o": 146.60, "h": 148.20, "l": 144.10, "c": 144.80 },
        { "x": "2026-05-12", "o": 144.90, "h": 150.30, "l": 144.50, "c": 149.90 },
        { "x": "2026-05-13", "o": 150.00, "h": 152.40, "l": 148.70, "c": 151.20 }
      ]
    }]
  },
  "options": {
    "plugins": { "title": { "display": true, "text": "ACME this week: +6.4%" } },
    "scales": {
      "x": { "type": "time", "time": { "unit": "day" } }
    }
  }
}
```

## OHLC bars

Same data, `"type": "ohlc"`.

## Tips

- Always render with a time scale on x — categorical x looks fine until trading days are missing.
- Keep to one ticker per chart. Compare returns (% from base) on a line chart instead.
- For a price + volume view, see [mixed.md](mixed.md).
- Time-series data is usually large — the helper script will auto-switch to short URLs.
