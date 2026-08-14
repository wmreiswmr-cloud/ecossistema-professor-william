// BL-029 — poka-yoke do contador de ocorrencias (Politica de Escalonamento).
// Adiciona ao Code node existente de "Alerta de Prazo Vencido" a contagem
// consecutiva por item vencido (auditoria/contagem-vencimentos.json) e um
// bloco de escalonamento quando um item bate 3 ocorrencias seguidas.
const fs = require('fs');

const FILE = 'workflow-prazo-vencido.json';
const wf = JSON.parse(fs.readFileSync(FILE, 'utf8'));
const node = wf.nodes.find(n => n.id === 'code-check');
if (!node) throw new Error('node code-check nao encontrado');

node.parameters.jsCode = `const fs = require('fs');
const PROBLEMAS = 'C:\\\\Users\\\\usuario\\\\Desktop\\\\Projeto-professor-William\\\\auditoria\\\\problemas.md';
const ALERTAS = 'C:\\\\Users\\\\usuario\\\\Desktop\\\\Projeto-professor-William\\\\auditoria\\\\alertas-automaticos.md';
const CONTAGEM = 'C:\\\\Users\\\\usuario\\\\Desktop\\\\Projeto-professor-William\\\\auditoria\\\\contagem-vencimentos.json';

function parseData(prazoRaw) {
  const iso = prazoRaw.match(/(\\d{4})-(\\d{2})-(\\d{2})/);
  if (iso) return new Date(Date.UTC(+iso[1], +iso[2]-1, +iso[3]));
  const br = prazoRaw.match(/^\\**(\\d{2})\\/(\\d{2})\\**$/);
  if (br) return new Date(Date.UTC(2026, +br[2]-1, +br[1]));
  return null;
}

const content = fs.readFileSync(PROBLEMAS, 'utf8');
const lines = content.split(/\\r?\\n/);
const hoje = new Date(); hoje.setUTCHours(0,0,0,0);

// Mapa id -> linha mais recente: o arquivo e cronologico (secoes novas no
// final), entao a ultima ocorrencia de um # e sempre o estado mais atual.
// So aceita linhas de 7 celulas (forma da tabela principal) -- isso exclui
// naturalmente a tabela Resolvidos (4 col) e a Recorrente (6 col), que
// causavam falso-positivo por desalinhamento de coluna.
const porId = new Map();
for (const line of lines) {
  const t = line.trim();
  if (!t.startsWith('|')) continue;
  const cells = t.split('|').slice(1, -1).map(c => c.trim());
  if (cells.length !== 7) continue;
  const [id, problema, , dono, prazo, status] = cells;
  if (!/^\\d+$/.test(id)) continue;
  porId.set(id, { problema, dono, prazo, status });
}

const vencidos = [];
for (const [id, row] of porId) {
  const { problema, dono, prazo, status } = row;
  if (problema.includes('~~')) continue;
  const statusUp = status.toUpperCase();
  if (/DONE|CANCELLED|RESOLVID|CUMPRID|APROVAD/.test(statusUp) || status.trim().startsWith('\\u2705')) continue;
  const d = parseData(prazo);
  if (!d) continue;
  if (d.getTime() < hoje.getTime()) {
    vencidos.push({ id, problema: problema.replace(/\\*\\*/g, '').slice(0, 90), dono, prazo, status, diasVencido: Math.round((hoje - d) / 86400000) });
  }
}
vencidos.sort((a, b) => +a.id - +b.id);

// Poka-yoke -- contador de ocorrencias consecutivas (BL-029, Politica de
// Escalonamento, regra do dono 2026-08-04). Incrementa 1 por rodada diaria
// em que o item continua vencido; sai da lista de vencidos (resolvido ou
// prazo redesignado para o futuro) reseta a contagem -- cada ciclo de
// vencimento conta separado, nao acumula para sempre.
let contagem = {};
if (fs.existsSync(CONTAGEM)) {
  try { contagem = JSON.parse(fs.readFileSync(CONTAGEM, 'utf8')); } catch (e) { contagem = {}; }
}
const idsVencidosAgora = new Set(vencidos.map(v => v.id));
for (const id of Object.keys(contagem)) {
  if (!idsVencidosAgora.has(id)) delete contagem[id];
}
const escalados = [];
for (const v of vencidos) {
  contagem[v.id] = (contagem[v.id] || 0) + 1;
  if (contagem[v.id] >= 3) escalados.push({ ...v, ocorrencias: contagem[v.id] });
}
fs.writeFileSync(CONTAGEM, JSON.stringify(contagem, null, 2), 'utf8');

const agora = new Date();
const pad = n => String(n).padStart(2, '0');
const dataStr = \`\${agora.getUTCFullYear()}-\${pad(agora.getUTCMonth()+1)}-\${pad(agora.getUTCDate())}\`;
const horaStr = \`\${pad(agora.getUTCHours())}:\${pad(agora.getUTCMinutes())}\`;

let bloco = \`\\n## \${dataStr} \${horaStr} — n8n (automático, Alerta de Prazo Vencido)\\n\\n\`;
if (vencidos.length === 0) {
  bloco += 'Nenhum item vencido encontrado em problemas.md nesta checagem.\\n';
} else {
  bloco += \`\${vencidos.length} item(ns) vencido(s):\\n\\n\`;
  for (const v of vencidos) {
    bloco += \`- #\${v.id} (\${v.diasVencido}d vencido, \${contagem[v.id]}ª ocorrência consecutiva, dono \${v.dono}, prazo \${v.prazo}, status \${v.status}): \${v.problema}\\n\`;
  }
}

if (escalados.length > 0) {
  bloco += \`\\n🔴 ESCALONAMENTO (Política de Escalonamento, regra do dono 2026-08-04 — 3ª vez = lacuna sistêmica): \${escalados.length} item(ns) venceram 3+ rodadas seguidas sem resolver — precisa de A3 de causa raiz do cerebro-qualidade, não mais uma nova data:\\n\\n\`;
  for (const e of escalados) {
    bloco += \`- #\${e.id} (\${e.ocorrencias}ª vez, dono \${e.dono}): \${e.problema}\\n\`;
  }
}

if (!fs.existsSync(ALERTAS)) {
  fs.writeFileSync(ALERTAS, '# Alertas automáticos — n8n\\n\\nGerado pelo workflow "Alerta de Prazo Vencido". Lido pelo Diretor no início de toda sessão, junto com o resto de auditoria/.\\n' + bloco, 'utf8');
} else {
  fs.appendFileSync(ALERTAS, bloco, 'utf8');
}

return [{ json: { vencidos: vencidos.length, escalados: escalados.length, detalhe: vencidos } }];
`;

fs.writeFileSync(FILE, JSON.stringify(wf, null, 2), 'utf8');
console.log('atualizado', FILE);
