const { DatabaseSync } = require('node:sqlite');
const db = new DatabaseSync('C:\\Users\\usuario\\.n8n\\database.sqlite', { readOnly: true });
try {
  const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%api%'").all();
  console.log('tabelas api:', JSON.stringify(tables));
  for (const t of tables) {
    try {
      const rows = db.prepare(`SELECT * FROM ${t.name} LIMIT 5`).all();
      console.log(t.name, JSON.stringify(rows, null, 2));
    } catch (e) { console.log('erro lendo', t.name, e.message); }
  }
} catch (e) { console.error(e.message); }
