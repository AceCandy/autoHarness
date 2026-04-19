#!/usr/bin/env node

/**
 * Session End Hook
 * 轻量版：会话结束
 */

try {
  const fs = require('fs');
  const path = require('path');

  const HARNESS_DIR = process.env.CLAUDE_PROJECT_DIR || __dirname;
  const journalsDir = path.join(HARNESS_DIR, 'workspace', 'journals');

  if (!fs.existsSync(journalsDir)) {
    fs.mkdirSync(journalsDir, { recursive: true });
  }

  const today = new Date().toISOString().split('T')[0];
  const journalPath = path.join(journalsDir, `journal-${today}.md`);
  const entry = `\n## ${new Date().toISOString()}\n\nSession ended\n`;

  try {
    fs.appendFileSync(journalPath, entry);
  } catch (e) {
    // 忽略写入错误
  }

  console.log('[AutoHarness] Session ended');
  process.exit(0);
} catch (e) {
  process.exit(0);
}
