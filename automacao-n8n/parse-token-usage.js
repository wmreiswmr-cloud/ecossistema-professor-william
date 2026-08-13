// Le o transcript JSONL da sessao (392MB+) em streaming, linha por linha,
// nunca carrega o arquivo inteiro na memoria de uma vez — soma uso real de
// token por dia. So imprime o resumo agregado, nunca o conteudo cru.
const fs = require('fs');
const readline = require('readline');

const ARQUIVO = process.argv[2];
const SAIDA = process.argv[3];

const porDia = {}; // { '2026-08-09': { input, output, cacheCreate, cacheRead, turnos } }

const rl = readline.createInterface({
  input: fs.createReadStream(ARQUIVO, { encoding: 'utf8' }),
  crlfDelay: Infinity
});

let linhas = 0;
let comUsage = 0;

rl.on('line', (line) => {
  linhas++;
  if (!line.includes('"usage"')) return;
  let obj;
  try { obj = JSON.parse(line); } catch (e) { return; }
  if (obj.type !== 'assistant') return;
  const usage = obj.message && obj.message.usage;
  if (!usage) return;
  comUsage++;
  const dia = (obj.timestamp || '').slice(0, 10);
  if (!dia) return;
  if (!porDia[dia]) porDia[dia] = { input: 0, output: 0, cacheCreate: 0, cacheRead: 0, turnos: 0 };
  porDia[dia].input += usage.input_tokens || 0;
  porDia[dia].output += usage.output_tokens || 0;
  porDia[dia].cacheCreate += usage.cache_creation_input_tokens || 0;
  porDia[dia].cacheRead += usage.cache_read_input_tokens || 0;
  porDia[dia].turnos += 1;
});

rl.on('close', () => {
  const dias = Object.keys(porDia).sort();
  const resultado = { geradoEm: new Date().toISOString(), linhasProcessadas: linhas, mensagensComUsage: comUsage, porDia: {} };
  for (const d of dias) resultado.porDia[d] = porDia[d];
  fs.writeFileSync(SAIDA, JSON.stringify(resultado, null, 2), 'utf8');
  console.log('OK', linhas, 'linhas,', comUsage, 'com usage,', dias.length, 'dias');
});
