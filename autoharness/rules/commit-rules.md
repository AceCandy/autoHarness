# 提交规则

## 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具相关

### 规则

1. 使用祈使语气（"add" 不是 "added"）
2. 首行不超过 72 字符
3. Body 解释"为什么"，不是"做什么"
4. Footer 包含 Breaking Changes 和 Issue 引用

## 提交前检查

- [ ] 代码通过 lint
- [ ] 测试全部通过
- [ ] 没有调试代码（console.log 等）
- [ ] 没有敏感信息
- [ ] 提交信息格式正确

## 原子提交

- 每个提交应该是一个逻辑单元
- 不要混合不相关的修改
- 如果提交太大，考虑拆分
