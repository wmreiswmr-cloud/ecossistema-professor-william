const { chromium } = require('playwright');
const path = require('path');

const DIR = __dirname;

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1200, height: 1400 }, deviceScaleFactor: 1 });
  await page.goto('file:///' + path.join(DIR, '02-peca.html').replace(/\\/g, '/'), { waitUntil: 'networkidle' });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(1200);

  const el = await page.$('#D');
  const box = await el.boundingBox();
  await el.screenshot({ path: path.join(DIR, '02-peca.png') });
  console.log(`02-peca.png  ${Math.round(box.width)}x${Math.round(box.height)}`);
  await browser.close();
})();
