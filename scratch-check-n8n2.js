const { DatabaseSync } = require('node:sqlite');
const db = new DatabaseSync('C:\\Users\\usuario\\.n8n\\database.sqlite', { readOnly: true });

const wf = db.prepare("SELECT nodes, settings FROM workflow_entity WHERE id = 'economiaToken000001'").get();
const nodes = JSON.parse(wf.nodes);
const trigger = nodes.find(n => n.type.includes('scheduleTrigger') || n.type.includes('cron'));
console.log('TRIGGER NODE:', JSON.stringify(trigger, null, 2));
console.log('SETTINGS:', wf.settings);

// dados do proprio trigger na ultima execucao real (id 55) -- mostra timezone que a instancia usou de fato
const exec = db.prepare("SELECT data FROM execution_data WHERE executionId = 55").get();
if (exec) {
  const raw = exec.data;
  const idxTz = raw.indexOf('Timezone');
  console.log('trecho perto de Timezone na execucao 55:', idxTz >= 0 ? raw.slice(idxTz - 50, idxTz + 100) : 'nao achado');
}
