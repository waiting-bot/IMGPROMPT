PRD：AI Prompt 生成 SaaS 平台
1️⃣ 项目背景

你基于 saasfly
 项目模板启动了一个 SaaS 应用。

前期已完成：

使用 bun 创建并同步数据库表，Supabase 中已能看到数据表。

部分前端页面与后台结构已按 saasfly 文档完成初始化。

目前遇到：

网站访问异常，需排查部署/配置问题。

项目结构和后续开发流程尚未成体系。

2️⃣ 产品目标

为用户提供一个一站式 AI 提示词生成平台，前端可选择不同 AI 模型来生成对应的提示词。

支持多模型选择，后端负责调用对应模型的 API 生成结果并返回前端。

长期目标：演进为多用户的 SaaS 平台，支持注册登录、套餐计费。

3️⃣ 核心功能
模块	功能描述
模型选择	前端下拉框/按钮，可选：midjourney、stableDiffusion、flux、normal
提示词生成	用户输入关键词 + 选择模型，后端调用相应接口生成提示词返回
用户管理(后期)	账号注册、登录、基础权限
日志 & 监控	记录调用次数、错误日志，便于后期计费与运维
健康检查	提供 API /health 接口，便于测试部署环境是否正常
4️⃣ 技术栈与工具

基础框架：saasfly (Next.js + Bun + Supabase)

数据库：Supabase（PostgreSQL）

后端语言：TypeScript

前端：Next.js + Tailwind

AI 接口：根据所选模型对接对应的提示词生成逻辑（暂可 mock）

5️⃣ 输入输出规范

输入：

model: string (midjourney / stableDiffusion / flux / normal)

keywords: string

输出：

{
  "model": "midjourney",
  "prompt": "A futuristic city at sunset..."
}

6️⃣ 关键接口（示例）
接口	方法	说明
/api/generate	POST	根据 model 和 keywords 返回生成的 prompt
/api/health	GET	返回 { status: "ok" }，检查服务是否正常
7️⃣ 现状与问题

数据库表已在 Supabase 中创建，但尚未验证数据读写。

前端可启动但网站访问异常（需排查环境变量、数据库连接、部署设置）。

没有自动化测试，可能导致后续迭代风险。

8️⃣ Claude Code 任务规划
阶段 1：测试与排错

环境检查：让 Claude Code 逐步检查 .env 配置、Supabase 连接字符串、Bun/Next 构建日志。

API 测试：生成 /api/health 接口并部署，验证服务可访问。

数据库测试：生成简单读写脚本，测试 Supabase 表。

阶段 2：核心功能开发

前端界面：提供模型选择 UI（midjourney、stableDiffusion、flux、normal）。

后端接口：/api/generate 逻辑，先用 mock 返回假数据，再预留真实 AI 调用。

错误处理 & 日志：Claude Code 加入统一的错误中间件和日志记录。

阶段 3：后续增强

用户登录注册。

调用计费。

接入真实 AI 模型 API。

9️⃣ 安全与合规

不保存用户敏感信息。

对外公开接口需带简单鉴权（如固定密码或 token）。

10️⃣ 交付要求

代码在 GitHub 私有仓库管理。

提供一份 README 说明如何本地启动、测试、部署。

保持与 Claude Code 的对话式开发：

直接把本 PRD 发给 Claude Code

让 Claude Code 依步骤编写代码、生成测试脚本并指导部署。