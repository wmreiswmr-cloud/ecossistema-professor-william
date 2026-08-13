/**
 * Extrator de DNA visual de site de referência.
 *
 * Visita uma página real, mede o que de fato está renderizado (cor, espaçamento,
 * tipografia, raio, sombra) e gera um PROMPT de especificação no formato que o
 * vídeo de referência mostrou funcionar: concreto, com valores nomeados.
 *
 * Uso:
 *   node extrair-referencia.js <url> [--nome "Nome do Projeto"]
 *
 * Requer playwright global (NODE_PATH deve apontar pro global do npm).
 *
 * NÃO copia conteúdo, texto, imagem nem código do site — extrai só medidas
 * numéricas de estilo, que são fatos, não obra. Ver regra de ouro em
 * ~/.claude/knowledge/ (nunca copiar identidade alheia).
 */
const { chromium } = require('playwright');

const url = process.argv[2];
const nomeIdx = process.argv.indexOf('--nome');
const nome = nomeIdx > -1 ? process.argv[nomeIdx + 1] : 'Projeto';

if (!url) {
  console.error('uso: node extrair-referencia.js <url> [--nome "Projeto"]');
  process.exit(1);
}

const freq = (arr) => {
  const m = new Map();
  for (const v of arr) m.set(v, (m.get(v) || 0) + 1);
  return [...m.entries()].sort((a, b) => b[1] - a[1]);
};

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto(url, { waitUntil: 'networkidle', timeout: 45000 });

  // Rola de verdade: seções com reveal por IntersectionObserver só existem
  // no DOM medível depois que entraram na viewport.
  const alturaTotal = await page.evaluate(() => document.body.scrollHeight);
  for (let y = 0; y < alturaTotal; y += 400) {
    await page.evaluate((v) => window.scrollTo(0, v), y);
    await page.waitForTimeout(120);
  }
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.waitForTimeout(400);

  const dados = await page.evaluate(() => {
    const els = [...document.querySelectorAll('body *')].filter((el) => {
      const r = el.getBoundingClientRect();
      return r.width > 0 && r.height > 0;
    });

    const cores = [], fundos = [], fontes = [], tamanhos = [], pesos = [],
          alturas = [], raios = [], sombras = [], espacos = [];

    for (const el of els.slice(0, 3000)) {
      const s = getComputedStyle(el);
      const temTexto = el.textContent && el.textContent.trim().length > 0;

      if (temTexto) {
        cores.push(s.color);
        fontes.push(s.fontFamily.split(',')[0].replace(/["']/g, '').trim());
        tamanhos.push(parseFloat(s.fontSize));
        pesos.push(s.fontWeight);
        if (s.lineHeight !== 'normal') alturas.push(parseFloat(s.lineHeight));
      }
      const bg = s.backgroundColor;
      if (bg && bg !== 'rgba(0, 0, 0, 0)' && bg !== 'transparent') fundos.push(bg);

      const r = parseFloat(s.borderRadius);
      if (r > 0) raios.push(r);
      if (s.boxShadow && s.boxShadow !== 'none') sombras.push(s.boxShadow);

      for (const p of ['paddingTop', 'paddingBottom', 'marginTop', 'marginBottom', 'gap']) {
        const v = parseFloat(s[p]);
        if (v > 0) espacos.push(Math.round(v));
      }
    }
    return { cores, fundos, fontes, tamanhos, pesos, alturas, raios, sombras, espacos,
             titulo: document.title };
  });

  const topo = (arr, n = 6) => freq(arr).slice(0, n);
  // Preserva o alpha: rgba(255,255,255,.06) e rgba(255,255,255,1) são cores
  // diferentes no design e não podem colapsar no mesmo #FFFFFF.
  const rgbParaHex = (rgb) => {
    const m = rgb.match(/[\d.]+/g);
    if (!m || m.length < 3) return rgb;
    const hex = '#' + m.slice(0, 3).map((x) => Math.round(+x).toString(16).padStart(2, '0')).join('').toUpperCase();
    const a = m[3] !== undefined ? parseFloat(m[3]) : 1;
    return a < 1 ? `${hex} @ ${Math.round(a * 100)}%` : hex;
  };

  const paleta = topo(dados.fundos, 8).map(([c, n]) => `${rgbParaHex(c)} (${n}x)`);
  const tinta = topo(dados.cores, 5).map(([c, n]) => `${rgbParaHex(c)} (${n}x)`);
  const famílias = topo(dados.fontes, 4).map(([f, n]) => `${f} (${n}x)`);
  const escalaTexto = [...new Set(dados.tamanhos)].sort((a, b) => a - b);
  const escalaEspaco = topo(dados.espacos, 10).map(([v]) => v).sort((a, b) => a - b);
  const raiosTopo = topo(dados.raios, 4).map(([v, n]) => `${v}px (${n}x)`);

  const relatorio = `
# DNA visual extraído — ${dados.titulo}
Fonte: ${url}
Extraído em: ${new Date().toISOString().slice(0, 10)}

## Cores de fundo (mais usadas)
${paleta.map((c) => '- ' + c).join('\n')}

## Cores de texto
${tinta.map((c) => '- ' + c).join('\n')}

## Tipografia
- Famílias: ${famílias.join(' · ')}
- Escala de tamanho (px): ${escalaTexto.join(', ')}
- Pesos usados: ${[...new Set(dados.pesos)].sort().join(', ')}
- Entrelinhas (px): ${[...new Set(dados.alturas.map((a) => Math.round(a)))].sort((a, b) => a - b).slice(0, 8).join(', ')}

## Espaçamento
- Escala real observada (px): ${escalaEspaco.join(', ')}
- Base provável: ${escalaEspaco.length ? escalaEspaco.filter((v) => v % 8 === 0).length > escalaEspaco.length / 2 ? '8px' : '4px' : 'indefinida'}

## Forma
- Raios: ${raiosTopo.join(' · ') || 'nenhum'}
- Sombras distintas: ${new Set(dados.sombras).size}

---

# PROMPT GERADO (formato de especificação)

Construa um site para **${nome}**, com acabamento de agência (nível Awwwards).

## BRANDING
- Fundo principal: ${paleta[0] ? paleta[0].split(' ')[0] : '—'}
- Fundos secundários: ${paleta.slice(1, 4).map((c) => c.split(' ')[0]).join(', ')}
- Texto principal: ${tinta[0] ? tinta[0].split(' ')[0] : '—'}
- Hierarquia de texto: ${tinta.slice(1, 3).map((c) => c.split(' ')[0]).join(', ')}

## TIPOGRAFIA
- Display/títulos: ${famílias[0] ? famílias[0].split(' (')[0] : '—'}
- Corpo: ${famílias[1] ? famílias[1].split(' (')[0] : famílias[0] ? famílias[0].split(' (')[0] : '—'}
- Escala: ${escalaTexto.filter((t) => t >= 12).join(' / ')} px
- Pesos: ${[...new Set(dados.pesos)].sort().join(', ')}

## ESPAÇAMENTO
- Escala em base ${escalaEspaco.filter((v) => v % 8 === 0).length > escalaEspaco.length / 2 ? '8' : '4'}px: ${escalaEspaco.join(' / ')} px
- Respeitar essa escala em TODO padding, margin e gap — nada fora dela.

## FORMA
- Border-radius: ${raiosTopo[0] ? raiosTopo[0].split(' ')[0] : '0'}
- Sombra: usar no máximo ${Math.min(new Set(dados.sombras).size, 3)} níveis distintos.

## O QUE PRECISA SER PREENCHIDO ANTES DE USAR ESTE PROMPT
1. CORE CONCEPT — a ideia única da página, descrita concretamente (o que acontece conforme o usuário rola)
2. PÚBLICO — quem lê, decide e paga
3. TECH STACK — bibliotecas nomeadas (ex: GSAP+ScrollTrigger, Lenis, Framer Motion)
4. O QUE NÃO FAZER — limites de tom e estilo

> Sem os 4 itens acima, este prompt gera algo bonito e genérico — que é exatamente o erro
> que o processo existe pra evitar. Medida sem direção não é briefing.
`;

  console.log(relatorio);
  await browser.close();
})();
