#!/usr/bin/env node

/**
 * AutoHarness 状态脚本
 * 负责把当前任务、阶段、进度和待确认事项稳定落盘到 STATE.md。
 */

const fs = require('fs');
const path = require('path');

const VALID_PHASES = new Set(['propose', 'discuss', 'execute', 'debug', 'verify', 'ship']);
const STATE_FILE = path.join(process.cwd(), '.autoharness', 'workspace', 'STATE.md');

function fail(message) {
  console.error(`[AutoHarness] ${message}`);
  process.exit(1);
}

function ensureParentDir(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function normalizeBlock(value, fallback = '- 无') {
  if (!value) {
    return fallback;
  }

  const lines = value
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean);

  if (lines.length === 0) {
    return fallback;
  }

  return lines
    .map((line) => (line.startsWith('- ') ? line : `- ${line}`))
    .join('\n');
}

function normalizePhase(value, fallback = '- 未设置') {
  if (!value) {
    return fallback;
  }
  if (!VALID_PHASES.has(value)) {
    fail(`无效阶段: ${value}，允许值: ${Array.from(VALID_PHASES).join(', ')}`);
  }
  return value;
}

function renderState(state) {
  return [
    '# 当前状态',
    '',
    `> 最后更新: ${state.updatedAt}`,
    '',
    '## 当前任务',
    state.task,
    '',
    '## 当前阶段',
    state.phase,
    '',
    '## 进度',
    state.progress,
    '',
    '## 待确认事项',
    state.pending,
    '',
  ].join('\n');
}

function sectionContent(markdown, heading) {
  const marker = `## ${heading}`;
  const start = markdown.indexOf(marker);
  if (start === -1) {
    return '';
  }

  const contentStart = start + marker.length;
  const nextHeading = markdown.indexOf('\n## ', contentStart);
  const raw = nextHeading === -1
    ? markdown.slice(contentStart)
    : markdown.slice(contentStart, nextHeading);

  return raw.trim();
}

function loadState() {
  if (!fs.existsSync(STATE_FILE)) {
    return {
      updatedAt: new Date().toISOString(),
      task: '- 无',
      phase: '- 未设置',
      progress: '- 无',
      pending: '- 无',
    };
  }

  const markdown = fs.readFileSync(STATE_FILE, 'utf8');
  const updatedAtMatch = markdown.match(/> 最后更新:\s*(.+)/);

  return {
    updatedAt: updatedAtMatch ? updatedAtMatch[1].trim() : new Date().toISOString(),
    task: sectionContent(markdown, '当前任务') || '- 无',
    phase: sectionContent(markdown, '当前阶段') || '- 未设置',
    progress: sectionContent(markdown, '进度') || '- 无',
    pending: sectionContent(markdown, '待确认事项') || '- 无',
  };
}

function saveState(state) {
  ensureParentDir(STATE_FILE);
  fs.writeFileSync(STATE_FILE, renderState(state), 'utf8');
}

function parseArgs(argv) {
  const command = argv[2];
  const args = argv.slice(3);
  const options = {};

  if (!command) {
    fail('用法: node .autoharness/scripts/state.js <command> [options]');
  }

  for (let i = 0; i < args.length; i += 1) {
    const token = args[i];
    if (!token.startsWith('--')) {
      fail(`未知参数: ${token}`);
    }

    const key = token.slice(2);
    const value = args[i + 1];
    if (value === undefined || value.startsWith('--')) {
      fail(`参数 ${token} 缺少值`);
    }

    options[key] = value;
    i += 1;
  }

  return { command, options };
}

function appendLine(block, line) {
  const current = block && block !== '- 无' ? block.split('\n').filter(Boolean) : [];
  const normalized = line.startsWith('- ') ? line : `- ${line}`;

  if (current.includes(normalized)) {
    return current.join('\n') || '- 无';
  }

  current.push(normalized);
  return current.join('\n');
}

function main() {
  const { command, options } = parseArgs(process.argv);
  const state = loadState();

  if (command === 'show') {
    process.stdout.write(renderState(state));
    return;
  }

  // 核心写入路径统一在这里，避免多个子命令各自散落修改逻辑。
  switch (command) {
    case 'set': {
      if (options.task !== undefined) {
        state.task = normalizeBlock(options.task);
      }
      if (options.phase !== undefined) {
        state.phase = normalizePhase(options.phase);
      }
      if (options.progress !== undefined) {
        state.progress = normalizeBlock(options.progress);
      }
      if (options.pending !== undefined) {
        state.pending = normalizeBlock(options.pending);
      }
      break;
    }
    case 'set-task':
      state.task = normalizeBlock(options.value);
      break;
    case 'set-phase':
      state.phase = normalizePhase(options.value);
      break;
    case 'append-progress':
      state.progress = appendLine(state.progress, options.value || '');
      break;
    case 'append-pending':
      state.pending = appendLine(state.pending, options.value || '');
      break;
    case 'clear-pending':
      state.pending = '- 无';
      break;
    default:
      fail(`未知命令: ${command}`);
  }

  state.updatedAt = new Date().toISOString();
  saveState(state);
}

main();
