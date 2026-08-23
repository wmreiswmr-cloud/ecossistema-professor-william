#!/usr/bin/env node
// Poka-yoke do formato do quadro: acha linha de item MALFORMADA antes que ela
// suma em silencio do painel.
//
// Causa real (22/08): o item #112 foi escrito com 6 celulas em vez de 7 -- a
// coluna "Prova de que resolveu" ficou fundida dentro da celula de Status. O
// parser exige >=7 celulas, entao descartava a linha inteira sem erro nenhum.
// Item fechado, invisivel, e ninguem notaria. Se tivesse acontecido num item
// ABERTO, o quadro perderia um problema real de vista.
//
// Nao basta "escrever com cuidado" -- isso e paliativo, depende de lembrar.
// Isto aqui torna o erro detectavel: roda, e falha alto quando aparece.
//
// Uso: node auditoria/valida-quadro.js   (exit 1 se achar malformada)

const fs = require('fs');
const path = require('path');

const QUADRO = path.join(__dirname, 'problemas.md');

// Tabelas historicas que TEM 6 celulas de proposito (sem coluna Status) --
// nao sao defeito, sao formato antigo preservado.
//
// ponytail: a 1a versao isentava por INTERVALO DE LINHA e quebrou no mesmo dia
// -- o arquivo cresceu 20 linhas e as isencoes passaram a apontar pro lugar
// errado, acusando 13 falsos positivos. Numero de linha e posicao, e posicao
// muda a cada edicao. Agora a isencao olha o CABECALHO da tabela em que a
// linha vive: cabecalho SEM a coluna "Status" = formato antigo, isento por
// desenho. Isso sobrevive a qualquer deslocamento do arquivo.
//
// Encontra o cabecalho de tabela markdown mais proximo ACIMA da linha dada.
function cabecalhoDe(lines, idx) {
  // ponytail: NAO para na primeira linha de prosa. Tabela deste arquivo quebra
  // em linha vazia + paragrafo e continua depois com linha orfa sem cabecalho
  // novo -- e o caso (b) do #111, onde as orfas eram justamente os itens que
  // sumiam. Parar na prosa isentava exatamente quem precisava ser checado
  // (confirmado por teste: linha malformada plantada passou despercebida).
  // Sobe ate achar um cabecalho de tabela ou o inicio do arquivo.
  for (let i = idx; i >= 0; i--) {
    const l = lines[i].trim();
    if (!l.startsWith('|')) continue;
    if (/^\|\s*#\s*\|/.test(l) || /^\|\s*Problema\s*\|/.test(l)) return l;
  }
  return null;
}

// So a TABELA DE PROBLEMA precisa das 7 colunas. Isento todo o resto.
// Duas coisas legitimamente diferentes moram neste arquivo com 6 colunas:
//   - "03/08 tabela de ontem"  -> | # | Problema | ... | SEM coluna Status (formato antigo)
//   - "Recorrente"             -> | # | Tarefa   | ... | e manutencao agendada, nao problema
// A regra positiva (so valido o que declara Problema E Status) cobre as duas
// sem precisar listar nenhuma delas -- tabela nova de outro tipo tambem nasce
// isenta sozinha, sem ninguem lembrar de vir aqui atualizar lista.
function isenta(lines, idx) {
  const head = cabecalhoDe(lines, idx);
  if (head === null) { return 'fora de tabela com cabecalho reconhecivel'; }
  const ehTabelaDeProblema = /\|\s*Problema\s*\|/.test(head) && /\|\s*Status\s*\|/.test(head);
  return ehTabelaDeProblema ? null : 'nao e a tabela de problema (cabecalho: ' + head.slice(0, 60) + ')';
}

function main() {
  const lines = fs.readFileSync(QUADRO, 'utf8').split(/\r?\n/);
  const ruins = [];

  lines.forEach((line, i) => {
    const nLinha = i + 1;
    if (!/^\|\s*~*\s*\d+\s*\|/.test(line.trim())) return;
    // mesma fuga de "\|" escapado que o painel usa (achado #111)
    const cells = line.split(/(?<!\\)\|/).slice(1, -1).map(c => c.trim());
    if (cells.length >= 7) return;
    if (isenta(lines, i)) return;
    ruins.push({ linha: nLinha, id: cells[0].replace(/[~\s*]/g, ''), celulas: cells.length });
  });

  if (ruins.length === 0) {
    console.log('OK — nenhuma linha de item malformada em ' + path.basename(QUADRO) + '.');
    console.log('(linhas de 6 celulas em tabela SEM coluna Status sao isentas por desenho -- isencao por cabecalho, nao por numero de linha.)');
    return;
  }

  console.error('DEFEITO: ' + ruins.length + ' linha(s) de item seriam descartadas em silencio pelo painel:\n');
  ruins.forEach(r => {
    console.error('  linha ' + r.linha + ' -> item #' + r.id + ' tem ' + r.celulas + ' celulas (precisa de 7)');
  });
  console.error('\nCada linha precisa de: | # | Problema | Origem | Dono | Prazo | Status | Prova |');
  console.error('Causa comum: a coluna Prova ficou fundida dentro da celula de Status (faltou um "|").');
  process.exit(1);
}

main();
