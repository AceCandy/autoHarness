#!/usr/bin/env node

/**
 * Session Start Hook
 * 轻量版：只做上下文存在性提示
 */

try {
  const fs = require('fs');
  const path = require('path');

  const projectRoot = process.env.CLAUDE_PROJECT_DIR || process.cwd();

  const checkFile = (file) => {
    try {
      return fs.existsSync(path.join(projectRoot, file));
    } catch {
      return false;
    }
  };

  const hasProject = checkFile('.autoharness/project.md');
  const hasWorkspace = checkFile('.autoharness/workspace');

  if (hasProject || hasWorkspace) {
    console.log('[AutoHarness] 已检测到项目上下文');
  }

  process.exit(0);
} catch (e) {
  process.exit(0);
}
