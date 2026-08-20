const { DatabaseSync } = require('node:sqlite');
const db = new DatabaseSync('C:\\Users\\usuario\\.n8n\\database.sqlite', { readOnly: true });
const row = db.prepare("SELECT apiKey FROM user_api_keys LIMIT 1").get();
const key = row.apiKey;

fetch('http://localhost:5678/api/v1/workflows/economiaToken000001', {
  headers: { 'X-N8N-API-KEY': key }
}).then(async r => {
  console.log('status', r.status);
  const t = await r.text();
  console.log(t.slice(0, 500));
}).catch(e => console.error('erro', e.message));
