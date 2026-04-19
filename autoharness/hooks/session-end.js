#!/usr/bin/env node

/**
 * Session End Hook
 * 轻量版：记录会话结束时间
 */

try {
  const fs = require('fs');
  const path = require('path');

  const projectRoot = process.env.CLAUDE_PROJECT_DIR || process.cwd();
  const journalsDir = path.join(projectRoot, '.autoharness', 'workspace', 'journals');

  if (!fs.existsSync(journalsDir)) {
    fs.mkdirSync(journalsDir, { recursive: true });
  }

  const today = new Date().toISOString().split('T')[0];
  const journalPath = path.join(journalsDir, `journal-${today}.md`);
  const entry = `\n## ${new Date().toISOString()}\n\n会话结束\n`;

  try {
    fs.appendFileSync(journalPath, entry);
  } catch (e) {
    // 忽略写入错误
  }

  console.log('[AutoHarness] 会话已结束');
  process.exit(0);
} catch (e) {
  process.exit(0);
}
