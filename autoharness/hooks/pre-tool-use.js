#!/usr/bin/env node

/**
 * Pre-Tool-Use Hook
 * 最小策略执行：支持 hard block / soft warn / allowlist
 */

try {
  const fs = require('fs');
  const path = require('path');

  const data = process.argv[2] || '{}';
  const input = JSON.parse(data);
  const tool = input.tool || '';
  const args = input.input || {};
  const projectRoot = process.env.CLAUDE_PROJECT_DIR || process.cwd();
  const policyPath = path.join(projectRoot, '.autoharness', 'policy.json');
  const legacySecretPatterns = [
    {
      id: 'openai-key',
      regex: 'sk-[A-Za-z0-9]{20,}',
      message: '检测到疑似 OpenAI API Key，请确认是否包含敏感信息。',
    },
    {
      id: 'github-token',
      regex: 'ghp_[A-Za-z0-9]{36}',
      message: '检测到疑似 GitHub Token，请确认是否包含敏感信息。',
    },
    {
      id: 'aws-key',
      regex: 'AKIA[0-9A-Z]{16}',
      message: '检测到疑似 AWS Access Key，请确认是否包含敏感信息。',
    },
    {
      id: 'private-key',
      regex: '-----BEGIN (RSA |EC )?PRIVATE KEY-----',
      message: '检测到疑似私钥内容，请立即确认。',
    },
  ];

  const collectStrings = (obj, bucket = []) => {
    if (typeof obj === 'string') {
      bucket.push(obj);
    } else if (typeof obj === 'object' && obj !== null) {
      Object.values(obj).forEach((value) => collectStrings(value, bucket));
    }
    return bucket;
  };

  const buildSearchText = () => {
    if (tool === 'Bash') {
      return args.command || '';
    }
    return collectStrings(args).join('\n');
  };

  const buildRuleRegex = (rule) => {
    try {
      if (rule.regex) {
        return new RegExp(rule.regex, 'm');
      }
      if (rule.match) {
        const escaped = rule.match.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        return new RegExp(escaped, 'm');
      }
    } catch (error) {
      console.error(`[AutoHarness] 策略配置错误：规则 ${rule.id || 'unknown'} 的正则无效`);
    }
    return null;
  };

  const matchRule = (rule, searchText) => {
    if (!rule || !searchText) {
      return false;
    }
    if (rule.tool && rule.tool !== '*' && rule.tool !== tool) {
      return false;
    }

    const matcher = buildRuleRegex(rule);
    return matcher ? matcher.test(searchText) : false;
  };

  const loadPolicy = () => {
    if (!fs.existsSync(policyPath)) {
      return null;
    }
    try {
      const raw = fs.readFileSync(policyPath, 'utf8');
      return JSON.parse(raw);
    } catch (error) {
      console.error('[AutoHarness] 策略文件解析失败：.autoharness/policy.json');
      return null;
    }
  };

  const policy = loadPolicy();
  const searchText = buildSearchText();
  const allowlist = Array.isArray(policy?.allowlist) ? policy.allowlist : [];
  const hardBlockRules = Array.isArray(policy?.hard_block) ? policy.hard_block : [];
  const softWarnRules = Array.isArray(policy?.soft_warn) ? policy.soft_warn : [];
  const secretPatterns = Array.isArray(policy?.secret_patterns) ? policy.secret_patterns : legacySecretPatterns;

  // 先判 allowlist，避免已批准的命令继续命中阻断规则。
  const allowlisted = allowlist.some((rule) => matchRule(rule, searchText));

  if (!allowlisted) {
    for (const rule of hardBlockRules) {
      if (!matchRule(rule, searchText)) {
        continue;
      }
      console.error(`[AutoHarness] 策略阻断(${rule.id || 'unknown'})：${rule.message || '当前操作被策略禁止'}`);
      process.exit(2);
    }

    for (const rule of softWarnRules) {
      if (!matchRule(rule, searchText)) {
        continue;
      }
      console.error(`[AutoHarness] 策略提醒(${rule.id || 'unknown'})：${rule.message || '当前操作需要额外确认'}`);
    }
  }

  const seenSecretWarnings = new Set();
  for (const value of collectStrings(args)) {
    for (const rule of secretPatterns) {
      const matcher = buildRuleRegex(rule);
      if (!matcher || !matcher.test(value) || seenSecretWarnings.has(rule.id)) {
        continue;
      }
      console.error(`[AutoHarness] 安全提醒(${rule.id || 'unknown'})：${rule.message || '检测到疑似敏感信息'}`);
      seenSecretWarnings.add(rule.id);
    }
  }

  process.exit(0);
} catch (e) {
  process.exit(0);
}
