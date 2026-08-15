// Migra as 4 rotinas diarias (trilhas, quadro GUT, CEO-Integrador, auditoria)
// de Tarefa Agendada do Windows para workflow n8n, por ordem direta do dono,
// 2026-08-14: "nao quero nada de tarefa agendada no ecossistema quero
// automacao via n8n". Estrategia: n8n vira so o GATILHO/agendador -- os
// scripts .ps1 continuam sendo a fonte real de verdade (evita reescrever em
// JS os 500+ linhas de logica ja testada e cheia de bug corrigido de
// auditoria-diaria.ps1; reescrever isso seria reintroduzir os mesmos bugs
// documentados no proprio arquivo). Cada workflow so chama
// `powershell.exe -File <script>.ps1` via execSync.
const fs = require('fs');
const path = require('path');

function montarNode(caminhoScript, timeoutMs, argsExtra) {
  const args = argsExtra ? ` ${argsExtra}` : '';
  // Achados reais de hoje (14/08), nesta ordem:
  // 1. execSync bloqueia o processo inteiro do JS Task Runner do n8n -- pra
  //    script que chama o claude CLI e demora minutos, o proprio runner e
  //    derrubado pelo watchdog de responsividade ("Task execution aborted
  //    because runner became unresponsive"). Fix: exec assincrono
  //    (callback -> Promise) + await.
  // 2. "powershell.exe -File script.ps1" nesse mesmo caminho (n8n -> Node
  //    child_process, nao Tarefa Agendada) le o .ps1 com o codepage errado
  //    mesmo o arquivo tendo BOM UTF-8 -- corrompe emoji/acento usado como
  //    SINTAXE do proprio PowerShell (ex: `Alerta '🟡' "..."`), gerando erro
  //    de parse real ("')' de fechamento ausente"). Fix: nunca usar -File;
  //    usar -EncodedCommand (Base64 de UTF-16LE), a forma oficial do
  //    PowerShell de receber comando sem ambiguidade de encoding.
  const scriptCall = `& '${caminhoScript.replace(/'/g, "''")}'${args}`;
  const encodedCommand = Buffer.from(scriptCall, 'utf16le').toString('base64');
  const jsCode = `const { exec } = require('child_process');

function rodar(cmd, timeoutMs) {
  return new Promise((resolve) => {
    exec(cmd, { encoding: 'utf8', timeout: timeoutMs, maxBuffer: 20 * 1024 * 1024 }, (err, stdout, stderr) => {
      resolve({ err, stdout, stderr });
    });
  });
}

const cmd = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand ' + ${JSON.stringify(encodedCommand)};
const { err, stdout } = await rodar(cmd, ${timeoutMs});

// Guarda-corpo (BL-030, parcial): erro real do script nunca vira sucesso
// silencioso -- lanca de verdade, pro errorWorkflow (Mission Control)
// registrar em alertas-automaticos.md de forma visivel.
if (err) {
  throw new Error('Falha ao rodar ' + ${JSON.stringify(caminhoScript)} + ': ' + (err.message || String(err)));
}

return [{ json: { saidaResumo: String(stdout).trim().slice(-2000) } }];
`;
  return jsCode;
}

function montarWorkflow({ id, name, caminhoScript, timeoutMs, hora, minuto, argsExtra }) {
  const nomeGatilho = `Todo dia ${String(hora).padStart(2, '0')}:${String(minuto).padStart(2, '0')}`;
  return {
    id,
    name,
    nodes: [
      {
        parameters: { rule: { interval: [{ field: 'days', triggerAtHour: hora, triggerAtMinute: minuto }] } },
        id: 'trigger-schedule',
        name: nomeGatilho,
        type: 'n8n-nodes-base.scheduleTrigger',
        typeVersion: 1.2,
        position: [240, 200]
      },
      {
        parameters: {},
        id: 'trigger-manual',
        name: 'Rodar agora (teste)',
        type: 'n8n-nodes-base.manualTrigger',
        typeVersion: 1,
        position: [240, 380]
      },
      {
        parameters: { mode: 'runOnceForAllItems', jsCode: montarNode(caminhoScript, timeoutMs, argsExtra) },
        id: 'code-rodar-script',
        name: 'Rodar script PowerShell',
        type: 'n8n-nodes-base.code',
        typeVersion: 2,
        position: [480, 290]
      }
    ],
    connections: {
      [nomeGatilho]: { main: [[{ node: 'Rodar script PowerShell', type: 'main', index: 0 }]] },
      'Rodar agora (teste)': { main: [[{ node: 'Rodar script PowerShell', type: 'main', index: 0 }]] }
    },
    active: true,
    settings: { errorWorkflow: 'missionControl00001' }
  };
}

const BASE = 'c:\\Users\\usuario\\Desktop\\Projeto-professor-William\\';

const workflows = [
  {
    file: 'workflow-trilhas-diarias.json',
    def: montarWorkflow({
      id: 'trilhasDiariasN8n01',
      name: 'Trilhas Diárias — cerebro-analista-mercado (n8n)',
      caminhoScript: BASE + 'pesquisa-diaria\\run-daily.ps1',
      timeoutMs: 40 * 60 * 1000,
      hora: 13,
      minuto: 20
    })
  },
  {
    file: 'workflow-quadro-gut-diario.json',
    def: montarWorkflow({
      id: 'quadroGutN8n0001',
      name: 'Quadro de Ações — Classificação GUT (n8n)',
      caminhoScript: BASE + 'auditoria\\quadro-diario.ps1',
      timeoutMs: 15 * 60 * 1000,
      hora: 22,
      minuto: 20
    })
  },
  {
    file: 'workflow-integrador-diario.json',
    def: montarWorkflow({
      id: 'integradorN8n00001',
      name: 'CEO-Integrador — Health Check (n8n)',
      caminhoScript: BASE + 'auditoria\\integrador-diario.ps1',
      timeoutMs: 15 * 60 * 1000,
      hora: 22,
      minuto: 40
    })
  },
  {
    file: 'workflow-auditoria-diaria.json',
    def: montarWorkflow({
      id: 'auditoriaN8n000001',
      name: 'Auditoria Diária do Ecossistema (n8n)',
      caminhoScript: BASE + 'auditoria\\auditoria-diaria.ps1',
      timeoutMs: 15 * 60 * 1000,
      hora: 22,
      minuto: 0
    })
  }
];

for (const wf of workflows) {
  fs.writeFileSync(path.join(BASE, 'automacao-n8n', wf.file), JSON.stringify(wf.def, null, 2), 'utf8');
  console.log('escrito', wf.file);
}
