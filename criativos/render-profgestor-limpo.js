const { chromium } = require('playwright');
const path = require('path');

const DIR = __dirname;

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1200, height: 1450 }, deviceScaleFactor: 1 });
  await page.goto('file:///' + path.join(DIR, 'profgestor-hero-limpo.html').replace(/\\/g, '/'), { waitUntil: 'networkidle' });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(1200);

  const el = await page.$('.peca');
  const box = await el.boundingBox();
  await el.screenshot({ path: path.join(DIR, 'profgestor-hero-limpo.png') });
  console.log(`profgestor-hero-limpo.png  ${Math.round(box.width)}x${Math.round(box.height)}`);

  await browser.close();
})();
