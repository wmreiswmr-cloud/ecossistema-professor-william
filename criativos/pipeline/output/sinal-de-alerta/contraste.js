function lum(hex, alphaOverBg) {
  let [r, g, b] = hex.match(/\w\w/g).map(h => parseInt(h, 16));
  if (alphaOverBg) { // hex is fg rgb, blended with alpha over bg
    const [a, bg] = alphaOverBg;
    const [br, bgc, bb] = bg.match(/\w\w/g).map(h => parseInt(h, 16));
    r = r * a + br * (1 - a);
    g = g * a + bgc * (1 - a);
    b = b * a + bb * (1 - a);
  }
  const chan = v => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); };
  return 0.2126 * chan(r) + 0.7152 * chan(g) + 0.0722 * chan(b);
}
function ratio(hex1, hex2, alpha1, alpha2) {
  const L1 = lum(hex1, alpha1) + 0.05;
  const L2 = lum(hex2, alpha2) + 0.05;
  return (Math.max(L1, L2) / Math.min(L1, L2)).toFixed(2);
}

const paper = '#f6efe0';
const navy = '#16233b';
const inkSoft = '#574d3f';
const goldText = '#8a6220';
const gold = '#b8842e';
const ink = '#201a14';
const white = '#ffffff';

const pairs = [
  ['navy sobre paper (headline)', ratio(navy, paper)],
  ['ink-soft sobre paper (corpo)', ratio(inkSoft, paper)],
  ['gold-text sobre paper (destaque headline/num)', ratio(goldText, paper)],
  ['white 90% sobre navy (diferencial)', ratio(white, navy, [0.9, navy])],
  ['white 62% sobre navy (prazo/cidade)', ratio(white, navy, [0.62, navy])],
  ['ink sobre gold (CTA)', ratio(ink, gold)],
  ['gold sobre navy (span diferencial "sempre individual")', ratio(gold, navy)],
];

for (const [label, r] of pairs) {
  const aa = r >= 4.5 ? 'AA' : 'REPROVA';
  const aaLarge = r >= 3 ? 'AA large' : 'REPROVA';
  console.log(`${label}: ${r}:1  (texto normal ${aa} / texto grande ${aaLarge})`);
}
