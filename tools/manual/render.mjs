import pkg from '/tmp/shots/node_modules/playwright-core/index.js';
const { chromium } = pkg;
import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(__dirname, 'screenshots');
fs.mkdirSync(outDir, { recursive: true });

const exe = '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';
const browser = await chromium.launch({ executablePath: exe });
const page = await browser.newPage({ deviceScaleFactor: 2, viewport: { width: 1120, height: 1360 } });
await page.goto('file://' + path.join(__dirname, 'app.html'));
// wait for fonts (Roboto, Material Icons) to load
await page.evaluate(() => document.fonts.ready);
await page.waitForTimeout(600);

const ids = await page.evaluate(() => window.__SCREEN_IDS);
for (const id of ids) {
  const el = await page.$('#screen-' + id + ' > *');
  await el.screenshot({ path: path.join(outDir, id + '.png') });
  console.log('shot', id);
}
await browser.close();
console.log('DONE', ids.length, 'screens');
