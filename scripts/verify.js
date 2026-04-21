#!/usr/bin/env node

/**
 * AutoHarness 验证脚本
 * 读取 .autoharness/project.md 中显式配置的验证命令，顺序执行并产出验证报告。
 */

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const PROJECT_ROOT = process.cwd();
const AUTOHARNESS_DIR = path.join(PROJECT_ROOT, '.autoharness');
const PROJECT_FILE = path.join(AUTOHARNESS_DIR, 'project.md');
const STATE_SCRIPT = path.join(AUTOHARNESS_DIR, 'scripts', 'state.js');
const DEFAULT_TIMEOUT_MS = Number(process.env.AUTOHARNESS_VERIFY_TIMEOUT_MS || 60000);
const CHECKS = [
  { id: 'lint', label: 'Lint', projectKey: 'Lint 命令' },
  { id: 'typecheck', label: '类型检查', projectKey: '类型检查命令' },
  { id: 'test', label: '测试', projectKey: '测试命令' },
  { id: 'build', label: '构建', projectKey: '构建命令' },
];

function fail(message) {
  console.error(`[AutoHarness] ${message}`);
  process.exit(1);
}

function parseArgs(argv) {
  const args = argv.slice(2);
  const parsed = {
    change: '',
  };

  for (let i = 0; i < args.length; i += 1) {
    const token = args[i];
    if (token === '--change') {
      const value = args[i + 1];
      if (!value || value.startsWith('--')) {
        fail('参数 --change 缺少值');
      }
      parsed.change = value;
      i += 1;
      continue;
    }
    if (token.startsWith('--')) {
      fail(`未知参数: ${token}`);
    }
    if (!parsed.change) {
      parsed.change = token;
      continue;
    }
    fail(`未知位置参数: ${token}`);
  }

  return parsed;
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function loadProjectConfig() {
  if (!fs.existsSync(PROJECT_FILE)) {
    return {};
  }

  const content = fs.readFileSync(PROJECT_FILE, 'utf8');
  const config = {};

  for (const rawLine of content.split('\n')) {
    const line = rawLine.trim();
    const match = line.match(/^- ([^:]+):\s*(.*)$/);
    if (!match) {
      continue;
    }

    const key = match[1].trim();
    let value = match[2].trim();
    if (!value) {
      continue;
    }
    if (value.startsWith('`') && value.endsWith('`')) {
      value = value.slice(1, -1).trim();
    }
    config[key] = value;
  }

  return config;
}

function summarizeOutput(stdout, stderr) {
  const merged = [stdout || '', stderr || '']
    .join('\n')
    .split('\n')
    .map((line) => line.trimEnd())
    .filter((line) => line.trim().length > 0);

  if (merged.length === 0) {
    return '- 无输出';
  }

  return merged.slice(0, 8).map((line) => `- ${line}`).join('\n');
}

function runCommand(command) {
  const result = spawnSync(command, {
    cwd: PROJECT_ROOT,
    shell: true,
    encoding: 'utf8',
    timeout: DEFAULT_TIMEOUT_MS,
  });

  if (result.error && result.error.code === 'ETIMEDOUT') {
    return {
      ok: false,
      timedOut: true,
      exitCode: null,
      stdout: result.stdout || '',
      stderr: result.stderr || '',
    };
  }

  return {
    ok: result.status === 0,
    timedOut: false,
    exitCode: result.status,
    stdout: result.stdout || '',
    stderr: result.stderr || '',
  };
}

function reportPathForChange(changeName) {
  if (!changeName) {
    return path.join(AUTOHARNESS_DIR, 'workspace', 'verify-report.md');
  }

  const changeDir = path.join(AUTOHARNESS_DIR, 'changes', changeName);
  if (!fs.existsSync(changeDir)) {
    fail(`变更目录不存在: .autoharness/changes/${changeName}`);
  }

  return path.join(changeDir, 'verify-report.md');
}

function appendStateProgress(message) {
  if (!fs.existsSync(STATE_SCRIPT)) {
    return;
  }

  spawnSync(process.execPath, [STATE_SCRIPT, 'set-phase', '--value', 'verify'], {
    cwd: PROJECT_ROOT,
    encoding: 'utf8',
  });
  spawnSync(process.execPath, [STATE_SCRIPT, 'append-progress', '--value', message], {
    cwd: PROJECT_ROOT,
    encoding: 'utf8',
  });
}

function renderReport({ change, passed, failed, skipped }) {
  const title = change ? `# 验证报告: ${change}` : '# 验证报告';
  const passedLines = passed.length > 0
    ? passed.map((item) => `- ${item.label}: \`${item.command}\``).join('\n')
    : '- 无';
  const failedLines = failed.length > 0
    ? failed.map((item) => {
      const statusLine = item.timedOut
        ? '- 原因: 命令执行超时'
        : `- 退出码: ${item.exitCode === null ? 'null' : item.exitCode}`;
      return [
        `- ${item.label}: \`${item.command}\``,
        `  ${statusLine}`,
        '  - 输出摘要:',
        summarizeOutput(item.stdout, item.stderr).split('\n').map((line) => `  ${line}`).join('\n'),
      ].join('\n');
    }).join('\n')
    : '- 无';
  const skippedLines = skipped.length > 0
    ? skipped.map((item) => `- ${item.label}: ${item.reason}`).join('\n')
    : '- 无';
  const nextStep = failed.length === 0
    ? '- 可以进入 /ah-ship'
    : '- 先修复失败项后重新运行 /ah-verify';

  return [
    title,
    '',
    `> 生成时间: ${new Date().toISOString()}`,
    '',
    '## ✅ 通过',
    passedLines,
    '',
    '## ❌ 失败',
    failedLines,
    '',
    '## ⏭️ 跳过',
    skippedLines,
    '',
    '## 下一步',
    nextStep,
    '',
  ].join('\n');
}

function main() {
  const { change } = parseArgs(process.argv);
  const config = loadProjectConfig();
  const reportPath = reportPathForChange(change);
  const passed = [];
  const failed = [];
  const skipped = [];

  // 只跑用户在 project.md 里明确配置的命令，避免隐式猜测带来的静默降级。
  for (const check of CHECKS) {
    const command = config[check.projectKey];
    if (!command) {
      skipped.push({
        label: check.label,
        reason: `未配置 ${check.projectKey}`,
      });
      continue;
    }

    const result = runCommand(command);
    if (result.ok) {
      passed.push({
        label: check.label,
        command,
      });
    } else {
      failed.push({
        label: check.label,
        command,
        timedOut: result.timedOut,
        exitCode: result.exitCode,
        stdout: result.stdout,
        stderr: result.stderr,
      });
    }
  }

  if (passed.length === 0 && failed.length === 0) {
    failed.push({
      label: '配置检查',
      command: '-',
      timedOut: false,
      exitCode: null,
      stdout: '',
      stderr: 'project.md 中未配置任何验证命令',
    });
  }

  ensureDir(path.dirname(reportPath));
  fs.writeFileSync(reportPath, renderReport({ change, passed, failed, skipped }), 'utf8');

  if (failed.length === 0) {
    appendStateProgress(`验证通过: ${passed.length} 项, 跳过 ${skipped.length} 项`);
    process.exit(0);
  }

  appendStateProgress(`验证失败: ${failed.length} 项, 通过 ${passed.length} 项`);
  process.exit(1);
}

main();
