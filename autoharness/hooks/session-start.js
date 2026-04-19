#!/usr/bin/env node

/**
 * Session Start Hook
 * 轻量版：只做基础初始化，不尝试加载大量文件
 */

try {
  const fs = require('fs');
  const path = require('path');

  const HARNESS_DIR = process.env.CLAUDE_PROJECT_DIR || __dirname;

  // 简单检查关键文件是否存在
  const checkFile = (file) => {
    try {
      return fs.existsSync(path.join(HARNESS_DIR, file));
    } catch {
      return false;
    }
  };

  const hasProject = checkFile('.autoharness/project.md');
  const hasWorkspace = checkFile('.autoharness/workspace');

  if (hasProject || hasWorkspace) {
    console.log('[AutoHarness] Session started with project context');
  }

  process.exit(0);
} catch (e) {
  process.exit(0);
}
