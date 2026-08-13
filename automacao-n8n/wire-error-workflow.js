const fs = require('fs');
const files = [
  'workflow-prazo-vencido.json',
  'workflow-decisao-vencida.json',
  'workflow-trilhas-incompletas.json',
  'workflow-risco-parado.json',
  'workflow-ia-sob-demanda.json',
  'workflow-encoding-quebrado.json',
  'workflow-guardiao-decisao.json'
];
for (const f of files) {
  const wf = JSON.parse(fs.readFileSync(f, 'utf8'));
  wf.settings = wf.settings || {};
  wf.settings.errorWorkflow = 'missionControl00001';
  fs.writeFileSync(f, JSON.stringify(wf, null, 2), 'utf8');
  console.log('wired', f);
}
