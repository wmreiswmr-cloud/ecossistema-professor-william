const { DatabaseSync } = require('node:sqlite');
const db = new DatabaseSync('C:\\Users\\usuario\\.n8n\\database.sqlite', { readOnly: true });

for (const id of ['trilhasDiariasN8n01', 'auditoriaN8n000001', 'youtubeTrendScout01', 'decisaoRevisaoVencida1']) {
  const wf = db.prepare("SELECT id, name, nodes, settings, updatedAt FROM workflow_entity WHERE id = ?").get(id);
  if (!wf) { console.log(id, 'NAO ENCONTRADO'); continue; }
  const nodes = JSON.parse(wf.nodes);
  const trigger = nodes.find(n => n.type.includes('scheduleTrigger') || n.type.includes('cron'));
  console.log('===', id, wf.name, '| updatedAt', wf.updatedAt, '===');
  console.log('settings:', wf.settings);
  console.log('trigger:', trigger ? JSON.stringify(trigger.parameters) : 'sem trigger de schedule');
}
