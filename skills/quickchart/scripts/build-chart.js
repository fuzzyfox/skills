#!/usr/bin/env node
/**
 * build-chart.js — turn a Chart.js config into a markdown image snippet
 * via the QuickChart API.
 *
 *   node build-chart.js --type bar --title "Sales" \
 *     --labels "Q1,Q2,Q3,Q4" --data "12,19,8,15" [--alt "..."] [--short]
 *
 *   cat config.json | node build-chart.js --stdin [--alt "..."] [--short]
 *
 * Flags:
 *   --type <t>        Chart type for the simple builder (bar, line, pie, ...)
 *   --title <s>       Chart title for the simple builder
 *   --labels a,b,c    X-axis labels for the simple builder
 *   --data n,n,n      Single-series data for the simple builder
 *   --stdin           Read a full Chart.js config (JSON) from stdin
 *   --config <path>   Read a full Chart.js config (JSON) from a file
 *   --alt <s>         Alt text for the markdown image (default: title or type)
 *   --width <n>       Image width (default 500)
 *   --height <n>      Image height (default 300)
 *   --bg <color>      Background colour (default transparent)
 *   --format <fmt>    png|svg|webp|jpg|pdf (default png)
 *   --short           Force POST /chart/create → short URL
 *   --inline          Force inline GET URL (base64-encoded)
 *   --download <path> Render via POST /chart, save bytes to <path>, embed local path
 *   --rel-to <dir>    Make the markdown image path relative to <dir> (for --download)
 *   --url-only        Print just the URL (or file path), no markdown
 *   --version <v>     Chart.js version (default 2)
 *
 * Auto-transport (when not using --download):
 *   - If the JSON-encoded config is < 1500 chars → inline GET, URL-encoded.
 *   - 1500–6000 chars → inline GET, base64-encoded.
 *   - > 6000 chars → POST /chart/create (short URL).
 *   Override with --short or --inline.
 *
 * --download bypasses the auto-transport and POSTs directly to /chart for a
 * one-shot render. Use it for long-lived documents (committed reports, books,
 * PDFs) where short URL expiration is a risk. QuickChart's free-tier output
 * is public domain; paid tier retains your copyright.
 */

const HOST = 'https://quickchart.io';
const SHORT_THRESHOLD = 6000;
const B64_THRESHOLD = 1500;

function parseArgs(argv) {
  const args = { width: 500, height: 300, bg: 'transparent', format: 'png', version: '2' };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    const next = () => argv[++i];
    switch (a) {
      case '--type': args.type = next(); break;
      case '--title': args.title = next(); break;
      case '--labels': args.labels = next().split(',').map(s => s.trim()); break;
      case '--data': args.data = next().split(',').map(Number); break;
      case '--stdin': args.stdin = true; break;
      case '--config': args.configPath = next(); break;
      case '--alt': args.alt = next(); break;
      case '--width': args.width = Number(next()); break;
      case '--height': args.height = Number(next()); break;
      case '--bg': args.bg = next(); break;
      case '--format': args.format = next(); break;
      case '--short': args.short = true; break;
      case '--inline': args.inline = true; break;
      case '--download': args.download = next(); break;
      case '--rel-to': args.relTo = next(); break;
      case '--url-only': args.urlOnly = true; break;
      case '--version': args.version = next(); break;
      case '-h':
      case '--help': args.help = true; break;
      default:
        process.stderr.write(`Unknown flag: ${a}\n`);
        process.exit(2);
    }
  }
  return args;
}

function readStdin() {
  return new Promise((resolve, reject) => {
    let buf = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', c => (buf += c));
    process.stdin.on('end', () => resolve(buf));
    process.stdin.on('error', reject);
  });
}

function simpleChart({ type, title, labels, data }) {
  if (!type) throw new Error('Missing --type (or pass a full config via --stdin/--config).');
  if (!labels || !data) throw new Error('Simple builder needs --labels and --data.');
  const cfg = {
    type,
    data: {
      labels,
      datasets: [{ label: title || type, data }],
    },
    options: {
      plugins: title ? { title: { display: true, text: title } } : {},
    },
  };
  return cfg;
}

async function renderToBuffer(payload) {
  const res = await fetch(`${HOST}/chart`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    throw new Error(`POST /chart failed: ${res.status} ${await res.text()}`);
  }
  return Buffer.from(await res.arrayBuffer());
}

async function createShortUrl(payload) {
  const res = await fetch(`${HOST}/chart/create`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    throw new Error(`POST /chart/create failed: ${res.status} ${await res.text()}`);
  }
  const body = await res.json();
  if (!body.success || !body.url) {
    throw new Error(`POST /chart/create unexpected response: ${JSON.stringify(body)}`);
  }
  return body.url;
}

function inlineUrl(payload, { base64 }) {
  const params = new URLSearchParams();
  if (payload.width) params.set('w', String(payload.width));
  if (payload.height) params.set('h', String(payload.height));
  if (payload.backgroundColor) params.set('bkg', payload.backgroundColor);
  if (payload.format && payload.format !== 'png') params.set('f', payload.format);
  if (payload.version && payload.version !== '2') params.set('v', payload.version);
  const chartJson = JSON.stringify(payload.chart);
  if (base64) {
    params.set('encoding', 'base64');
    params.set('c', Buffer.from(chartJson, 'utf8').toString('base64'));
  } else {
    params.set('c', chartJson);
  }
  return `${HOST}/chart?${params.toString()}`;
}

async function main() {
  const args = parseArgs(process.argv);
  if (args.help) {
    process.stdout.write(require('fs').readFileSync(__filename, 'utf8').split('\n').slice(1, 32).join('\n') + '\n');
    return;
  }

  let chartConfig;
  if (args.stdin) {
    chartConfig = JSON.parse(await readStdin());
  } else if (args.configPath) {
    chartConfig = JSON.parse(require('fs').readFileSync(args.configPath, 'utf8'));
  } else {
    chartConfig = simpleChart(args);
  }

  const payload = {
    chart: chartConfig,
    width: args.width,
    height: args.height,
    backgroundColor: args.bg,
    format: args.format,
    version: args.version,
  };

  const alt = args.alt || args.title || chartConfig.options?.plugins?.title?.text || chartConfig.type || 'chart';

  if (args.download) {
    const fs = require('fs');
    const path = require('path');
    const buf = await renderToBuffer(payload);
    const outPath = path.resolve(args.download);
    fs.mkdirSync(path.dirname(outPath), { recursive: true });
    fs.writeFileSync(outPath, buf);
    const embedPath = args.relTo
      ? path.relative(path.resolve(args.relTo), outPath)
      : args.download;
    if (args.urlOnly) {
      process.stdout.write(outPath + '\n');
    } else {
      process.stdout.write(`![${alt}](${embedPath})\n`);
    }
    return;
  }

  const sizeChars = JSON.stringify(chartConfig).length;
  let url;
  if (args.short || (!args.inline && sizeChars > SHORT_THRESHOLD)) {
    url = await createShortUrl(payload);
  } else if (sizeChars > B64_THRESHOLD) {
    url = inlineUrl(payload, { base64: true });
  } else {
    url = inlineUrl(payload, { base64: false });
  }

  if (args.urlOnly) {
    process.stdout.write(url + '\n');
  } else {
    process.stdout.write(`![${alt}](${url})\n`);
  }
}

main().catch(err => {
  process.stderr.write(`build-chart: ${err.message}\n`);
  process.exit(1);
});
