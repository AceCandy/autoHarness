#!/usr/bin/env node

/**
 * Post-Tool-Use Hook
 * 轻量版：记录工具调用痕迹
 */

try {
  const fs = require('fs');
  const path = require('path');

  const rawInput = process.argv[2] || '{}';
  const input = JSON.parse(rawInput);
  const tool = input.tool || 'unknown';
  const projectRoot = process.env.CLAUDE_PROJECT_DIR || process.cwd();
  const logDir = path.join(projectRoot, '.autoharness', 'workspace');

  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }

  const logPath = path.join(logDir, 'tool-usage.log');
  const logEntry = `[${new Date().toISOString()}] 已执行工具: ${tool}\n`;
  fs.appendFileSync(logPath, logEntry);

  process.exit(0);
} catch (e) {
  process.exit(0);
}
