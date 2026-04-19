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

  // 密钥检测
  const secretPatterns = [
    /sk-[a-zA-Z0-9]{20,}/,
    /ghp_[a-zA-Z0-9]{36}/,
    /AKIA[0-9A-Z]{16}/,
    /-----BEGIN (RSA |EC )?PRIVATE KEY-----/,
  ];

  const checkSecrets = (obj) => {
    if (typeof obj === 'string') {
      for (const pattern of secretPatterns) {
        if (pattern.test(obj)) {
          console.error('[AutoHarness] Security: Potential secret detected');
        }
      }
    } else if (typeof obj === 'object' && obj !== null) {
      Object.values(obj).forEach(checkSecrets);
    }
  };

  checkSecrets(args);

  // Git 安全检查
  if (tool === 'Bash') {
    const command = args.command || '';
    if (command.includes('--no-verify')) {
      console.error('[AutoHarness] Security: --no-verify flag not allowed');
    }
  }

  process.exit(0);
} catch (e) {
  process.exit(0);
}
