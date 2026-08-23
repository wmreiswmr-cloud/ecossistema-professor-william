// Teste do validador contra 3 casos de resposta CONHECIDA (Armadilha 6).
// Roda o valida-quadro.js de verdade contra copias temporarias do quadro.
const fs = require('fs');
const { execFileSync } = require('child_process');
const path = require('path');

const RAIZ = 'C:/Users/usuario/Desktop/Projeto-professor-William';
const QUADRO = path.join(RAIZ, 'auditoria/problemas.md');
const VALIDADOR = path.join(RAIZ, 'auditoria/valida-quadro.js');
const original = fs.readFileSync(QUADRO, 'utf8');

function roda() {
  try { execFileSync('node', [VALIDADOR], { stdio: 'pipe' }); return 0; }
  catch (e) { return e.status; }
}

const casos = [
  { nome: 'quadro real, sem defeito', muta: t => t, esperado: 0 },
  { nome: 'linha malformada orfa no fim', muta: t => t + '\n| 999 | orfao | o | d | p | s |\n', esperado: 1 },
  {
    nome: 'linha malformada DENTRO da tabela de problema',
    muta: t => {
      const linhas = t.split(/\r?\n/);
      // acha a 1a linha de item numerico logo abaixo de um cabecalho de Problema+Status
      let alvo = -1;
      for (let i = 0; i < linhas.length && alvo < 0; i++) {
        if (/\|\s*Problema\s*\|/.test(linhas[i]) && /\|\s*Status\s*\|/.test(linhas[i])) {
          for (let j = i + 2; j < linhas.length; j++) {
            if (/^\|\s*\d+\s*\|/.test(linhas[j].trim())) { alvo = j; break; }
          }
        }
      }
      if (alvo < 0) throw new Error('nao achei tabela de problema pra mutar');
      linhas.splice(alvo + 1, 0, '| 998 | dentro da tabela | o | d | p | s |');
      return linhas.join('\n');
    },
    esperado: 1,
  },
];

let falhas = 0;
try {
  for (const c of casos) {
    fs.writeFileSync(QUADRO, c.muta(original), 'utf8');
    const got = roda();
    const ok = got === c.esperado;
    if (!ok) falhas++;
    console.log((ok ? 'PASSOU' : 'FALHOU') + ' — ' + c.nome + ' (esperado exit ' + c.esperado + ', veio ' + got + ')');
  }
} finally {
  fs.writeFileSync(QUADRO, original, 'utf8');
  console.log('\nquadro restaurado ao original (' + original.length + ' bytes)');
}
process.exit(falhas === 0 ? 0 : 1);
