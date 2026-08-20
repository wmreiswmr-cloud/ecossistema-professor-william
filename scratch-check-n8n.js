const { DatabaseSync } = require('node:sqlite');
const db = new DatabaseSync('C:\\Users\\usuario\\.n8n\\database.sqlite', { readOnly: true });

const wf = db.prepare("SELECT id, name, active FROM workflow_entity WHERE id = 'economiaToken000001' OR name LIKE '%conomia%oken%'").all();
console.log('WORKFLOW:', JSON.stringify(wf, null, 2));

const execs = db.prepare("SELECT id, mode, status, startedAt, stoppedAt, finished FROM execution_entity WHERE workflowId = 'economiaToken000001' ORDER BY startedAt DESC LIMIT 15").all();
console.log('EXECUCOES:', JSON.stringify(execs, null, 2));
