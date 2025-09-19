# 项目任务管理说明

## 📋 **概述**

本项目使用自动化任务管理系统来跟踪开发进度。任务清单位于 `docs/TASK_LIST.md`，会随着项目进展自动更新。

## 🚀 **快速开始**

### 1. 查看当前任务状态
```bash
# 查看任务统计
node scripts/task-tracker.js stats

# 查看详细任务清单
cat docs/TASK_LIST.md
```

### 2. 验证项目功能
```bash
# 运行完整功能验证
node scripts/validate-project.js
```

### 3. 更新任务状态

#### 完成任务
```bash
# 完成任务 1.1
node scripts/task-tracker.js complete 1.1

# 完成任务并添加备注
node scripts/task-tracker.js complete 1.1 "功能测试通过"
```

#### 开始任务
```bash
# 开始任务 3.2
node scripts/task-tracker.js start 3.2

# 开始任务并添加备注
node scripts/task-tracker.js start 3.2 "开始Coze API集成"
```

#### 验证任务
```bash
# 验证任务通过
node scripts/task-tracker.js verify 1.1 "所有功能正常"

# 验证任务失败
node scripts/task-tracker.js fail 1.1 "发现端口冲突问题"
```

## 📊 **任务状态说明**

| 状态 | 图标 | 说明 |
|------|------|------|
| 已完成 | ✅ | 任务代码已完成 |
| 进行中 | 🔄 | 任务正在开发中 |
| 待开始 | ⏳ | 任务尚未开始 |
| 已验证 | ✅ | 功能验证通过 |
| 需验证 | ⚠️ | 已完成但需要验证 |
| 验证失败 | ❌ | 功能验证不通过 |

## 🔧 **自动化功能**

### 验证脚本功能
`validate-project.js` 脚本会自动检查：

- **应用服务状态**: 检查端口和应用是否正常运行
- **API接口**: 验证健康检查和生成API
- **页面访问**: 确认AI Prompt页面可正常访问
- **文件系统**: 检查关键文件是否存在
- **依赖完整性**: 验证所有必需依赖已安装

### 任务追踪功能
`task-tracker.js` 脚本提供：

- **状态更新**: 自动更新任务状态和备注
- **统计更新**: 实时更新项目完成统计
- **更新记录**: 自动记录所有状态变更
- **历史追踪**: 维护完整的更新历史

## 📝 **任务ID规范**

任务ID采用 `阶段.子任务` 格式：

- **1.x**: 阶段1 - 基础修复
  - 1.1: 修改端口配置
  - 1.2: 禁用OAuth功能
  - ...

- **2.x**: 阶段2 - 核心功能开发
  - 2.1: 创建AI Prompt页面
  - 2.2: 实现图片上传组件
  - ...

- **3.x**: 阶段3 - 生产准备
  - 3.1: 创建Coze API客户端
  - 3.2: 接入真实Coze API
  - ...

## 🎯 **推荐工作流程**

### 1. 开始新任务
```bash
# 开始任务
node scripts/task-tracker.js start 3.2 "开始Coze API集成工作"
```

### 2. 开发过程中
- 定期提交代码
- 更新任务备注（可选）

### 3. 完成任务
```bash
# 完成任务
node scripts/task-tracker.js complete 3.2 "Coze API集成完成"
```

### 4. 验证功能
```bash
# 运行验证
node scripts/validate-project.js

# 或手动验证特定任务
node scripts/task-tracker.js verify 3.2 "API测试通过"
```

## 📄 **文档结构**

```
docs/
├── TASK_LIST.md          # 主任务清单
├── prd.md               # 产品需求文档
└── ...                  # 其他文档

scripts/
├── task-tracker.js      # 任务状态管理脚本
├── validate-project.js  # 项目验证脚本
└── ...                  # 其他脚本
```

## 💡 **最佳实践**

1. **及时更新**: 完成任务后立即更新状态
2. **详细备注**: 添加具体的完成/失败信息
3. **定期验证**: 开发完成后运行验证脚本
4. **查看统计**: 定期查看项目整体进度

## 🔍 **故障排除**

### 常见问题

1. **任务找不到**: 确认任务ID格式正确
2. **权限错误**: 确保有写入docs目录的权限
3. **端口冲突**: 确保应用在正确端口运行

### 获取帮助

```bash
# 查看使用帮助
node scripts/task-tracker.js

# 查看统计信息
node scripts/task-tracker.js stats
```

---

*此文档会随着项目进展更新，最后更新时间：2025-09-17*