import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import * as http from 'http';

// Raiz do projeto onde vivem auditoria/ e as trilhas — fixo porque este
// painel é só pra este ecossistema, não é uma extensão genérica.
const RAIZ = 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William';
const AUD = path.join(RAIZ, 'auditoria');
const PROBLEMAS = path.join(AUD, 'problemas.md');
const DECISOES = path.join(AUD, 'decisoes.md');
const RECADOS = path.join(AUD, 'recados-dono.md');
const FONTS_FRAGMENT = path.join(AUD, 'artefatos', '_fonts-fragment.txt');
const GESTAO = path.join('C:\\Users\\usuario\\.claude\\knowledge', 'gestao.md');
const BACKLOG = path.join(AUD, 'evolution-backlog.md');
const RISCOS = path.join(AUD, 'riscos.md');
const PROJETOS = path.join(AUD, 'projetos.md');
const OPORTUNIDADES = path.join(AUD, 'opportunity-pipeline.md');
const USO_TOKENS = path.join(AUD, 'uso-tokens-real.json');
const HIGIENE_SESSAO = path.join(AUD, 'higiene-sessao-status.json');

function readFileSafe(p: string): string {
  try { return fs.readFileSync(p, 'utf8'); } catch { return ''; }
}

// Parser genérico de tabela markdown: recebe as linhas do arquivo e o índice
// da linha de cabeçalho (| Col1 | Col2 | ...|), devolve um array de linhas,
// cada uma já um array de células (string[]), parando na primeira linha que
// não é mais tabela.
function parseTableAt(lines: string[], headerIdx: number): string[][] {
  const rows: string[][] = [];
  for (let i = headerIdx + 2; i < lines.length; i++) {
    const line = lines[i];
    if (!line || !line.trim().startsWith('|')) break;
    const cells = line.split('|').slice(1, -1).map(c => c.trim());
    rows.push(cells);
  }
  return rows;
}

function findLastHeaderIdx(lines: string[], headerStart: string, beforeIdx?: number): number {
  let found = -1;
  const limit = beforeIdx ?? lines.length;
  for (let i = 0; i < limit; i++) {
    if (lines[i].trim().startsWith(headerStart)) found = i;
  }
  return found;
}

function findLineIdx(lines: string[], needle: string): number {
  return lines.findIndex(l => l.includes(needle));
}

interface Problema {
  id: string; problema: string; origem: string; dono: string; prazo: string;
  status: string; idade: string; prova: string;
}
interface Resolvido { problema: string; origem: string; resolvidoEm: string; prova: string; }
interface EscadaLinha { categoria: string; nivel: string; responsavel: string; falta: string; }
interface Recado { data: string; hora: string; texto: string; }

// problemas.md acumula uma tabela "| # | Problema | ... |" por data de reunião,
// nunca uma única tabela canônica — um mesmo # pode ganhar linha nova em toda
// reunião seguinte, e linhas editadas depois nem sempre mantêm a largura
// original do cabeçalho (ex.: tabela de 04/08 declara coluna Idade, mas linhas
// editadas depois, tipo #14/#19/#20, têm só 7 células reais, sem Idade). Pra
// pegar TODO item ainda aberto, agrega TODAS as tabelas de problema do arquivo
// e decide o formato LINHA A LINHA pela contagem real de células, nunca pelo
// cabeçalho. A tabela "03/08 tabela de ontem" (sem coluna Status) e a
// "Recorrente" (tarefa de manutenção, não problema) são formatos diferentes de
// propósito — excluídas exigindo cabeçalho com "Status" e "Problema".
// Status é a fonte de verdade de "resolvido", não o texto riscado do título —
// alguns itens têm ~~trecho~~ riscado dentro de uma descrição que segue
// genuinamente aberta (ex. #19: "~~causa X~~ — mas falta confirmar Y").
function isResolvido(status: string): boolean {
  return /✅|`?DONE`?|CANCELLED/.test(status);
}

function parseProblemas(): { abertos: Problema[]; resolvidos: Resolvido[] } {
  const content = readFileSafe(PROBLEMAS);
  const lines = content.split(/\r?\n/);

  const resolvidosSectionIdx = findLineIdx(lines, '## Resolvidos');
  const limite = resolvidosSectionIdx > 0 ? resolvidosSectionIdx : lines.length;

  const porId = new Map<string, Problema>();
  for (let i = 0; i < limite; i++) {
    const line = lines[i].trim();
    if (!line.startsWith('| # |') || !line.includes('Status') || !line.includes('Problema')) continue;
    for (const c of parseTableAt(lines, i)) {
      if (c.length < 7) continue;
      const p: Problema = c.length >= 8
        ? { id: c[0], problema: c[1], origem: c[2], dono: c[3], prazo: c[4], status: c[5], idade: c[6], prova: c[7] }
        : { id: c[0], problema: c[1], origem: c[2], dono: c[3], prazo: c[4], status: c[5], idade: '', prova: c[6] };
      if (!p.id) continue;
      porId.set(p.id.replace(/[~\s]/g, ''), p); // última ocorrência do mesmo # vence
    }
  }
  const abertos: Problema[] = [...porId.values()].filter(p => !isResolvido(p.status));

  let resolvidos: Resolvido[] = [];
  if (resolvidosSectionIdx >= 0) {
    const rHeaderIdx = findLastHeaderIdx(lines, '| Problema |', undefined);
    if (rHeaderIdx > resolvidosSectionIdx) {
      resolvidos = parseTableAt(lines, rHeaderIdx)
        .filter(c => c.length >= 4)
        .map(c => ({ problema: c[0], origem: c[1], resolvidoEm: c[2], prova: c[3] }));
    }
  }
  return { abertos, resolvidos };
}

function parseEscada(): EscadaLinha[] {
  const content = readFileSafe(DECISOES);
  const lines = content.split(/\r?\n/);
  const headerIdx = findLastHeaderIdx(lines, '| Categoria | Nível |');
  if (headerIdx < 0) return [];
  return parseTableAt(lines, headerIdx)
    .filter(c => c.length >= 5)
    .map(c => ({ categoria: c[0], nivel: c[1], responsavel: c[4], falta: c[3] }));
}

interface Mestre { num: string; nome: string; framework: string; quando: string; }
interface DiretorDev { nivel: number; totalCurriculo: number; registrados: Mestre[]; proximo: string; }

function normaliza(s: string): string {
  return s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();
}

function parseDiretorDev(): DiretorDev {
  const content = readFileSafe(GESTAO);
  if (!content) return { nivel: 0, totalCurriculo: 14, registrados: [], proximo: '' };
  const lines = content.split(/\r?\n/);

  // Nivel: "> **Nível de gestão do Diretor: 8 mestres registrados de 14**"
  let nivel = 0;
  const nivelLine = lines.find(l => /Nível de gestão do Diretor:\s*\d/.test(l));
  if (nivelLine) {
    const m = nivelLine.match(/Nível de gestão do Diretor:\s*(\d+)\s*mestres registrados de\s*(\d+)/);
    if (m) nivel = parseInt(m[1], 10);
  }

  // Curriculo: tabela "| # | Mestre | Framework central | Por que nesta posição |"
  const curHeaderIdx = findLastHeaderIdx(lines, '| # | Mestre |');
  const curriculo = curHeaderIdx >= 0
    ? parseTableAt(lines, curHeaderIdx).filter(c => c.length >= 2).map(c => ({ num: c[0].trim(), nome: c[1].replace(/\*\*/g, '').trim() }))
    : [];
  const totalCurriculo = curriculo.length || 14;

  // Registros: cabecalhos "## <Tema> — <Framework> (<Autor>, <data>)"
  const registrados: Mestre[] = [];
  for (const line of lines) {
    const m = line.match(/^##\s+(.+?)\s+—\s+(.+?)\s+\(([^,]+),\s*([\d-]+)\)\s*$/);
    if (!m) continue;
    const [, , framework, autor, data] = m;
    const cur = curriculo.find(c => normaliza(c.nome).includes(normaliza(autor).split(' ').pop() || ''));
    registrados.push({ num: cur ? '#' + cur.num : '#?', nome: autor.trim(), framework: framework.trim(), quando: data.trim().slice(5) });
  }

  const cobertos = new Set(registrados.map(r => normaliza(r.nome)));
  const proximoEntry = curriculo.find(c => ![...cobertos].some(nome => normaliza(c.nome).includes(nome.split(' ').pop() || '###')));
  const proximo = proximoEntry ? `#${proximoEntry.num} ${proximoEntry.nome}` : '';

  return { nivel, totalCurriculo, registrados, proximo };
}

interface BacklogItem {
  id: string; titulo: string; categoria: string; prioridade: string; status: string;
  responsavel: string; prazo: string; evidencia: string;
}

// Backlog de evolução do Innovator Director — auditoria/evolution-backlog.md.
// Reaproveita o mesmo parser genérico de tabela já usado pra problemas/decisões:
// este arquivo NUNCA vira "decoração" (regra do dono, 2026-08-09) — todo campo
// vem direto do arquivo real, nada calculado à mão e colado aqui.
function parseBacklog(): BacklogItem[] {
  const content = readFileSafe(BACKLOG);
  const lines = content.split(/\r?\n/);
  const headerIdx = findLastHeaderIdx(lines, '| ID |');
  if (headerIdx < 0) return [];
  return parseTableAt(lines, headerIdx)
    .filter(c => c.length >= 8)
    .map(c => ({ id: c[0], titulo: c[1], categoria: c[2], prioridade: c[3], status: c[4], responsavel: c[5], prazo: c[6], evidencia: c[7] }));
}

const STATUS_FINAL = new Set(['DONE', 'CANCELLED']);
const STATUS_ATIVO = new Set(['READY', 'ASSIGNED', 'IN_PROGRESS']);

// Contagem simples e robusta em vez de parser de tabela formal: riscos.md e
// decisoes.md têm linhas em branco irregulares entre algumas linhas de tabela
// (histórico de edições manuais), o que quebraria parseTableAt no meio do
// arquivo. Contar o marcador literal é menos elegante, mas não finge precisão
// que um parser frágil não teria de verdade.
function countRiscosAbertos(): number {
  const content = readFileSafe(RISCOS);
  return (content.match(/⏳/g) || []).length;
}

interface Projeto { id: string; nome: string; prioridade: string; fase: string; proximoCheckpoint: string; }

// auditoria/projetos.md — cada projeto é um "## PROJ-NNN — Nome" seguido de
// uma tabela "| Campo | Valor |" (chave/valor, não colunas fixas). Lê a
// tabela de cada bloco em vez de parseTableAt genérico porque o formato
// aqui é diferente (linhas nomeadas, não colunas por posição).
function parseProjetos(): Projeto[] {
  const content = readFileSafe(PROJETOS);
  const lines = content.split(/\r?\n/);
  const projetos: Projeto[] = [];
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].trim().match(/^##\s+(PROJ-\d+)\s+—\s+(.+)$/);
    if (!m) continue;
    let tableIdx = -1;
    for (let j = i + 1; j < lines.length; j++) {
      if (lines[j].trim().startsWith('## PROJ-')) break;
      if (lines[j].trim().startsWith('| Campo | Valor |')) { tableIdx = j; break; }
    }
    if (tableIdx < 0) continue;
    const campos = new Map<string, string>();
    for (const c of parseTableAt(lines, tableIdx)) {
      if (c.length < 2) continue;
      campos.set(c[0].replace(/\*\*/g, '').trim(), c[1].replace(/\*\*/g, '').trim());
    }
    projetos.push({
      id: m[1],
      nome: m[2].trim(),
      prioridade: campos.get('Prioridade') || '',
      fase: campos.get('Status/Fase') || '',
      proximoCheckpoint: campos.get('Próximo checkpoint') || '',
    });
  }
  return projetos;
}

interface OportunidadeLinha {
  id: string; problema: string; mercado: string; publico: string; tamanho: string; tendencia: string;
  concorrencia: string; potencial: string; risco: string; custoMvp: string; score: string; status: string;
}

// auditoria/opportunity-pipeline.md — dono cerebro-empreendedor. Hoje tem só
// a linha placeholder (ID "—", ainda não rodou 1ª execução) — filtrada fora
// de propósito, 0 é o valor honesto, não bug do parser.
function parseOportunidades(): { total: number; linhas: OportunidadeLinha[] } {
  const content = readFileSafe(OPORTUNIDADES);
  const lines = content.split(/\r?\n/);
  const headerIdx = findLastHeaderIdx(lines, '| ID | Problema |');
  if (headerIdx < 0) return { total: 0, linhas: [] };
  const linhas = parseTableAt(lines, headerIdx)
    .filter(c => c.length >= 12 && c[0].trim() !== '—')
    .map(c => ({
      id: c[0], problema: c[1], mercado: c[2], publico: c[3], tamanho: c[4], tendencia: c[5],
      concorrencia: c[6], potencial: c[7], risco: c[8], custoMvp: c[9], score: c[10], status: c[11],
    }));
  return { total: linhas.length, linhas };
}

interface Atrasado { id: string; problema: string; dono: string; prazo: string; diasVencido: number; }

function parseDataPrazo(prazoRaw: string): Date | null {
  const iso = prazoRaw.match(/(\d{4})-(\d{2})-(\d{2})/);
  if (iso) return new Date(Date.UTC(+iso[1], +iso[2] - 1, +iso[3]));
  const br = prazoRaw.match(/^\**(\d{2})\/(\d{2})\**$/);
  if (br) return new Date(Date.UTC(2026, +br[2] - 1, +br[1]));
  return null;
}

// Mesma lógica do node "Checar prazos vencidos" de
// automacao-n8n/workflow-prazo-vencido.json — replicada aqui e calculada ao
// vivo contra `abertos` (já deduplicado por parseProblemas()), nunca lendo
// auditoria/alertas-automaticos.md: esse arquivo só rodou 1x (09/08), com
// 1 falso positivo, e não roda mais — mostraria dado de dias atrás como se
// fosse agora. Item sem data parseável nunca conta como vencido (não é
// "vencido por omissão").
function countAtrasados(abertos: Problema[]): Atrasado[] {
  const hoje = new Date(); hoje.setUTCHours(0, 0, 0, 0);
  const vencidos: Atrasado[] = [];
  for (const p of abertos) {
    if (p.problema.includes('~~')) continue;
    const statusUp = p.status.toUpperCase();
    if (/DONE|CANCELLED|RESOLVID|CUMPRID|APROVAD/.test(statusUp) || p.status.trim().startsWith('✅')) continue;
    const d = parseDataPrazo(p.prazo);
    if (!d) continue;
    if (d.getTime() < hoje.getTime()) {
      vencidos.push({ id: p.id, problema: p.problema.replace(/\*\*/g, ''), dono: p.dono, prazo: p.prazo, diasVencido: Math.round((hoje.getTime() - d.getTime()) / 86400000) });
    }
  }
  return vencidos;
}
interface UsoTokenDia { dia: string; input: number; output: number; cacheCreate: number; cacheRead: number; turnos: number; }
function parseUsoTokens(): { dias: UsoTokenDia[]; medidoEm: string } {
  const content = readFileSafe(USO_TOKENS);
  if (!content) return { dias: [], medidoEm: '' };
  try {
    const dados = JSON.parse(content);
    const dias: UsoTokenDia[] = Object.keys(dados.porDia || {}).sort().map(dia => ({ dia, ...dados.porDia[dia] }));
    return { dias, medidoEm: dados.geradoEm || '' };
  } catch { return { dias: [], medidoEm: '' }; }
}

interface HigieneSessao { diasAtivos: number; recomendacao: string; handoffAtualizadoEm: string | null; handoffPath: string; }

// auditoria/higiene-sessao-status.json — escrito pelo workflow n8n de Economia
// de Token a cada execução (estado atual, não log). Mesmo padrão de leitura de
// parseUsoTokens(): nunca quebra o painel se o arquivo ainda não existe ou o
// n8n ainda não rodou uma vez.
function parseHigieneSessao(): HigieneSessao | null {
  const content = readFileSafe(HIGIENE_SESSAO);
  if (!content) return null;
  try { return JSON.parse(content); } catch { return null; }
}

function countDecisoesPendentes(): number {
  const content = readFileSafe(DECISOES);
  return (content.match(/\*\(pendente/g) || []).length;
}

// Checagem ao vivo, não leitura de arquivo — o n8n já morreu em silêncio 2x
// no mesmo dia (BL-037): um arquivo de status desatualizado mentiria "ok"
// depois do processo cair. GET real em localhost, timeout curto pra nunca
// travar o painel se o servidor estiver fora do ar.
function checkN8nSaude(): Promise<boolean> {
  return new Promise((resolve) => {
    const req = http.get({ host: 'localhost', port: 5679, path: '/healthz', timeout: 2000 }, (res) => {
      res.resume();
      resolve(res.statusCode === 200);
    });
    req.on('error', () => resolve(false));
    req.on('timeout', () => { req.destroy(); resolve(false); });
  });
}

interface AgenteReal { nome: string; }
// Descoberta ao vivo do diretório, não um array hardcoded — um agente novo
// (ex.: cerebro-empreendedor, criado 12/08) aparece aqui sozinho na próxima
// vez que o painel abrir, sem precisar de ninguém sincronizar uma lista.
function listarAgentesReais(): AgenteReal[] {
  const dir = path.join('C:\\Users\\usuario\\.claude', 'agents');
  try {
    return fs.readdirSync(dir)
      .filter(f => f.endsWith('.md'))
      .map(f => ({ nome: f.replace(/\.md$/, '') }))
      .sort((a, b) => a.nome.localeCompare(b.nome));
  } catch { return []; }
}

interface OndeEncontrarLinha { categoria: string; ondeVoceOlha: string; }
const SOURCE_OF_TRUTH = path.join(AUD, 'source-of-truth.md');
function parseOndeEncontrar(): OndeEncontrarLinha[] {
  const content = readFileSafe(SOURCE_OF_TRUTH);
  const lines = content.split(/\r?\n/);
  const headerIdx = findLastHeaderIdx(lines, '| Categoria | Fonte oficial');
  if (headerIdx < 0) return [];
  return parseTableAt(lines, headerIdx)
    .filter(c => c.length >= 3)
    .map(c => ({ categoria: c[0], ondeVoceOlha: c[2] }));
}

function readNiveisTime(): { niveis: Record<string, number>; media: number; data: string; subiram: string[] } {
  try {
    const files = fs.readdirSync(AUD).filter(f => /^snapshot-\d{4}-\d{2}-\d{2}\.json$/.test(f)).sort();
    if (files.length === 0) return { niveis: {}, media: 0, data: '', subiram: [] };
    const latest = files[files.length - 1];
    const snap = JSON.parse(fs.readFileSync(path.join(AUD, latest), 'utf8'));
    let subiram: string[] = [];
    if (files.length >= 2) {
      const prev = JSON.parse(fs.readFileSync(path.join(AUD, files[files.length - 2]), 'utf8'));
      const niveisAtuais = snap.niveis || {};
      const niveisAntes = prev.niveis || {};
      subiram = Object.keys(niveisAtuais).filter(nome => niveisAntes[nome] !== undefined && niveisAtuais[nome] > niveisAntes[nome]);
    }
    return { niveis: snap.niveis || {}, media: snap.mediaNivel || 0, data: snap.data || '', subiram };
  } catch {
    return { niveis: {}, media: 0, data: '', subiram: [] };
  }
}

function checkRotinaHoje(): { trilhasHoje: boolean; auditoriaHoje: boolean; hoje: string } {
  const hoje = new Date().toISOString().slice(0, 10);
  const digest = path.join(RAIZ, 'pesquisa-diaria', `${hoje}.md`);
  const auditoria = path.join(AUD, `${hoje}.md`);
  return { trilhasHoje: fs.existsSync(digest), auditoriaHoje: fs.existsSync(auditoria), hoje };
}

function readRecentRecados(limit = 5): Recado[] {
  const content = readFileSafe(RECADOS);
  if (!content) return [];
  const blocks = content.split(/\n(?=## )/).filter(b => b.startsWith('## '));
  const recados: Recado[] = blocks.map(b => {
    const m = b.match(/^## (\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}) — William\n\n([\s\S]*)/);
    if (!m) return null;
    return { data: m[1], hora: m[2], texto: m[3].trim() };
  }).filter((r): r is Recado => r !== null);
  return recados.slice(-limit).reverse();
}

function salvarRecado(texto: string): void {
  const agora = new Date();
  const data = agora.toISOString().slice(0, 10);
  const hora = agora.toTimeString().slice(0, 5);
  const entrada = `\n## ${data} ${hora} — William\n\n${texto.trim()}\n`;
  if (!fs.existsSync(RECADOS)) {
    fs.writeFileSync(RECADOS, '# Recados do dono para o time\n\nLido pelo Diretor no início de toda sessão — ver `processo-empresa.md`.\n' + entrada, 'utf8');
  } else {
    fs.appendFileSync(RECADOS, entrada, 'utf8');
  }
}

function getWebviewHtml(): string {
  const fonts = readFileSafe(FONTS_FRAGMENT);
  return /* html */ `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<style>
${fonts}
:root {
  --paper:#f6efe0; --paper-dim:#ece0c8; --navy:#16233b; --ink:#201a14; --ink-soft:#574d3f;
  --gold:#b8842e; --gold-text:#8a6220; --vinho:#7a2e2e; --vinho-bg:#f4e4e1; --salvia:#3f5236; --salvia-bg:#e6ecdf;
  --line:#d8cdb4; --track:#e3d8bf; --bg:var(--paper); --surface:#fffdf7; --text:var(--ink); --text-dim:var(--ink-soft);
  --accent:var(--gold-text); --accent-strong:var(--navy);
}
body.vscode-dark {
  --bg:#14181f; --surface:#1b212b; --text:#ece6d8; --text-dim:#a9a08c; --accent:#d3a860; --accent-strong:#8fa3c9;
  --line:#333c4c; --track:#262e3b; --vinho-bg:#3a2320; --salvia-bg:#232c1f; --paper-dim:#232937;
}
* { box-sizing: border-box; }
body { background: var(--bg); color: var(--text); font-family: 'Jakarta', var(--vscode-font-family, sans-serif); font-size: 14px; line-height: 1.5; padding: 24px 30px 60px; max-width: 1040px; margin: 0 auto; }
code { font-family: ui-monospace, "SF Mono", Consolas, monospace; font-size: 0.9em; background: var(--paper-dim); border-radius: 4px; padding: 0.05em 0.4em; }

.topbar { display: flex; align-items: flex-start; justify-content: space-between; gap: 14px; }
h1 { font-family: 'Bricolage', sans-serif; font-size: 24px; font-weight: 800; color: var(--accent-strong); margin: 0 0 4px; letter-spacing: -0.01em; }
.dek { color: var(--text-dim); font-size: 12.5px; margin: 0 0 20px; max-width: 62ch; }
.btn-refresh {
  font-size: 12px; font-weight: 700; padding: 6px 14px; border-radius: 999px; border: 1px solid var(--line);
  background: var(--surface); color: var(--text); cursor: pointer; flex: none;
}
.btn-refresh:hover { border-color: var(--accent-strong); }

h2.section-title { font-family: 'Bricolage', sans-serif; font-size: 16px; font-weight: 700; margin: 30px 0 4px; display: flex; align-items: center; gap: 8px; }
h2.section-title .count { font-size: 11px; font-weight: 700; color: var(--text-dim); background: var(--paper-dim); border-radius: 999px; padding: 1px 9px; }
p.section-sub { color: var(--text-dim); font-size: 12px; margin: 0 0 14px; }

.routine { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 20px; }
.routine-item { display: flex; align-items: center; gap: 10px; background: var(--surface); border: 1px solid var(--line); border-radius: 10px; padding: 10px 14px; font-size: 12px; }
.dot { width: 10px; height: 10px; border-radius: 50%; flex: none; }
.dot.ok { background: var(--salvia); } .dot.fail { background: var(--gold); animation: pulse 1.6s ease-in-out infinite; }
@keyframes pulse { 0%,100% { opacity:1 } 50% { opacity:.35 } }

.kpis { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 6px; }
.kpi { background: var(--surface); border: 1px solid var(--line); border-radius: 10px; padding: 12px 14px; }
.kpi-label { font-size: 10px; text-transform: uppercase; letter-spacing: .04em; color: var(--text-dim); font-weight: 700; margin-bottom: 4px; }
.kpi-value { font-family: 'Bricolage', sans-serif; font-weight: 800; font-size: 22px; color: var(--accent-strong); }

.diretor-card { background: var(--surface); border: 1px solid var(--line); border-radius: 10px; padding: 16px 18px; margin-bottom: 18px; }
.diretor-top { display: flex; gap: 20px; align-items: center; margin-bottom: 14px; }
.diretor-nivel-box { flex: none; text-align: center; }
.diretor-nivel-num { font-family: 'Bricolage', sans-serif; font-weight: 800; font-size: 34px; color: var(--accent-strong); line-height: 1; }
.diretor-nivel-label { font-size: 9.5px; color: var(--text-dim); text-transform: uppercase; margin-top: 2px; }
.diretor-progress { flex: 1; }
.diretor-progress-label { font-size: 11.5px; font-weight: 700; color: var(--text-dim); margin-bottom: 6px; }
.diretor-progress-track { height: 7px; background: var(--track); border-radius: 4px; overflow: hidden; }
.diretor-progress-fill { height: 100%; background: var(--accent); }
.diretor-next { font-size: 11px; color: var(--text-dim); margin-top: 6px; }
.diretor-mestres { display: flex; flex-direction: column; gap: 7px; border-top: 1px solid var(--line); padding-top: 10px; }
.diretor-mestre { display: flex; gap: 8px; align-items: baseline; font-size: 12px; }
.diretor-mestre .num { font-family: ui-monospace, monospace; font-weight: 700; color: var(--accent-strong); flex: none; width: 20px; }
.diretor-mestre .nome { font-weight: 700; }
.diretor-mestre .fw { color: var(--text-dim); font-size: 11px; }
.diretor-mestre .quando { margin-left: auto; font-size: 10px; color: var(--text-dim); flex: none; }

.charts { display: grid; grid-template-columns: 1fr 1.3fr; gap: 12px; margin: 18px 0; }
.chart-card { background: var(--surface); border: 1px solid var(--line); border-radius: 10px; padding: 14px 16px; }
.chart-card h3 { font-size: 10.5px; text-transform: uppercase; letter-spacing: .04em; color: var(--text-dim); font-weight: 700; margin: 0 0 12px; }
.donut-row { display: flex; align-items: center; gap: 16px; }
.donut { width: 76px; height: 76px; border-radius: 50%; flex: none; display: flex; align-items: center; justify-content: center; }
.donut-hole { width: 44px; height: 44px; border-radius: 50%; background: var(--surface); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px; color: var(--text); }
.donut-legend { font-size: 11.5px; display: flex; flex-direction: column; gap: 6px; }
.donut-legend .li { display: flex; align-items: center; gap: 6px; }
.donut-legend .sw { width: 9px; height: 9px; border-radius: 3px; }
.bar-row { display: grid; grid-template-columns: 90px 1fr 20px; align-items: center; gap: 8px; font-size: 11px; margin-bottom: 7px; cursor: pointer; }
.bar-row .bn { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-weight: 600; }
.bar-track { height: 8px; background: var(--track); border-radius: 4px; overflow: hidden; }
.bar-fill { height: 100%; background: var(--accent); }
.bar-row.active .bn { color: var(--accent-strong); }
.bar-row.active .bar-fill { background: var(--vinho); }

.filter-bar { display: flex; gap: 6px; margin-bottom: 10px; flex-wrap: wrap; }
.filter-btn { font-size: 11.5px; font-weight: 700; border: 1px solid var(--line); background: var(--surface); color: var(--text-dim); padding: 5px 12px; border-radius: 999px; cursor: pointer; }
.filter-btn.active { background: var(--accent-strong); color: var(--paper); border-color: var(--accent-strong); }

.notes-box { background: var(--surface); border: 1px solid var(--line); border-radius: 10px; padding: 14px 16px; margin-bottom: 4px; }
textarea { width: 100%; min-height: 74px; font-family: inherit; font-size: 12.5px; padding: 9px 11px; border-radius: 7px; border: 1px solid var(--line); background: var(--bg); color: var(--text); resize: vertical; }
textarea:focus { outline: 2px solid var(--accent-strong); outline-offset: 1px; }
button.save { margin-top: 8px; font-size: 12px; font-weight: 700; padding: 6px 15px; border-radius: 999px; border: none; background: var(--accent-strong); color: var(--paper); cursor: pointer; }
.recado-status { font-size: 11px; color: var(--text-dim); margin-top: 6px; }
.recado-history { margin-top: 14px; border-top: 1px solid var(--line); padding-top: 10px; }
.recado-item { border-left: 3px solid var(--accent-strong); padding: 2px 0 2px 10px; font-size: 12px; margin-bottom: 8px; }
.recado-item .rh { color: var(--text-dim); font-size: 10.5px; }

table { width: 100%; border-collapse: collapse; font-size: 12px; margin-bottom: 8px; }
th { text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .03em; color: var(--text-dim); font-weight: 700; border-bottom: 1px solid var(--line); padding: 6px 8px; position: sticky; top: 0; background: var(--bg); }
td { padding: 7px 8px; border-bottom: 1px solid var(--line); vertical-align: top; }
.table-wrap { border: 1px solid var(--line); border-radius: 10px; overflow: hidden; max-height: 360px; overflow-y: auto; }
.table-wrap table { margin-bottom: 0; }
.pill { display: inline-block; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 999px; white-space: nowrap; }
.pill.aberto { background: color-mix(in srgb, var(--gold) 20%, transparent); color: var(--gold-text); }
.pill.bloqueado { background: var(--vinho-bg); color: var(--vinho); }
.pill.assigned, .pill.ready { background: color-mix(in srgb, var(--accent-strong) 16%, transparent); color: var(--accent-strong); }
.pill.in-progress { background: color-mix(in srgb, var(--gold) 20%, transparent); color: var(--gold-text); }
.pill.review, .pill.needs-revision { background: var(--vinho-bg); color: var(--vinho); }
.pill.done { background: var(--salvia-bg); color: var(--salvia); }
.pill.cancelled { background: var(--paper-dim); color: var(--text-dim); }
.level-row { display: grid; grid-template-columns: 190px 1fr 26px; align-items: center; gap: 10px; padding: 4px 0; font-size: 12px; }
.level-track { height: 6px; background: var(--track); border-radius: 4px; overflow: hidden; }
.level-fill { height: 100%; background: var(--accent); }
.empty { color: var(--text-dim); font-size: 12px; font-style: italic; padding: 10px 0; }
footer { margin-top: 34px; padding-top: 14px; border-top: 1px solid var(--line); font-size: 10.5px; color: var(--text-dim); }

.cc { background: var(--accent-strong); color: var(--paper); border-radius: 12px; padding: 18px 22px; margin-bottom: 24px; }
body.vscode-dark .cc { background: var(--surface); border: 1px solid var(--accent-strong); color: var(--text); }
.cc-top { display: flex; align-items: center; justify-content: space-between; gap: 20px; flex-wrap: wrap; margin-bottom: 14px; }
.cc-title { font-family: 'Bricolage', sans-serif; font-weight: 800; font-size: 15px; letter-spacing: 0.02em; text-transform: uppercase; opacity: 0.85; }
.cc-maturity { display: flex; align-items: center; gap: 10px; }
.cc-maturity-num { font-family: 'Bricolage', sans-serif; font-weight: 800; font-size: 26px; }
.cc-maturity-track { width: 140px; height: 8px; border-radius: 5px; background: rgba(255,255,255,0.22); overflow: hidden; }
body.vscode-dark .cc-maturity-track { background: var(--track); }
.cc-maturity-fill { height: 100%; background: var(--gold); }
.cc-counts { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 16px; }
.cc-count { background: rgba(255,255,255,0.1); border-radius: 8px; padding: 8px 10px; text-align: center; }
body.vscode-dark .cc-count { background: var(--paper-dim); }
.cc-count .n { font-family: 'Bricolage', sans-serif; font-weight: 800; font-size: 20px; }
.cc-count .l { font-size: 9.5px; text-transform: uppercase; letter-spacing: 0.04em; opacity: 0.75; }
.cc-count.p0 .n { color: #ff8a80; } .cc-count.p1 .n { color: #ffca80; } .cc-count.p2 .n { color: #ffe680; } .cc-count.done .n { color: #9ee8a8; }
.cc-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.cc-sub { font-size: 10px; text-transform: uppercase; letter-spacing: 0.05em; opacity: 0.7; font-weight: 700; margin-bottom: 8px; }
.cc-sys-row { display: grid; grid-template-columns: 110px 1fr 28px; align-items: center; gap: 8px; font-size: 11.5px; margin-bottom: 6px; }
.cc-sys-track { height: 6px; border-radius: 4px; background: rgba(255,255,255,0.18); overflow: hidden; }
body.vscode-dark .cc-sys-track { background: var(--track); }
.cc-sys-fill { height: 100%; background: var(--gold); }
.cc-agora-item, .cc-alert-item { font-size: 11.5px; padding: 5px 0; border-bottom: 1px solid rgba(255,255,255,0.12); display: flex; gap: 8px; align-items: baseline; }
body.vscode-dark .cc-agora-item, body.vscode-dark .cc-alert-item { border-color: var(--line); }
.cc-agora-item:last-child, .cc-alert-item:last-child { border-bottom: none; }
.cc-pid { font-family: ui-monospace, monospace; font-weight: 700; opacity: 0.7; flex: none; }
.cc-empty { font-size: 11.5px; opacity: 0.65; font-style: italic; }

.tok-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 16px; }
.n8n-pill { display: inline-flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 700; padding: 6px 14px; border-radius: 999px; margin-bottom: 14px; }
.n8n-pill.ok { background: var(--salvia-bg); color: var(--salvia); }
.n8n-pill.fail { background: var(--vinho-bg); color: var(--vinho); animation: pulse 1.6s ease-in-out infinite; }
.agentes-grid { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 18px; }
.agente-chip { font-family: ui-monospace, "SF Mono", Consolas, monospace; font-size: 11.5px; background: var(--surface); border: 1px solid var(--line); border-radius: 999px; padding: 4px 10px; color: var(--text-dim); }
.tok-stat { background: var(--surface); border: 1px solid var(--line); border-radius: 10px; padding: 10px 12px; }
.tok-stat .v { font-family: 'Bricolage', sans-serif; font-weight: 800; font-size: 18px; color: var(--accent-strong); }
.tok-stat .l { font-size: 9.5px; text-transform: uppercase; letter-spacing: .04em; color: var(--text-dim); margin-top: 2px; }
.tok-chart-row { display: grid; grid-template-columns: 78px 1fr 74px; align-items: center; gap: 8px; font-size: 11px; margin-bottom: 5px; }
.tok-chart-row .tn { color: var(--text-dim); font-variant-numeric: tabular-nums; }
.tok-chart-track { height: 14px; background: var(--track); border-radius: 4px; overflow: hidden; display: flex; }
.tok-chart-fill { height: 100%; background: var(--accent); }
.tok-chart-fill.today { background: var(--vinho); }
.tok-chart-val { text-align: right; font-variant-numeric: tabular-nums; color: var(--text-dim); }
</style>
</head>
<body>
  <div class="topbar">
    <div>
      <h1>Painel do Ecossistema</h1>
      <p class="dek">Lido direto de <code>problemas.md</code>, <code>decisoes.md</code> e do snapshot mais recente — sem republicar nada, sempre o arquivo real agora.</p>
    </div>
    <button class="btn-refresh" id="btn-refresh">↻ Atualizar</button>
  </div>

  <div id="n8n-status"></div>

  <div class="cc" id="control-center"></div>

  <h2 class="section-title">Painel do Diretor <span class="count" id="count-painel-diretor"></span></h2>
  <p class="section-sub">Nível de projeto/risco/decisão/oportunidade de negócio — diferente do Control Center acima, que cobre só o backlog de evolução do próprio ecossistema. Performance Global / Qualidade / Execução não aparecem aqui — nenhuma fonte real mede esses três números hoje (ver <code>auditoria/decisoes.md</code>, 2026-08-13).</p>
  <div class="kpis" id="kpis-painel-diretor" style="grid-template-columns:repeat(6,1fr);margin-bottom:18px;"></div>
  <div class="table-wrap" style="margin-bottom:14px;"><table id="tabela-projetos"></table></div>
  <div class="table-wrap"><table id="tabela-atrasados"></table></div>
  <p class="section-sub" id="oportunidades-nota" style="margin-top:10px;"></p>

  <h2 class="section-title">Onde encontrar <span class="count" id="count-onde"></span></h2>
  <p class="section-sub">De <code>auditoria/source-of-truth.md</code> — pra qualquer categoria, é aqui que a resposta real mora, não em memória de conversa antiga.</p>
  <div class="table-wrap"><table id="tabela-onde"></table></div>

  <div class="routine" id="routine"></div>
  <div class="kpis" id="kpis"></div>

  <h2 class="section-title">Suas ações (William) <span class="count" id="count-minhas"></span></h2>
  <p class="section-sub">Todo item aberto com você como dono — inclusive bloqueado, nada escondido. Sempre visível, não é atrás de filtro.</p>
  <div class="table-wrap"><table id="tabela-minhas"></table></div>

  <h2 class="section-title">Desenvolvimento do Diretor <span class="count" id="diretor-nivel-badge"></span></h2>
  <div class="diretor-card">
    <div class="diretor-top">
      <div class="diretor-nivel-box"><div class="diretor-nivel-num" id="diretor-nivel-num"></div><div class="diretor-nivel-label">nível</div></div>
      <div class="diretor-progress">
        <div class="diretor-progress-label">Currículo — <span id="diretor-progress-count"></span> mestres registrados</div>
        <div class="diretor-progress-track"><div class="diretor-progress-fill" id="diretor-progress-fill"></div></div>
        <div class="diretor-next" id="diretor-next"></div>
      </div>
    </div>
    <div class="diretor-mestres" id="diretor-mestres"></div>
  </div>

  <h2 class="section-title">Gráficos</h2>
  <div class="charts">
    <div class="chart-card"><h3>Status</h3><div class="donut-row"><div class="donut" id="donut"></div><div class="donut-legend" id="donut-legend"></div></div></div>
    <div class="chart-card"><h3>Por dono</h3><div id="owner-bars"></div></div>
  </div>
  <div class="chart-card" style="margin-bottom:18px;"><h3>Por prazo</h3><div id="prazo-bars"></div></div>

  <div class="notes-box">
    <label style="font-size:11.5px;font-weight:700;color:var(--text-dim);">Escreva um recado pro time</label>
    <textarea id="recado-texto" placeholder="Fica salvo em auditoria/recados-dono.md — o Diretor lê isso no início de toda sessão." style="margin-top:8px;"></textarea>
    <button class="save" id="btn-salvar">Salvar recado</button>
    <div class="recado-status" id="recado-status"></div>
    <div class="recado-history" id="recado-history"></div>
  </div>

  <div id="tok-higiene-banner"></div>
  <h2 class="section-title">Economia de Token <span class="count" id="count-tok-dias"></span></h2>
  <p class="section-sub">Medido de verdade no transcript real da sessão (<code>auditoria/uso-tokens-real.json</code>) — nunca estimado. Output = o que eu gero; é a parte mais sob meu controle direto.</p>
  <div class="tok-stats" id="tok-stats"></div>
  <div id="tok-chart" style="margin-bottom:22px;"></div>

  <h2 class="section-title">Organograma <span class="count" id="count-agentes"></span></h2>
  <p class="section-sub">Descoberto ao vivo em <code>~/.claude/agents/</code> — um agente novo aparece aqui sozinho, sem precisar sincronizar lista nenhuma. Detalhe de função em cada um: <a href="https://claude.ai/code/artifact/f805f5ae-969b-4491-ba5a-a4468b5fa6f5" style="color:var(--accent-strong);">artefato Organograma</a>.</p>
  <div id="agentes-grid" class="agentes-grid"></div>

  <h2 class="section-title">Evolution Backlog <span class="count" id="count-backlog"></span></h2>
  <p class="section-sub">Plano de evolução do Innovator Director — <code>auditoria/evolution-backlog.md</code>. Nunca marcado DONE sem evidência na última coluna.</p>
  <div class="table-wrap"><table id="tabela-backlog"></table></div>

  <h2 class="section-title">Quadro de problemas <span class="count" id="count-abertos"></span></h2>
  <div class="filter-bar" id="filter-bar"></div>
  <div class="table-wrap"><table id="tabela-problemas"></table></div>

  <h2 class="section-title">Nível do time <span class="count" id="count-niveis"></span></h2>
  <div id="niveis"></div>

  <h2 class="section-title">Escada de Autonomia</h2>
  <div class="table-wrap"><table id="tabela-escada"></table></div>

  <h2 class="section-title">Resolvidos <span class="count" id="count-resolvidos"></span></h2>
  <div class="table-wrap"><table id="tabela-resolvidos"></table></div>

  <h2 class="section-title">Achados pela auditoria, já resolvidos <span class="count" id="count-audit-caught"></span></h2>
  <p class="section-sub">Só o que o script <code>auditoria-diaria.ps1</code> mediu e apontou sozinho — prova de que o instrumento funciona.</p>
  <div class="table-wrap"><table id="tabela-audit-caught"></table></div>

  <footer>auditoria-diaria.ps1 + problemas.md + decisoes.md — script/verificação, nunca julgamento de modelo</footer>

<script>
  const vscode = acquireVsCodeApi();
  const PRIORIDADE_ORDEM = { P0: 0, P1: 1, P2: 2, P3: 3 };
  let DADOS = null;
  let activeStatus = 'todos';
  let activeOwner = null;

  function pedirDados() { vscode.postMessage({ type: 'pedirDados' }); }
  pedirDados();
  document.getElementById('btn-refresh').addEventListener('click', pedirDados);

  document.getElementById('btn-salvar').addEventListener('click', () => {
    const texto = document.getElementById('recado-texto').value.trim();
    if (!texto) return;
    vscode.postMessage({ type: 'salvarRecado', texto });
  });

  window.addEventListener('message', (event) => {
    const msg = event.data;
    if (msg.type === 'dados') { DADOS = msg.payload; renderAll(); }
    if (msg.type === 'recadoSalvo') {
      document.getElementById('recado-texto').value = '';
      document.getElementById('recado-status').textContent = 'Salvo às ' + msg.hora + ' — o Diretor lê isso no início da próxima sessão.';
      pedirDados();
    }
  });

  // Task State Machine (BL-004, 2026-08-09): itens novos usam os estados em
  // inglês (READY/ASSIGNED/IN_PROGRESS/...); itens antigos continuam com o
  // texto português (Aberto/Bloqueado) — os dois precisam de pill reconhecível.
  function pillClass(status) {
    const s = (status || '').toUpperCase();
    if (s.includes('BLOQUE') || s.includes('BLOCKED')) return 'bloqueado';
    if (s.includes('NEEDS_REVISION')) return 'needs-revision';
    if (s.includes('REVIEW')) return 'review';
    if (s.includes('CANCELLED')) return 'cancelled';
    if (s.includes('DONE') || s.includes('APPROVED')) return 'done';
    if (s.includes('IN_PROGRESS')) return 'in-progress';
    if (s.includes('ASSIGNED')) return 'assigned';
    if (s.includes('READY')) return 'ready';
    return 'aberto';
  }

  function groupBy(arr, key) {
    const m = new Map();
    for (const p of arr) m.set(p[key], (m.get(p[key]) || 0) + 1);
    return [...m.entries()].sort((a, b) => b[1] - a[1]);
  }

  function renderControlCenter(d) {
    const bl = d.backlog || [];
    const total = bl.length || 1;
    const done = bl.filter(b => b.status === 'DONE').length;
    const maturidade = Math.round((done / total) * 100);
    const nivel = (done / total * 10).toFixed(1);
    const porPrioridade = (p) => bl.filter(b => b.prioridade === p && b.status !== 'DONE' && b.status !== 'CANCELLED').length;

    const categorias = [...new Set(bl.map(b => b.categoria))];
    const sistemas = categorias.map(cat => {
      const itens = bl.filter(b => b.categoria === cat);
      const doneCat = itens.filter(b => b.status === 'DONE').length;
      return { cat, pct: Math.round((doneCat / itens.length) * 100), n: itens.length };
    }).sort((a, b) => b.pct - a.pct);

    const agora = bl.filter(b => ['READY', 'ASSIGNED', 'IN_PROGRESS'].includes(b.status))
      .sort((a, b) => (PRIORIDADE_ORDEM[a.prioridade] ?? 9) - (PRIORIDADE_ORDEM[b.prioridade] ?? 9))
      .slice(0, 6);

    const bloqueados = d.abertos.filter(p => /bloque/i.test(p.status)).length;
    const p0NaoIniciado = bl.filter(b => b.prioridade === 'P0' && b.status === 'BACKLOG').length;
    const alertas = [];
    if (bloqueados > 0) alertas.push(bloqueados + ' item(ns) do quadro de problemas bloqueado(s)');
    if (d.riscosAbertos > 0) alertas.push(d.riscosAbertos + ' risco(s) aberto(s) em riscos.md, sem mitigação completa');
    if (d.decisoesPendentes > 0) alertas.push(d.decisoesPendentes + ' decisão(ões) com resultado real ainda pendente');
    if (p0NaoIniciado > 0) alertas.push(p0NaoIniciado + ' item(ns) P0 do backlog ainda em BACKLOG, sem dono ativo');

    const cc = document.getElementById('control-center');
    cc.innerHTML =
      '<div class="cc-top">' +
        '<div class="cc-title">Innovator Director — Control Center</div>' +
        '<div class="cc-maturity"><div class="cc-maturity-num">' + maturidade + '%</div>' +
          '<div class="cc-maturity-track"><div class="cc-maturity-fill" style="width:' + maturidade + '%"></div></div>' +
          '<div style="font-size:11px;opacity:.75;">nível ' + nivel + '/10</div></div>' +
      '</div>' +
      '<div class="cc-counts">' +
        '<div class="cc-count p0"><div class="n">' + porPrioridade('P0') + '</div><div class="l">P0 críticos</div></div>' +
        '<div class="cc-count p1"><div class="n">' + porPrioridade('P1') + '</div><div class="l">P1 altos</div></div>' +
        '<div class="cc-count p2"><div class="n">' + porPrioridade('P2') + '</div><div class="l">P2 médios</div></div>' +
        '<div class="cc-count done"><div class="n">' + done + '</div><div class="l">Concluídos</div></div>' +
      '</div>' +
      '<div class="cc-grid">' +
        '<div><div class="cc-sub">Sistemas (% concluído por categoria)</div>' +
          (sistemas.length === 0 ? '<div class="cc-empty">Sem itens ainda.</div>' : sistemas.map(s =>
            '<div class="cc-sys-row"><div>' + s.cat + '</div><div class="cc-sys-track"><div class="cc-sys-fill" style="width:' + s.pct + '%"></div></div><div>' + s.pct + '%</div></div>'
          ).join('')) +
        '</div>' +
        '<div>' +
          '<div class="cc-sub">Agora</div>' +
          (agora.length === 0 ? '<div class="cc-empty">Nada em READY/ASSIGNED/IN_PROGRESS.</div>' : agora.map(b =>
            '<div class="cc-agora-item"><span class="cc-pid">' + b.id + '</span><span>' + b.titulo + ' — ' + b.status + '</span></div>'
          ).join('')) +
          '<div class="cc-sub" style="margin-top:12px;">Alertas</div>' +
          (alertas.length === 0 ? '<div class="cc-empty">Nenhum alerta real agora.</div>' : alertas.map(a =>
            '<div class="cc-alert-item">⚠ ' + a + '</div>'
          ).join('')) +
        '</div>' +
      '</div>';

    document.getElementById('count-backlog').textContent = bl.length;
    const tb = document.getElementById('tabela-backlog');
    tb.innerHTML = bl.length === 0 ? '<tr><td class="empty">Backlog vazio.</td></tr>' :
      '<tr><th>ID</th><th>Título</th><th>Categoria</th><th>Prio.</th><th>Status</th><th>Responsável</th><th>Prazo</th></tr>' +
      bl.map(b => '<tr><td>' + b.id + '</td><td>' + b.titulo + '</td><td>' + b.categoria + '</td><td>' + b.prioridade + '</td><td>' + b.status + '</td><td>' + b.responsavel + '</td><td>' + b.prazo + '</td></tr>').join('');
  }

  function renderPainelDiretor(d) {
    const projetos = d.projetos || [];
    const oportunidades = d.oportunidades || { total: 0, linhas: [] };
    const atrasados = d.atrasados || [];
    document.getElementById('count-painel-diretor').textContent = projetos.length + ' projeto(s)';

    document.getElementById('kpis-painel-diretor').innerHTML =
      '<div class="kpi"><div class="kpi-label">Projetos</div><div class="kpi-value">' + projetos.length + '</div></div>' +
      '<div class="kpi"><div class="kpi-label">Em risco</div><div class="kpi-value">' + d.riscosAbertos + '</div></div>' +
      '<div class="kpi"><div class="kpi-label">Atrasados</div><div class="kpi-value">' + atrasados.length + '</div></div>' +
      '<div class="kpi"><div class="kpi-label">Concluídos</div><div class="kpi-value">' + d.resolvidos.length + '</div></div>' +
      '<div class="kpi"><div class="kpi-label">Decisões Necessárias</div><div class="kpi-value">' + d.decisoesPendentes + '</div></div>' +
      '<div class="kpi"><div class="kpi-label">Oportunidades</div><div class="kpi-value">' + oportunidades.total + '</div></div>';

    const tp = document.getElementById('tabela-projetos');
    tp.innerHTML = projetos.length === 0 ? '<tr><td class="empty">Nenhum projeto registrado.</td></tr>' :
      '<tr><th>ID</th><th>Nome</th><th>Prioridade</th><th>Fase</th><th>Próximo checkpoint</th></tr>' +
      projetos.map(p => '<tr><td>' + p.id + '</td><td>' + p.nome + '</td><td>' + p.prioridade + '</td><td>' + p.fase + '</td><td>' + p.proximoCheckpoint + '</td></tr>').join('');

    const ta = document.getElementById('tabela-atrasados');
    ta.innerHTML = atrasados.length === 0 ? '<tr><td class="empty">Nada vencido hoje.</td></tr>' :
      '<tr><th>#</th><th>Problema</th><th>Dono</th><th>Prazo</th><th>Dias vencido</th></tr>' +
      atrasados.map(a => '<tr><td>#' + a.id + '</td><td>' + a.problema + '</td><td>' + a.dono + '</td><td>' + a.prazo + '</td><td>' + a.diasVencido + '</td></tr>').join('');

    document.getElementById('oportunidades-nota').textContent =
      oportunidades.total === 0 ? 'Pipeline de oportunidades vazio — nenhuma execução do cerebro-empreendedor ainda.' : '';
  }

  function renderHigieneSessao(d) {
    const el = document.getElementById('tok-higiene-banner');
    const h = d.higieneSessao;
    if (!h || h.recomendacao !== 'compact') { el.innerHTML = ''; return; }
    el.innerHTML = '<div class="tok-stat" style="margin-bottom:12px;border-color:var(--vinho);">' +
      '<div class="v" style="color:var(--vinho);font-size:13px;">Sessão ativa há ' + h.diasAtivos + ' dias — resumo pronto em <code>' + h.handoffPath + '</code>, rode <code>/compact</code> quando for parar.</div>' +
    '</div>';
  }

  function renderTokenEconomy(d) {
    renderHigieneSessao(d);
    const dias = d.usoTokens || [];
    document.getElementById('count-tok-dias').textContent = dias.length + ' dias reais';
    const stats = document.getElementById('tok-stats');
    if (dias.length === 0) {
      stats.innerHTML = '<div class="tok-stat"><div class="v">—</div><div class="l">sem medição ainda</div></div>';
      document.getElementById('tok-chart').innerHTML = '';
      return;
    }
    const hoje = dias[dias.length - 1];
    const ontem = dias.length > 1 ? dias[dias.length - 2] : null;
    const deltaPct = ontem && ontem.output > 0 ? Math.round(((hoje.output - ontem.output) / ontem.output) * 100) : null;
    const totalOutput = dias.reduce((s, x) => s + x.output, 0);
    stats.innerHTML =
      '<div class="tok-stat"><div class="v">' + hoje.output.toLocaleString('pt-BR') + '</div><div class="l">Output — dia mais recente</div></div>' +
      '<div class="tok-stat"><div class="v">' + (deltaPct === null ? '—' : (deltaPct <= 0 ? deltaPct : '+' + deltaPct) + '%') + '</div><div class="l">vs. dia anterior</div></div>' +
      '<div class="tok-stat"><div class="v">' + hoje.turnos + '</div><div class="l">turnos no dia</div></div>' +
      '<div class="tok-stat"><div class="v">' + totalOutput.toLocaleString('pt-BR') + '</div><div class="l">Output total, ' + dias.length + ' dias</div></div>';

    const ultimos = dias.slice(-10);
    const maxOutput = Math.max(1, ...ultimos.map(x => x.output));
    document.getElementById('tok-chart').innerHTML = ultimos.map((x, i) => {
      const isToday = i === ultimos.length - 1;
      const pct = (x.output / maxOutput) * 100;
      return '<div class="tok-chart-row"><div class="tn">' + x.dia.slice(5) + '</div>' +
        '<div class="tok-chart-track"><div class="tok-chart-fill' + (isToday ? ' today' : '') + '" style="width:' + pct + '%"></div></div>' +
        '<div class="tok-chart-val">' + x.output.toLocaleString('pt-BR') + '</div></div>';
    }).join('');
  }

  function renderN8nStatus(d) {
    const el = document.getElementById('n8n-status');
    el.innerHTML = '<div class="n8n-pill ' + (d.n8nOk ? 'ok' : 'fail') + '">' +
      (d.n8nOk ? '● n8n rodando — 9 workflows de monitoramento ativos' : '○ n8n PARADO — nenhum workflow de monitoramento rodando agora') +
      '</div>';
  }

  function renderOndeEncontrar(d) {
    const linhas = d.ondeEncontrar || [];
    document.getElementById('count-onde').textContent = linhas.length;
    const t = document.getElementById('tabela-onde');
    t.innerHTML = linhas.length === 0 ? '<tr><td class="empty">Registro não encontrado.</td></tr>' :
      '<tr><th>Categoria</th><th>Onde você olha</th></tr>' +
      linhas.map(l => '<tr><td>' + l.categoria + '</td><td>' + l.ondeVoceOlha + '</td></tr>').join('');
  }

  function renderAgentes(d) {
    const ag = d.agentesReais || [];
    document.getElementById('count-agentes').textContent = ag.length;
    document.getElementById('agentes-grid').innerHTML = ag.map(a =>
      '<div class="agente-chip">' + a.nome + '</div>').join('');
  }

  function renderAll() {
    const d = DADOS;
    renderN8nStatus(d);
    renderOndeEncontrar(d);
    renderAgentes(d);
    renderControlCenter(d);
    renderPainelDiretor(d);
    renderTokenEconomy(d);
    document.getElementById('count-abertos').textContent = d.abertos.length;
    document.getElementById('count-resolvidos').textContent = d.resolvidos.length;
    document.getElementById('count-niveis').textContent = d.niveisData ? 'média ' + d.niveisData.media + '/5' : '';

    document.getElementById('routine').innerHTML =
      '<div class="routine-item"><span class="dot ' + (d.rotina.trilhasHoje ? 'ok' : 'fail') + '"></span>Trilhas ' + d.rotina.hoje + ': ' + (d.rotina.trilhasHoje ? 'rodou' : 'ainda não') + '</div>' +
      '<div class="routine-item"><span class="dot ' + (d.rotina.auditoriaHoje ? 'ok' : 'fail') + '"></span>Auditoria ' + d.rotina.hoje + ': ' + (d.rotina.auditoriaHoje ? 'rodou' : 'ainda não') + '</div>';

    if (d.diretorDev) {
      const dd = d.diretorDev;
      document.getElementById('diretor-nivel-badge').textContent = 'nível ' + dd.nivel + '/' + dd.totalCurriculo;
      document.getElementById('diretor-nivel-num').textContent = dd.nivel;
      document.getElementById('diretor-progress-count').textContent = dd.registrados.length + ' de ' + dd.totalCurriculo;
      document.getElementById('diretor-progress-fill').style.width = (dd.registrados.length / dd.totalCurriculo * 100) + '%';
      document.getElementById('diretor-next').textContent = dd.proximo ? 'Próximo: ' + dd.proximo : '';
      document.getElementById('diretor-mestres').innerHTML = dd.registrados.map(m =>
        '<div class="diretor-mestre"><span class="num">' + m.num + '</span><span class="nome">' + m.nome + '</span><span class="fw">— ' + m.framework + '</span><span class="quando">' + m.quando + '</span></div>'
      ).join('');
    }

    const bloqueados = d.abertos.filter(p => /bloque/i.test(p.status)).length;
    const abertosLimpo = d.abertos.length - bloqueados;
    const minhas = d.abertos.filter(p => /william/i.test(p.dono));
    document.getElementById('kpis').innerHTML =
      '<div class="kpi"><div class="kpi-label">Problemas</div><div class="kpi-value">' + d.abertos.length + '</div></div>' +
      '<div class="kpi"><div class="kpi-label">Bloqueados</div><div class="kpi-value">' + bloqueados + '</div></div>' +
      '<div class="kpi"><div class="kpi-label">Resolvidos</div><div class="kpi-value">' + d.resolvidos.length + '</div></div>' +
      '<div class="kpi"><div class="kpi-label">Suas ações (William)</div><div class="kpi-value">' + minhas.length + '</div></div>';

    document.getElementById('count-minhas').textContent = minhas.length;
    const tm = document.getElementById('tabela-minhas');
    tm.innerHTML = minhas.length === 0 ? '<tr><td class="empty">Nenhuma ação sua em aberto.</td></tr>' :
      '<tr><th>#</th><th>Problema</th><th>Prazo</th><th>Status</th></tr>' +
      minhas.map(p =>
        '<tr><td>#' + p.id + '</td><td>' + p.problema + '</td><td>' + p.prazo + '</td>' +
          '<td><span class="pill ' + pillClass(p.status) + '">' + p.status + '</span></td></tr>'
      ).join('');

    const total = d.abertos.length || 1;
    const pctBloq = (bloqueados / total) * 100;
    document.getElementById('donut').style.background = 'conic-gradient(var(--vinho) 0% ' + pctBloq + '%, var(--gold) ' + pctBloq + '% 100%)';
    document.getElementById('donut').innerHTML = '<div class="donut-hole">' + d.abertos.length + '</div>';
    document.getElementById('donut-legend').innerHTML =
      '<div class="li"><span class="sw" style="background:var(--gold)"></span> Aberto ' + abertosLimpo + '</div>' +
      '<div class="li"><span class="sw" style="background:var(--vinho)"></span> Bloqueado ' + bloqueados + '</div>';

    const ownerGroups = groupBy(d.abertos, 'dono');
    const maxOwner = Math.max(1, ...ownerGroups.map(g => g[1]));
    document.getElementById('owner-bars').innerHTML = ownerGroups.map(([nome, n]) =>
      '<div class="bar-row' + (activeOwner === nome ? ' active' : '') + '" data-owner="' + nome + '"><div class="bn">' + nome + '</div><div class="bar-track"><div class="bar-fill" style="width:' + (n / maxOwner * 100) + '%"></div></div><div>' + n + '</div></div>'
    ).join('');
    document.querySelectorAll('.bar-row').forEach(el => el.addEventListener('click', () => {
      const o = el.getAttribute('data-owner');
      activeOwner = activeOwner === o ? null : o;
      renderAll();
    }));

    const prazoGroups = groupBy(d.abertos, 'prazo');
    const maxPrazo = Math.max(1, ...prazoGroups.map(g => g[1]));
    document.getElementById('prazo-bars').innerHTML = prazoGroups.map(([prazo, n]) =>
      '<div class="bar-row"><div class="bn">' + prazo + '</div><div class="bar-track"><div class="bar-fill" style="width:' + (n / maxPrazo * 100) + '%"></div></div><div>' + n + '</div></div>'
    ).join('');

    const aberto = d.abertos.filter(p => !/bloque/i.test(p.status)).length;
    const opts = [{ key: 'todos', label: 'Todos', n: d.abertos.length }, { key: 'aberto', label: 'Aberto', n: aberto }, { key: 'bloqueado', label: 'Bloqueado', n: bloqueados }];
    document.getElementById('filter-bar').innerHTML = opts.map(o => '<button class="filter-btn' + (activeStatus === o.key ? ' active' : '') + '" data-status="' + o.key + '">' + o.label + ' (' + o.n + ')</button>').join('');
    document.querySelectorAll('.filter-btn').forEach(btn => btn.addEventListener('click', () => { activeStatus = btn.getAttribute('data-status'); renderAll(); }));

    let rows = d.abertos;
    if (activeStatus !== 'todos') rows = rows.filter(p => activeStatus === 'bloqueado' ? /bloque/i.test(p.status) : !/bloque/i.test(p.status));
    if (activeOwner) rows = rows.filter(p => p.dono === activeOwner);
    const tp = document.getElementById('tabela-problemas');
    tp.innerHTML = rows.length === 0 ? '<tr><td class="empty">Nada com este filtro.</td></tr>' :
      '<tr><th>#</th><th>Problema</th><th>Dono</th><th>Prazo</th><th>Status</th></tr>' +
      rows.map(p =>
        '<tr><td>#' + p.id + '</td><td>' + p.problema + '</td><td>' + p.dono + '</td><td>' + p.prazo + '</td>' +
          '<td><span class="pill ' + pillClass(p.status) + '">' + p.status + '</span></td></tr>'
      ).join('');

    const niveisDiv = document.getElementById('niveis');
    const entries = d.niveisData ? Object.entries(d.niveisData.niveis) : [];
    const subiram = (d.niveisData && d.niveisData.subiram) || [];
    niveisDiv.innerHTML = entries.length === 0 ? '<p class="empty">Sem snapshot ainda.</p>' :
      entries.sort((a, b) => b[1] - a[1]).map(([nome, nivel]) =>
        '<div class="level-row"><code>' + nome + (subiram.includes(nome) ? ' <span class="pill aberto" style="font-size:9px;">subiu</span>' : '') + '</code><div class="level-track"><div class="level-fill" style="width:' + (nivel / 5 * 100) + '%"></div></div><span>' + nivel + '</span></div>'
      ).join('');

    const te = document.getElementById('tabela-escada');
    te.innerHTML = d.escada.length === 0 ? '<tr><td class="empty">Sem dados.</td></tr>' :
      '<tr><th>Categoria</th><th>Nível</th><th>Responsável</th><th>Falta</th></tr>' +
      d.escada.map(e => '<tr><td>' + e.categoria + '</td><td>' + e.nivel + '</td><td>' + e.responsavel + '</td><td>' + e.falta + '</td></tr>').join('');

    const tr = document.getElementById('tabela-resolvidos');
    tr.innerHTML = d.resolvidos.length === 0 ? '<tr><td class="empty">Nada ainda.</td></tr>' :
      '<tr><th>Problema</th><th>Origem</th><th>Quando</th><th>Prova</th></tr>' +
      d.resolvidos.map(r => '<tr><td>' + r.problema + '</td><td>' + (r.origem || '—') + '</td><td>' + r.resolvidoEm + '</td><td>' + r.prova + '</td></tr>').join('');

    const daAuditoria = d.resolvidos.filter(r => (r.origem || '').toLowerCase() === 'auditoria');
    document.getElementById('count-audit-caught').textContent = daAuditoria.length;
    const tac = document.getElementById('tabela-audit-caught');
    tac.innerHTML = daAuditoria.length === 0 ? '<tr><td class="empty">Nenhum ainda.</td></tr>' :
      '<tr><th>Problema</th><th>Quando</th><th>Prova</th></tr>' +
      daAuditoria.map(r => '<tr><td>' + r.problema + '</td><td>' + r.resolvidoEm + '</td><td>' + r.prova + '</td></tr>').join('');

    const rh = document.getElementById('recado-history');
    rh.innerHTML = (!d.recados || d.recados.length === 0) ? '' :
      '<div style="font-size:11px;font-weight:700;color:var(--text-dim);margin-bottom:6px;">Últimos recados</div>' +
      d.recados.map(r => '<div class="recado-item"><div class="rh">' + r.data + ' ' + r.hora + '</div>' + r.texto + '</div>').join('');
  }
</script>
</body>
</html>`;
}

export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.commands.registerCommand('painelEcossistema.abrir', () => {
    const panel = vscode.window.createWebviewPanel(
      'painelEcossistema',
      'Painel do Ecossistema',
      vscode.ViewColumn.One,
      { enableScripts: true, retainContextWhenHidden: true }
    );
    panel.webview.html = getWebviewHtml();

    panel.webview.onDidReceiveMessage(async (msg) => {
      if (msg.type === 'pedirDados') {
        const { abertos, resolvidos } = parseProblemas();
        const niveisData = readNiveisTime();
        const escada = parseEscada();
        const rotina = checkRotinaHoje();
        const recados = readRecentRecados();
        const diretorDev = parseDiretorDev();
        const backlog = parseBacklog();
        const riscosAbertos = countRiscosAbertos();
        const decisoesPendentes = countDecisoesPendentes();
        const usoTokens = parseUsoTokens().dias;
        const higieneSessao = parseHigieneSessao();
        const agentesReais = listarAgentesReais();
        const ondeEncontrar = parseOndeEncontrar();
        const n8nOk = await checkN8nSaude();
        const projetos = parseProjetos();
        const oportunidades = parseOportunidades();
        const atrasados = countAtrasados(abertos);
        panel.webview.postMessage({ type: 'dados', payload: { abertos, resolvidos, niveisData, escada, rotina, recados, diretorDev, backlog, riscosAbertos, decisoesPendentes, usoTokens, higieneSessao, agentesReais, ondeEncontrar, n8nOk, projetos, oportunidades, atrasados } });
      }
      if (msg.type === 'salvarRecado') {
        salvarRecado(msg.texto);
        const hora = new Date().toTimeString().slice(0, 5);
        panel.webview.postMessage({ type: 'recadoSalvo', hora });
      }
    });
  });

  context.subscriptions.push(disposable);

  const statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
  statusBar.text = '$(dashboard) Painel do Ecossistema';
  statusBar.tooltip = 'Abrir o Painel do Ecossistema (Ctrl+Alt+P)';
  statusBar.command = 'painelEcossistema.abrir';
  statusBar.show();
  context.subscriptions.push(statusBar);
}

export function deactivate() {}
