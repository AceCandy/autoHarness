#!/usr/bin/env node

/**
 * Post-Tool-Use Hook
 * 轻量版：记录工具使用
 */

try {
  const fs = require('fs');
  const path = require('path');

  const HARNESS_DIR = process.env.CLAUDE_PROJECT_DIR || __dirname;
  const logDir = path.join(HARNESS_DIR, 'workspace');

  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }

  const logPath = path.join(logDir, 'tool-usage.log');
  const logEntry = `[${new Date().toISOString()}] tool executed\n`;
  fs.appendFileSync(logPath, logEntry);

  process.exit(0);
} catch (e) {
  process.exit(0);
}
