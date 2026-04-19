# 认证模块规格

## Requirement: 用户注册
系统 MUST 支持用户通过邮箱注册。

#### Scenario: 有效邮箱注册
- GIVEN 用户提供有效邮箱地址
- WHEN 用户提交注册表单
- THEN 系统发送验证邮件
- AND 创建待验证账户记录

#### Scenario: 邮箱已存在
- GIVEN 邮箱已被注册
- WHEN 用户尝试注册
- THEN 返回"邮箱已存在"错误
- AND 不创建新记录

---

## Requirement: 用户登录
系统 SHALL 在用户验证身份后颁发 JWT Token。

#### Scenario: 有效凭证
- GIVEN 用户拥有已验证的有效账户
- WHEN 用户提交正确的用户名和密码
- THEN 返回 JWT access token 和 refresh token
- AND token 包含用户 ID 和角色信息

#### Scenario: 无效凭证
- GIVEN 用户提供错误的密码
- WHEN 用户尝试登录
- THEN 返回"凭证无效"错误
- AND 不泄露具体是用户名还是密码错误

---

## Requirement: 会话管理
系统 MUST 在 15 分钟无活动后过期会话。

#### Scenario: 会话过期
- GIVEN 用户已登录
- WHEN 15 分钟内无任何请求
- THEN 当前会话标记为过期
- AND 下次请求需要重新认证

---

## Requirement: Token 刷新
系统 MUST 支持通过 refresh token 获取新的 access token。

#### Scenario: 有效刷新
- GIVEN 用户持有未过期的 refresh token
- WHEN 用户请求刷新
- THEN 返回新的 access token
- AND 返回新的 refresh token（轮换）

#### Scenario: 过期 Token
- GIVEN refresh token 已过期
- WHEN 用户请求刷新
- THEN 返回"Token 已过期"错误
- AND 需要重新登录

## Requirement: 用户登出
系统 MUST 支持用户主动登出。

#### Scenario: 正常登出
- GIVEN 用户持有有效的 refresh token
- WHEN 用户请求登出
- THEN 使 refresh token 失效
- AND 返回"已退出"消息

---
