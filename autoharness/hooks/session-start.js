#!/usr/bin/env node

/**
 * Session Start Hook
 * 轻量版：做上下文存在性提示，并提醒仍需人工补充的文件
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

  const readFile = (file) => {
    try {
      return fs.readFileSync(path.join(projectRoot, file), 'utf8');
    } catch {
      return '';
    }
  };

  const templateChecks = [
    {
      file: '.autoharness/project.md',
      required: true,
      summary: '项目概览、技术栈、启动/测试/构建入口',
      markers: ['- 项目名称:', '- 当前阶段:', '- 语言:', '- 本地启动:', '- 测试命令:'],
    },
    {
      file: '.autoharness/knowledge/business.md',
      required: true,
      summary: '业务背景、核心实体、关键流程',
      markers: ['- 目标:', '- 用户:', '- 实体 1:', '1. \n2. \n3. '],
    },
    {
      file: '.autoharness/knowledge/rules.md',
      required: true,
      summary: '隐形条件、业务规则、边界与禁区',
      markers: ['- 条件 1:', '- 规则 1:', '- 不允许:', '- 平台:'],
    },
    {
      file: '.autoharness/knowledge/decisions.md',
      required: false,
      summary: '已确认的重要决策与原因',
      markers: ['### 决策 1', '- 日期:', '- 结论:', '- 原因:'],
    },
  ];

  const needsManualFill = (item) => {
    if (!checkFile(item.file)) {
      return true;
    }

    const content = readFile(item.file);
    if (!content.trim()) {
      return true;
    }

    return item.markers.some((marker) => content.includes(marker));
  };

  const hasProject = checkFile('.autoharness/project.md');
  const hasWorkspace = checkFile('.autoharness/workspace');
  const pendingRequired = [];
  const pendingRecommended = [];

  for (const item of templateChecks) {
    if (!needsManualFill(item)) {
      continue;
    }
    const line = `- ${item.file}：${item.summary}`;
    if (item.required) {
      pendingRequired.push(line);
    } else {
      pendingRecommended.push(line);
    }
  }

  if (hasProject || hasWorkspace) {
    console.log('[AutoHarness] 已检测到项目上下文');
  }

  if (pendingRequired.length > 0 || pendingRecommended.length > 0) {
    console.log('[AutoHarness] 检测到以下文件仍建议人工补充：');

    if (pendingRequired.length > 0) {
      console.log('[AutoHarness] 必须补齐:');
      pendingRequired.forEach((line) => console.log(line));
    }

    if (pendingRecommended.length > 0) {
      console.log('[AutoHarness] 推荐补齐:');
      pendingRecommended.forEach((line) => console.log(line));
    }

    console.log('[AutoHarness] 建议先补齐项目上下文，再继续 /ah-new 或 /ah-propose');
  }

  process.exit(0);
} catch (e) {
  process.exit(0);
}
