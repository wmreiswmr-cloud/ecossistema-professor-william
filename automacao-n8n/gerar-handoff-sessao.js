// Le os arquivos reais de estado do projeto (evolution-backlog, problemas, decisoes,
// projetos, riscos, em auditoria/) e gera um brief compacto de continuidade —
// pra uma sessao NOVA comecar "fria" sem reprocessar o historico gigante da anterior.
// Nunca inventa conteudo: so extrai e resume o que ja esta escrito nesses arquivos.
// Nao reduz o custo da sessao atual — so a friccao de comecar a proxima.
const fs = require('fs');
const path = require('path');

const AUDITORIA_DIR = process.argv[2] || 'C:\\Users\\usuario\\Desktop\\Projeto-professor-William\\auditoria';
const SAIDA = process.argv[3] || path.join(AUDITORIA_DIR, 'handoff-sessao.md');

function ler(nome) {
  const p = path.join(AUDITORIA_DIR, nome);
  return fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : '';
}

// Marcador de item ABERTO — convenção já usada nesses arquivos (nunca inventada aqui).
const ABERTO = /(⏳|🔒|`BACKLOG`|`READY`|`ASSIGNED`|`IN_PROGRESS`|`NEEDS_REVISION`|\*\(pendente)/;

// Linha de tabela markdown que sinaliza item aberto: começa com "|", não é linha
// separadora (---|---), não contém "✅" (convenção: resolvido sempre carrega check).
function linhasAbertas(conteudo) {
  return conteudo.split('\n').filter((l) => {
    const linha = l.trim();
    if (!linha.startsWith('|')) return false;
    if (linha.replace(/[|\s:-]/g, '') === '') return false;
    if (linha.includes('✅')) return false;
    return ABERTO.test(linha);
  });
}

// evolution-backlog.md: tabela única e regular (8 colunas fixas) — parse real por coluna.
function backlogAberto() {
  const linhas = ler('evolution-backlog.md').split('\n').filter((l) => l.trim().startsWith('| BL-'));
  const abertos = [];
  for (const l of linhas) {
    const cols = l.split('|').map((c) => c.trim());
    const [, id, titulo, , prioridade, status, responsavel, prazo] = cols;
    if (status !== 'DONE') {
      abertos.push(`- **${id}** (${prioridade}, ${status}) ${titulo} — ${responsavel}, prazo ${prazo}`);
    }
  }
  return abertos;
}

// projetos.md: 2 tabelas curtas por projeto, já compactas — incluir a seção inteira.
function projetosAtivos() {
  const conteudo = ler('projetos.md');
  return conteudo
    .split(/\n(?=## PROJ-)/)
    .filter((s) => s.startsWith('## PROJ-'))
    .map((s) => s.split('\n---')[0].trim());
}

function riscosAbertos() {
  return linhasAbertas(ler('riscos.md'));
}
function decisoesPendentes() {
  return linhasAbertas(ler('decisoes.md'));
}
function problemasAbertos() {
  return linhasAbertas(ler('problemas.md'));
}

const agora = new Date();
const pad = (n) => String(n).padStart(2, '0');
const dataStr = `${agora.getFullYear()}-${pad(agora.getMonth() + 1)}-${pad(agora.getDate())}`;
const horaStr = `${pad(agora.getHours())}:${pad(agora.getMinutes())}`;

const projetos = projetosAtivos();
const backlog = backlogAberto();
const riscos = riscosAbertos();
const decisoes = decisoesPendentes();
const problemas = problemasAbertos();

let md = `# Handoff de Sessão — gerado ${dataStr} ${horaStr}\n\n`;
md += `Gerado automaticamente a partir dos arquivos reais de \`auditoria/\` (evolution-backlog.md, problemas.md, decisoes.md, projetos.md, riscos.md) — nunca de memória. Objetivo: uma conversa NOVA começar por aqui em vez de reprocessar o histórico da sessão anterior.\n\n`;
md += `**O que isto resolve, e o que não resolve:** reduz a FRICÇÃO de reiniciar sessão (não precisa reexplicar tudo). Não reduz o custo de token da sessão atual em andamento — a redução real só acontece na PRÓXIMA sessão, que herda este resumo em vez do histórico completo.\n\n`;
md += `---\n\n`;

md += `## Projetos ativos (${projetos.length})\n\n`;
md += (projetos.length ? projetos.join('\n\n') : '_nenhum projeto encontrado em projetos.md_') + '\n\n';

md += `## Backlog aberto — evolution-backlog.md (${backlog.length} itens não-DONE)\n\n`;
md += (backlog.length ? backlog.join('\n') : '_nenhum item aberto_') + '\n\n';

md += `## Riscos abertos — riscos.md (${riscos.length})\n\n`;
md += (riscos.length ? riscos.join('\n\n') : '_nenhum risco aberto_') + '\n\n';

md += `## Decisões pendentes de revisão — decisoes.md (${decisoes.length})\n\n`;
md += (decisoes.length ? decisoes.join('\n\n') : '_nenhuma decisão pendente_') + '\n\n';

md += `## Problemas abertos — problemas.md (${problemas.length} linhas)\n\n`;
md += (problemas.length ? problemas.join('\n\n') : '_nenhum problema aberto encontrado_') + '\n\n';

fs.writeFileSync(SAIDA, md, 'utf8');
console.log(
  'OK', 'projetos:', projetos.length,
  'backlog:', backlog.length,
  'riscos:', riscos.length,
  'decisoes:', decisoes.length,
  'problemas:', problemas.length,
  '->', SAIDA
);
