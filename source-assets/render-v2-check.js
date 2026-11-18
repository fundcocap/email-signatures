const { chromium } = require('playwright-core');
const path = require('path');
const fs = require('fs');

const ROOT = path.resolve(__dirname, '..');
const TEMPLATES = path.join(ROOT, 'templates');
const EXPORT = path.join(ROOT, 'export');
const PREVIEWS = path.join(ROOT, 'previews');

const SAMPLE = {
  '%%DisplayName%%': 'Jane Doe',
  '%%Title%%': 'Marketing Manager',
  '%%Department%%': 'Communications',
  '%%PhoneNumber%%': '+234 1 555 0100',
};

const SLUGS = [
  'fundco-ng',
  'grosolar-ng',
  'onecapinvestment-ng',
  'agronomie-ng',
  'e-mobilite-ng',
  'electrifymicrogrid-ng',
];

function toFileUrl(p) {
  return 'file://' + p.split('\\').join('/');
}

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 650, height: 900 } });
  for (const slug of SLUGS) {
    let html = fs.readFileSync(path.join(TEMPLATES, `${slug}-footer.html`), 'utf8');
    for (const [tok, val] of Object.entries(SAMPLE)) html = html.split(tok).join(val);
    // point the live GitHub raw URL at the local export copy so the preview doesn't need network
    html = html.replace(
      /https:\/\/raw\.githubusercontent\.com\/FundCo-Capital-Managers-Limited\/email-signatures\/main\/export\//g,
      toFileUrl(EXPORT) + '/'
    );
    const wrapped = `<!doctype html><html><head><meta charset="utf-8"></head><body style="margin:0;padding:20px;background:#ffffff;">${html}</body></html>`;
    const localTmp = path.join(ROOT, `._tmp_preview_${slug}.html`);
    fs.writeFileSync(localTmp, wrapped, 'utf8');
    await page.goto(toFileUrl(localTmp));
    await page.waitForTimeout(200);
    const el = await page.evaluateHandle(() => document.body.firstElementChild);
    const box = await el.asElement().boundingBox();
    await page.screenshot({
      path: path.join(PREVIEWS, `${slug}-footer-preview.png`),
      clip: { x: 0, y: 0, width: Math.ceil(box.x + box.width) + 20, height: Math.ceil(box.y + box.height) + 20 },
    });
    console.log(slug, 'saved');
    fs.unlinkSync(localTmp);
  }
  await browser.close();
})().catch((e) => { console.error(e); process.exit(1); });
