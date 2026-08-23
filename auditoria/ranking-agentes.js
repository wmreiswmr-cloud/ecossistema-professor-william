#!/usr/bin/env node
// Conta despachos REAIS de subagente (Task/Agent) por especialista, lendo os
// transcripts de sessao do Claude Code. Evidencia crua, nunca autodeclaracao:
// so conta o que aparece como "subagent_type" numa chamada de ferramenta real.
//
// Nasceu do achado de 22/08 (decisoes.md): metade do time nomeado nunca tinha
// sido despachada de verdade -- so narrada em prosa. Sem este medidor, "o time
// esta atuando" e opiniao. Com ele, e numero auditavel.
//
// Uso: node auditoria/ranking-agentes.js
// Escreve: auditoria/ranking-agentes.json (lido pelo painel VS Code)

const fs = require('fs');
const path = require('path');
const os = require('os');

const PROJETO = 'c--Users-usuario-Desktop-Projeto-professor-William';
const SESSOES = path.join(os.homedir(), '.claude', 'projects', PROJETO);
const SAIDA = path.join(__dirname, 'ranking-agentes.json');

// Nome de guerra -> id do agente. Fonte: processo-empresa.md, "Squads nomeados
// por celula". Padrao do dono (22/08): Nome Funcao (cerebro-id).
const NOMES = {
  'cerebro-ecossistema': 'Ricardo Diretor',
  'cerebro-brand-director': 'Bianca Marca',
  'cerebro-brand-scout': 'Sara Referência',
  'cerebro-ux-research': 'Úrsula Jornada',
  'cerebro-design-pro': 'Diego Design',
  'cerebro-motion-designer': 'Marco Motion',
  'cerebro-design-system-manager': 'Sofia Sistema',
  'cerebro-component-library-manager': 'Caio Componente',
  'cerebro-reverse-engineering': 'Rafael Engenharia',
  'cerebro-product-architect': 'Paulo Produto',
  'cerebro-automacao': 'Alan Automação',
  'cerebro-performance': 'Pedro Performance',
  'cerebro-saas': 'Sandra SaaS',
  'cerebro-dominios': 'Diana Domínio',
  'ceo-orquestrador': 'Otávio Orquestrador',
  'ceo-orquestrador-agencia': 'Otávio Agência',
  'cerebro-social-media': 'Sônia Social',
  'cerebro-copywriter': 'Carla Copy',
  'cerebro-gerador-criativos': 'Gustavo Criativo',
  'cerebro-trafego': 'Tiago Tráfego',
  'cerebro-funil': 'Fábio Funil',
  'cerebro-vendas': 'Vera Vendas',
  'cerebro-seo': 'Selma SEO',
  'cerebro-growth-hacker': 'Gabriel Growth',
  'cerebro-analista-mercado-agencia': 'Ana Mercado',
  'cerebro-financeiro': 'Felipe Financeiro',
  'cerebro-analiseusuario': 'Alice Análise',
  'cerebro-branding': 'Breno Branding',
  'cerebro-reitor': 'Rodolfo Reitor',
  'cerebro-knowledge-architect': 'Karina Conhecimento',
  'cerebro-analista-mercado': 'Marcelo Pesquisa',
  'cerebro-memoria-solucao': 'Mila Memória',
  'cerebro-analisador': 'Adriano Diagnóstico',
  'cerebro-analista-pro': 'Priscila Arquitetura',
  'cerebro-secretario': 'Sérgio Secretário',
  'cerebro-sentinela': 'Sandro Sentinela',
  'cerebro-integrador': 'Igor Integrador',
  'cerebro-qualidade': 'Queila Qualidade',
  'cerebro-editor-in-chief': 'Eduardo Editorial',
  'cerebro-accessibility': 'Alba Acessibilidade',
  'cerebro-qa-automation': 'Quirino QA',
  'cerebro-design-critic': 'Clara Crítica',
  'cerebro-empreendedor': 'Elias Empreendedor',
  'cerebro-claude-os': 'Cleo Capacidades',
};

const CELULAS = {
  'Marca & Produto': ['cerebro-brand-director', 'cerebro-brand-scout', 'cerebro-ux-research',
    'cerebro-design-pro', 'cerebro-motion-designer', 'cerebro-design-system-manager',
    'cerebro-component-library-manager', 'cerebro-reverse-engineering'],
  'Engenharia': ['cerebro-product-architect', 'cerebro-automacao', 'cerebro-performance',
    'cerebro-saas', 'cerebro-dominios'],
  'Mercado & Receita': ['ceo-orquestrador', 'ceo-orquestrador-agencia', 'cerebro-social-media',
    'cerebro-copywriter', 'cerebro-gerador-criativos', 'cerebro-trafego', 'cerebro-funil',
    'cerebro-vendas', 'cerebro-seo', 'cerebro-growth-hacker', 'cerebro-analista-mercado-agencia',
    'cerebro-financeiro', 'cerebro-analiseusuario', 'cerebro-branding'],
  'Conhecimento & Operação': ['cerebro-reitor', 'cerebro-knowledge-architect',
    'cerebro-analista-mercado', 'cerebro-memoria-solucao', 'cerebro-analisador',
    'cerebro-analista-pro'],
  'Gestão': ['cerebro-ecossistema', 'cerebro-secretario', 'cerebro-sentinela',
    'cerebro-integrador', 'cerebro-qualidade', 'cerebro-claude-os', 'cerebro-empreendedor'],
  'Auditoria': ['cerebro-design-critic', 'cerebro-accessibility', 'cerebro-qa-automation',
    'cerebro-editor-in-chief'],
};

function celulaDe(id) {
  for (const [nome, ids] of Object.entries(CELULAS)) if (ids.includes(id)) return nome;
  return 'Sem célula';
}

function main() {
  if (!fs.existsSync(SESSOES)) {
    console.error('Diretorio de sessoes nao encontrado: ' + SESSOES);
    process.exit(1);
  }

  const arquivos = fs.readdirSync(SESSOES).filter(f => f.endsWith('.jsonl'));
  const contagem = {};   // id -> total de despachos
  const ultimaVez = {};  // id -> timestamp ISO mais recente

  // ponytail: regex sobre a linha crua em vez de JSON.parse por linha -- os
  // .jsonl somam centenas de MB e o que precisamos e um campo so. Se o formato
  // do transcript mudar, o self-check abaixo (total 0) denuncia na hora.
  const reAgente = /"subagent_type":"([a-zA-Z0-9_-]+)"/g;
  const reData = /"timestamp":"([^"]+)"/;

  for (const arq of arquivos) {
    const linhas = fs.readFileSync(path.join(SESSOES, arq), 'utf8').split('\n');
    for (const linha of linhas) {
      if (!linha.includes('subagent_type')) continue;
      const data = (linha.match(reData) || [])[1] || '';
      let m;
      reAgente.lastIndex = 0;
      while ((m = reAgente.exec(linha)) !== null) {
        const id = m[1];
        if (!NOMES[id]) continue; // ignora Explore/general-purpose/etc
        contagem[id] = (contagem[id] || 0) + 1;
        if (data && (!ultimaVez[id] || data > ultimaVez[id])) ultimaVez[id] = data;
      }
    }
  }

  const ranking = Object.keys(NOMES).map(id => ({
    id,
    nome: NOMES[id],
    rotulo: NOMES[id] + ' (' + id + ')',
    celula: celulaDe(id),
    despachos: contagem[id] || 0,
    ultimaVez: ultimaVez[id] || null,
  })).sort((a, b) => b.despachos - a.despachos || a.nome.localeCompare(b.nome));

  const ativos = ranking.filter(r => r.despachos > 0).length;
  const total = ranking.reduce((s, r) => s + r.despachos, 0);

  const saida = {
    geradoEm: new Date().toISOString(),
    sessoesLidas: arquivos.length,
    totalDespachos: total,
    agentesAtivos: ativos,
    agentesNunca: ranking.length - ativos,
    ranking,
  };

  fs.writeFileSync(SAIDA, JSON.stringify(saida, null, 2), 'utf8');

  console.log('Sessoes lidas: ' + arquivos.length);
  console.log('Despachos reais: ' + total);
  console.log('Agentes que ja atuaram: ' + ativos + ' de ' + ranking.length);
  console.log('Nunca despachados: ' + (ranking.length - ativos));
  console.log('\nTop 10:');
  ranking.slice(0, 10).forEach((r, i) => {
    console.log('  ' + (i + 1) + '. ' + r.rotulo + ' -- ' + r.despachos + ' (' + r.celula + ')');
  });
  console.log('\nEscrito em: ' + SAIDA);

  if (total === 0) {
    console.error('\nALERTA: zero despachos contados. Ou o formato do transcript mudou, ou o caminho esta errado. Nao confie neste resultado.');
    process.exit(2);
  }
}

main();
