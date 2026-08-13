const { chromium } = require('playwright');
const path = require('path');

const DIR = __dirname;

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1200, height: 1400 }, deviceScaleFactor: 1 });
  await page.goto('file:///' + path.join(DIR, 'criativos.html').replace(/\\/g, '/'), { waitUntil: 'networkidle' });
  // Fonte do Google so conta como carregada depois disto — sem esperar, o
  // screenshot sai com a fonte de fallback e a metrica do texto muda.
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(1200);

  for (const id of ['A', 'B', 'C']) {
    const el = await page.$('#' + id);
    const box = await el.boundingBox();
    await el.screenshot({ path: path.join(DIR, `criativo-${id}.png`) });
    console.log(`criativo-${id}.png  ${Math.round(box.width)}x${Math.round(box.height)}`);
  }
  await browser.close();
})();
