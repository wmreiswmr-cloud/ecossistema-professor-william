// Le TODOS os .jsonl do diretorio de sessoes em streaming (nunca carrega arquivo
// inteiro na memoria), soma uso real de token por dia -- agregando entre arquivos
// que caem no mesmo dia, contando em cada arquivo so as mensagens daquele dia (um
// arquivo que atravessa varios dias contribui pra cada dia separadamente, nunca
// joga o arquivo inteiro num dia so). Tambem agrega por sessao (arquivo), com uma
// classificacao automacao x interativa. So imprime o resumo agregado, nunca o
// conteudo cru.
//
// Uso: node parse-token-usage.js <DIRETORIO_DE_SESSOES> <SAIDA.json>
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const DIR = process.argv[2];
const SAIDA = process.argv[3];

// ponytail: heuristica de classificacao automacao x interativa = contagem de
// turnos "assistant" no arquivo inteiro. Conferido em 19/08 contra os arquivos
// reais do projeto: toda execucao -p single-shot conhecida (run-daily.ps1,
// auditoria-diaria.ps1, run-reuniao.ps1) ficou em 1-14 turnos; toda sessao
// interativa real ficou em 16+ (a mais curta observada teve 16, a mais longa
// 10.277). Teto pra cima do gargalo, com folga. Se surgir automacao nova com mais
// turnos, subir TETO_TURNOS_AUTOMACAO aqui -- nao inventar segunda heuristica.
const TETO_TURNOS_AUTOMACAO = 20;

function novoAcumulador() {
  return { input: 0, output: 0, cacheCreate: 0, cacheRead: 0, turnos: 0 };
}

async function processarArquivo(caminho) {
  let linhas = 0;
  let comUsage = 0;
  let turnos = 0;
  const totalSessao = novoAcumulador();
  const porDiaArquivo = {};

  const rl = readline.createInterface({
    input: fs.createReadStream(caminho, { encoding: 'utf8' }),
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    linhas++;
    if (!line.includes('"usage"')) continue;
    let obj;
    try { obj = JSON.parse(line); } catch (e) { continue; }
    if (obj.type !== 'assistant') continue;
    const usage = obj.message && obj.message.usage;
    if (!usage) continue;
    const dia = (obj.timestamp || '').slice(0, 10);
    if (!dia) continue;
    comUsage++;
    turnos++;

    const i = usage.input_tokens || 0;
    const o = usage.output_tokens || 0;
    const cc = usage.cache_creation_input_tokens || 0;
    const cr = usage.cache_read_input_tokens || 0;

    totalSessao.input += i;
    totalSessao.output += o;
    totalSessao.cacheCreate += cc;
    totalSessao.cacheRead += cr;
    totalSessao.turnos += 1;

    if (!porDiaArquivo[dia]) porDiaArquivo[dia] = novoAcumulador();
    porDiaArquivo[dia].input += i;
    porDiaArquivo[dia].output += o;
    porDiaArquivo[dia].cacheCreate += cc;
    porDiaArquivo[dia].cacheRead += cr;
    porDiaArquivo[dia].turnos += 1;
  }

  return { linhas, comUsage, turnos, totalSessao, porDiaArquivo };
}

async function main() {
  const arquivos = fs.readdirSync(DIR).filter(f => f.endsWith('.jsonl'));
  const porDia = {};
  const porSessao = {};
  let linhasProcessadas = 0;
  let mensagensComUsage = 0;

  for (const f of arquivos) {
    const full = path.join(DIR, f);
    const { linhas, comUsage, turnos, totalSessao, porDiaArquivo } = await processarArquivo(full);
    linhasProcessadas += linhas;
    mensagensComUsage += comUsage;
    if (turnos === 0) continue; // sessao sem nenhum turno medido (ex: abortada antes da 1a resposta)

    for (const [dia, v] of Object.entries(porDiaArquivo)) {
      if (!porDia[dia]) porDia[dia] = novoAcumulador();
      porDia[dia].input += v.input;
      porDia[dia].output += v.output;
      porDia[dia].cacheCreate += v.cacheCreate;
      porDia[dia].cacheRead += v.cacheRead;
      porDia[dia].turnos += v.turnos;
    }

    porSessao[f] = {
      turnos,
      input: totalSessao.input,
      output: totalSessao.output,
      cacheCreate: totalSessao.cacheCreate,
      cacheRead: totalSessao.cacheRead,
      total: totalSessao.input + totalSessao.output + totalSessao.cacheCreate + totalSessao.cacheRead,
      dias: Object.keys(porDiaArquivo).sort(),
      tipo: turnos <= TETO_TURNOS_AUTOMACAO ? 'automacao' : 'interativa',
      mtime: fs.statSync(full).mtime.toISOString()
    };
  }

  const dias = Object.keys(porDia).sort();
  const resultado = {
    geradoEm: new Date().toISOString(),
    arquivosProcessados: arquivos.length,
    linhasProcessadas,
    mensagensComUsage,
    porDia: {},
    porSessao
  };
  for (const d of dias) resultado.porDia[d] = porDia[d];

  fs.writeFileSync(SAIDA, JSON.stringify(resultado, null, 2), 'utf8');
  console.log('OK', arquivos.length, 'arquivos,', linhasProcessadas, 'linhas,', mensagensComUsage, 'com usage,', dias.length, 'dias');
}

main().catch(e => { console.error('ERRO', e); process.exit(1); });
