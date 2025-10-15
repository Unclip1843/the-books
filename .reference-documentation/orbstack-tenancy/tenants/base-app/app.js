import express from 'express';
import Database from 'better-sqlite3';
import { request } from 'undici';
import fs from 'fs';
import path from 'path';

const app = express();
app.use(express.json({ limit: '5mb' }));

const PORT = 8080;
const USER_ID_HEADER = 'x-user-id';
const dataDir = '/app/data';
const filesDir = (userId) => path.join(dataDir, 'users', userId, 'files');
const historyDbPath = path.join(dataDir, 'db', 'history.db');

function ensureUserDirs(userId) {
  const dir = filesDir(userId);
  fs.mkdirSync(dir, { recursive: true });
}

// Ensure data directory exists before opening database
fs.mkdirSync(dataDir, { recursive: true });
fs.closeSync(fs.openSync(historyDbPath, "a"));

const db = new Database(historyDbPath);
db.pragma('journal_mode = WAL');
db.exec(`CREATE TABLE IF NOT EXISTS conversation_history(
  conversation_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  started_at TEXT NOT NULL,
  ended_at TEXT,
  messages_json TEXT NOT NULL
)`);

app.get('/health', (req, res) => {
  res.json({ ok: true, ts: new Date().toISOString() });
});

function requireUser(req, res) {
  const uid = req.header(USER_ID_HEADER);
  if (!uid) {
    res.status(403).json({ error: 'missing X-User-ID' });
    return null;
  }
  if (req.body && req.body.user_id && req.body.user_id !== uid) {
    res.status(403).json({ error: 'user mismatch' });
    return null;
  }
  return uid;
}

app.post('/chat', async (req, res) => {
  const userId = requireUser(req, res); if (!userId) return;
  ensureUserDirs(userId);

  const { message, conversation_id } = req.body || {};
  if (!message) return res.status(400).json({ error: 'message required' });
  const cid = conversation_id || `c_${Date.now()}`;

  // Simulate LLM reply (replace with real Anthropic/OpenAI client calls)
  const reply = `echo: ${message}`;

  // Append to history
  const row = db.prepare('SELECT messages_json FROM conversation_history WHERE conversation_id = ?').get(cid);
  let messages = row ? JSON.parse(row.messages_json) : [];
  const now = new Date().toISOString();
  messages.push({ role: 'user', content: message, at: now });
  messages.push({ role: 'assistant', content: reply, at: new Date().toISOString() });

  db.prepare(`INSERT INTO conversation_history(conversation_id, user_id, started_at, ended_at, messages_json)
              VALUES(?,?,?,?,?)
              ON CONFLICT(conversation_id) DO UPDATE SET
                ended_at=excluded.ended_at,
                messages_json=excluded.messages_json
            `).run(cid, userId, messages[0].at, messages[messages.length-1].at, JSON.stringify(messages));

  // Write a demo file
  fs.writeFileSync(path.join(filesDir(userId), `note-${Date.now()}.txt`), `You said: ${message}\nReply: ${reply}\n`);

  // Send summary to Supervisor (best effort)
  try {
    const payload = {
      user_id: userId,
      conversation_id: cid,
      started_at: messages[0].at,
      ended_at: messages[messages.length-1].at,
      tokens_in: message.length,
      tokens_out: reply.length,
      cost_usd: 0.00001,
      model: "demo-echo",
      provider: "local",
      message_count: messages.length,
      last_active_at: messages[messages.length-1].at,
      feedback_count: 0,
      error_count: 0,
      flags: { used_files: true, tool_calls: 0 }
    };
    const SUPERVISOR_INGEST = process.env.PUBLIC_BASE_URL
      ? `${process.env.PUBLIC_BASE_URL}/admin/ingest-summary`
      : 'http://gateway:8080/admin/ingest-summary';
    await request(SUPERVISOR_INGEST, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(payload)
    });
  } catch (_) { /* ignore */ }

  res.json({ conversation_id: cid, reply });
});

app.post('/internal/summary', (req, res) => {
  const userId = requireUser(req, res); if (!userId) return;
  res.json(req.body || {});
});

app.listen(PORT, () => console.log(`tenant app on :${PORT}`));
