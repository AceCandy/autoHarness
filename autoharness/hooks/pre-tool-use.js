#!/usr/bin/env node

/**
 * Pre-Tool-Use Hook
 * 轻量版：基础安全检查
 */

try {
  const data = process.argv[2] || '{}';
  const input = JSON.parse(data);
  const tool = input.tool;
  const args = input.input || {};

  const secretPatterns = [
    /sk-[a-zA-Z0-9]{20,}/,
    /ghp_[a-zA-Z0-9]{36}/,
    /AKIA[0-9A-Z]{16}/,
    /-----BEGIN (RSA |EC )?PRIVATE KEY-----/,
  ];

  let warned = false;

  const checkSecrets = (obj) => {
    if (typeof obj === 'string') {
      for (const pattern of secretPatterns) {
        if (pattern.test(obj)) {
          if (!warned) {
            console.error('[AutoHarness] 安全提醒：检测到疑似密钥或私钥内容');
            warned = true;
          }
        }
      }
    } else if (typeof obj === 'object' && obj !== null) {
      Object.values(obj).forEach(checkSecrets);
    }
  };

  checkSecrets(args);

  if (tool === 'Bash') {
    const command = args.command || '';
    if (command.includes('--no-verify')) {
      console.error('[AutoHarness] 安全提醒：检测到 --no-verify，请确认是否真的需要跳过校验');
    }
  }

  process.exit(0);
} catch (e) {
  process.exit(0);
}
