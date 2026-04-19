# API 模块规格

## Requirement: RESTful 接口
所有 API 端点 MUST 遵循 RESTful 设计规范。

#### Scenario: 资源列表
- GIVEN 存在资源集合
- WHEN 客户端发送 GET /api/{resource} 请求
- THEN 返回分页的资源列表
- AND 包含 total、page、pageSize 元数据

#### Scenario: 资源创建
- GIVEN 客户端提供有效数据
- WHEN 客户端发送 POST /api/{resource} 请求
- THEN 创建新资源并返回 201 Created
- AND 响应体包含完整资源对象

#### Scenario: 资源更新
- GIVEN 资源已存在
- WHEN 客户端发送 PUT /api/{resource}/{id} 请求
- THEN 更新资源并返回 200 OK
- AND 响应体包含更新后的资源对象

---

## Requirement: 错误处理
所有 API 响应 MUST 使用统一的错误格式。

#### Scenario: 业务错误
- GIVEN 请求违反业务规则
- WHEN API 处理请求
- THEN 返回 4xx 状态码
- AND 响应体包含 { code, message, details } 格式

#### Scenario: 系统错误
- GIVEN 系统发生未预期异常
- WHEN API 处理请求
- THEN 返回 500 状态码
- AND 记录详细错误日志（不暴露给客户端）
- AND 响应体包含通用错误信息

---

## Requirement: 速率限制
系统 SHOULD 对 API 请求实施速率限制。

#### Scenario: 超出限制
- GIVEN 客户端在短时间内发送过多请求
- WHEN 请求超过速率阈值
- THEN 返回 429 Too Many Requests
- AND 响应头包含 Retry-After
