// Codigo do node "Medir uso real de token" do workflow economiaToken000001.
// Mantido como arquivo separado so pra poder testar com `node` antes de colar
// no JSON do workflow (n8n nao roda arquivo externo, o texto e colado no
// campo jsCode) -- nunca importado em runtime.
const { execSync } = require('child_process');
const fs = require('fs');

const PROJECTS_DIR = 'C:\\Users\\usuario\\.claude\\projects\\c--Users-usuario-Desktop-Projeto-professor-William';
const PARSER = 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William\\automacao-n8n\\parse-token-usage.js';
const SAIDA = 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William\\auditoria\\uso-tokens-real.json';
const ALERTAS = 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William\\auditoria\\alertas-automaticos.md';
const HANDOFF_SCRIPT = 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William\\automacao-n8n\\gerar-handoff-sessao.js';
const AUDITORIA_DIR = 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William\\auditoria';
const HANDOFF_MD = 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William\\auditoria\\handoff-sessao.md';
const STATUS_PATH = 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William\\auditoria\\higiene-sessao-status.json';

// O parser agora varre o diretorio inteiro sozinho (todos os .jsonl, todos os
// dias, agregando por sessao) -- nao escolhemos mais "o maior arquivo" aqui.
let erro = null;
try {
  execSync(`node "${PARSER}" "${PROJECTS_DIR}" "${SAIDA}"`, { encoding: 'utf8', timeout: 180000, maxBuffer: 20 * 1024 * 1024 });
} catch (e) {
  erro = e.message || String(e);
}

const agora = new Date();
const pad = n => String(n).padStart(2, '0');
const dataStr = `${agora.getUTCFullYear()}-${pad(agora.getUTCMonth() + 1)}-${pad(agora.getUTCDate())}`;
const horaStr = `${pad(agora.getUTCHours())}:${pad(agora.getUTCMinutes())}`;

let bloco = `\n## ${dataStr} ${horaStr} — n8n (automático, Economia de Token)\n\n`;

// Jidoka (Shingo): o workflow NUNCA termina sem atualizar STATUS_PATH, nem em erro.
// Le o estado anterior pra herdar os campos que so fazem sentido numa medicao boa
// (diasAtivos/recomendacao/handoffAtualizadoEm) -- no erro, nunca inventa valor novo pra eles.
// E tambem pra comparar contra o novo `status.recomendacao` e detectar a TRANSICAO
// ok->compact (aviso real, pedido do dono 19/08 -- ver bloco de PushNotification abaixo).
let anterior = {};
try { anterior = JSON.parse(fs.readFileSync(STATUS_PATH, 'utf8')); } catch (e) { /* primeira execucao, sem status anterior */ }

let status;
if (erro) {
  bloco += `Falha ao medir uso de token: ${erro}\n`;
  status = {
    diasAtivos: anterior.diasAtivos ?? null,
    recomendacao: anterior.recomendacao ?? 'desconhecida',
    handoffAtualizadoEm: anterior.handoffAtualizadoEm ?? null,
    handoffPath: 'auditoria/handoff-sessao.md',
    ultimaMedicaoOk: false,
    erroUltimaMedicao: erro,
    erroUltimaMedicaoEm: agora.toISOString()
  };
} else {
  const dados = JSON.parse(fs.readFileSync(SAIDA, 'utf8'));

  // A "sessao ativa" pra fins de higiene (reiniciar ou nao) e a sessao
  // INTERATIVA tocada mais RECENTEMENTE (maior dia em `dias`) -- nunca uma
  // automacao (trilha/auditoria/reuniao), que e sempre curta e nao acumula
  // contexto entre dias. Escolher pelo TOTAL de tokens (como o script antigo
  // fazia, via "maior arquivo em bytes") erra: uma conversa antiga e enorme,
  // abandonada ha dias, teria mais tokens que a conversa de hoje e venceria
  // por engano -- e a higiene tem que apontar pra o que esta aberto AGORA.
  const sessoes = Object.entries(dados.porSessao || {});
  let ativa = null, ativaUltimoDia = null;
  for (const [, s] of sessoes) {
    if (s.tipo !== 'interativa') continue;
    const ultimoDia = s.dias[s.dias.length - 1];
    if (!ativa || ultimoDia > ativaUltimoDia) { ativa = s; ativaUltimoDia = ultimoDia; }
  }
  const diasSessaoAtiva = ativa ? ativa.dias.length : 0;

  bloco += `Medido: ${dados.linhasProcessadas} linhas de ${dados.arquivosProcessados} arquivos de sessão, ${dados.mensagensComUsage} turnos com uso real. `;
  bloco += `Sessão interativa ativa (maior consumo) soma ${diasSessaoAtiva} dia(s) sem reiniciar. `;

  const dias = Object.keys(dados.porDia).sort();
  const hoje = dados.porDia[dias[dias.length - 1]];
  const ontem = dados.porDia[dias[dias.length - 2]];
  if (hoje && ontem) {
    const deltaOutput = hoje.output - ontem.output;
    const sinal = deltaOutput <= 0 ? 'reduziu' : 'aumentou';
    bloco += `Output do dia mais recente (todas as sessões somadas): ${hoje.output.toLocaleString('pt-BR')} tokens (${sinal} ${Math.abs(deltaOutput).toLocaleString('pt-BR')} vs. o dia anterior). `;
  } else {
    bloco += `Ainda sem 2 dias completos pra comparar. `;
  }

  // ponytail: handoff só é regenerado quando a higiene de fato dispara (dias>=3) --
  // fora disso, herda o mtime real do handoff-sessao.md (ou null se nunca existiu),
  // pra o status.json nunca afirmar um "atualizado em" que não aconteceu de verdade.
  let handoffAtualizadoEm = null;
  if (diasSessaoAtiva >= 3) {
    bloco += `\n\nHIGIENE DE SESSÃO: a sessão ativa já soma ${diasSessaoAtiva} dias sem nunca reiniciar — é a causa raiz real do cache_read alto (todo o histórico é reprocessado a cada turno, mesmo em cache). Recomendação real: começar uma conversa nova pro próximo assunto grande, não continuar empilhando nesta.\n`;
    try {
      execSync(`node "${HANDOFF_SCRIPT}" "${AUDITORIA_DIR}"`, { encoding: 'utf8', timeout: 60000, maxBuffer: 10 * 1024 * 1024 });
      handoffAtualizadoEm = new Date().toISOString();
    } catch (e) {
      bloco += `\nFalha ao atualizar handoff-sessao.md: ${e.message || String(e)}\n`;
    }
  } else if (fs.existsSync(HANDOFF_MD)) {
    handoffAtualizadoEm = fs.statSync(HANDOFF_MD).mtime.toISOString();
  }

  status = {
    diasAtivos: diasSessaoAtiva,
    recomendacao: diasSessaoAtiva >= 3 ? 'compact' : 'ok',
    handoffAtualizadoEm,
    handoffPath: 'auditoria/handoff-sessao.md',
    ultimaMedicaoOk: true,
    erroUltimaMedicao: null,
    erroUltimaMedicaoEm: null
  };

  // AVISO NA TRANSIÇÃO — pedido do dono, 19/08: calcular "compact" sozinho não
  // avisa ninguém. Dispara PushNotification só quando a recomendação MUDA de
  // "ok" pra "compact" (nunca de novo enquanto ficar em "compact" sem antes
  // voltar a "ok" — reinício de sessão zera diasAtivos). Mesmo canal que
  // pesquisa-diaria/run-daily.ps1 já usa (PushNotification, status "proactive"),
  // via `claude -p`, porque a ferramenta só existe dentro de uma execução do
  // Claude Code -- um Code node puro não consegue chamá-la direto.
  if (anterior.recomendacao === 'ok' && status.recomendacao === 'compact') {
    const msg = `Sessao do Claude Code ja soma ${diasSessaoAtiva} dias sem reiniciar -- abra uma conversa nova pro proximo assunto grande.`;
    const prompt = `Envie uma PushNotification (status "proactive") com exatamente este texto, sem markdown: "${msg}". Nao faca mais nada, nao leia arquivo nenhum. Se a ferramenta PushNotification nao estiver disponivel nesta execucao, apenas ignore e nao retorne erro.`;
    try {
      execSync(`claude -p "${prompt.replace(/"/g, '\\"')}" --dangerously-skip-permissions --output-format text`, { encoding: 'utf8', timeout: 120000, maxBuffer: 5 * 1024 * 1024 });
      bloco += `\nAviso de higiene de sessão disparado via PushNotification (transição ok→compact).\n`;
    } catch (e) {
      bloco += `\nFalha ao disparar PushNotification de higiene de sessão: ${e.message || String(e)}\n`;
    }
  }
}

// Escreve SEMPRE -- boa ou ruim, o status reflete o estado real da última tentativa.
fs.writeFileSync(STATUS_PATH, JSON.stringify(status, null, 2), 'utf8');

if (!fs.existsSync(ALERTAS)) {
  fs.writeFileSync(ALERTAS, '# Alertas automáticos — n8n\n\n' + bloco, 'utf8');
} else {
  fs.appendFileSync(ALERTAS, bloco, 'utf8');
}

return [{ json: { erro } }];
