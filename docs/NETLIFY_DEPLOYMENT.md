# Netlify部署环境变量配置

## 必需环境变量

### 应用程序配置
- `NEXT_PUBLIC_APP_URL` - 应用程序URL（Netlify分配的域名，如：https://your-app.netlify.app）

### 身份验证
- `NEXTAUTH_SECRET` - NextAuth.js密钥（生成：`openssl rand -base64 32`）
- `NEXTAUTH_URL` - NextAuth.js URL（与应用程序URL相同）
- `GITHUB_CLIENT_ID` - GitHub OAuth客户端ID
- `GITHUB_CLIENT_SECRET` - GitHub OAuth客户端密钥
- `GOOGLE_CLIENT_ID` - Google OAuth客户端ID（可选）
- `GOOGLE_CLIENT_SECRET` - Google OAuth客户端密钥（可选）

### 数据库配置
- `POSTGRES_URL` - PostgreSQL数据库连接字符串
- `IS_DEBUG` - 调试模式（设置为false）

### 外部服务
- `RESEND_API_KEY` - Resend邮件服务API密钥
- `RESEND_FROM` - 发件人邮箱地址
- `STRIPE_API_KEY` - Stripe API密钥
- `STRIPE_WEBHOOK_SECRET` - Stripe Webhook密钥
- `NEXT_PUBLIC_STRIPE_STD_PRODUCT_ID` - Stripe标准产品ID
- `NEXT_PUBLIC_STRIPE_STD_MONTHLY_PRICE_ID` - Stripe标准月付价格ID
- `NEXT_PUBLIC_STRIPE_PRO_PRODUCT_ID` - Stripe专业产品ID
- `NEXT_PUBLIC_STRIPE_PRO_MONTHLY_PRICE_ID` - Stripe专业月付价格ID
- `NEXT_PUBLIC_STRIPE_PRO_YEARLY_PRICE_ID` - Stripe专业年付价格ID
- `NEXT_PUBLIC_STRIPE_BUSINESS_PRODUCT_ID` - Stripe商业产品ID
- `NEXT_PUBLIC_STRIPE_BUSINESS_MONTHLY_PRICE_ID` - Stripe商业月付价格ID
- `NEXT_PUBLIC_STRIPE_BUSINESS_YEARLY_PRICE_ID` - Stripe商业年付价格ID

### 分析和监控
- `NEXT_PUBLIC_POSTHOG_KEY` - PostHog API密钥
- `NEXT_PUBLIC_POSTHOG_HOST` - PostHog主机地址

### AI服务
- `COZE_API_KEY` - Coze API密钥
- `COZE_API_URL` - Coze API URL（默认：https://api.coze.cn）
- `WORKFLOW_ID` - Coze工作流ID

### 管理配置
- `ADMIN_EMAIL` - 管理员邮箱地址（多个用逗号分隔）

## 如何在Netlify中设置环境变量

### 方法1：通过Netlify界面
1. 登录Netlify控制台
2. 选择你的网站
3. 点击"Site settings"
4. 选择"Build & deploy" > "Environment"
5. 点击"Edit variables"
6. 逐个添加环境变量

### 方法2：通过Netlify CLI
1. 安装Netlify CLI：`npm install -g netlify-cli`
2. 登录：`netlify login`
3. 设置环境变量：
```bash
netlify env:set NEXT_PUBLIC_APP_URL https://your-app.netlify.app
netlify env:set NEXTAUTH_SECRET your_secret_here
netlify env:set POSTGRES_URL your_database_url
# ... 其他变量
```

### 方法3：通过netlify.toml
```toml
[build.environment]
  NEXT_PUBLIC_APP_URL = "https://your-app.netlify.app"
  NEXTAUTH_SECRET = "your_secret_here"
  # ... 其他变量
```

## 环境变量获取指南

### 1. 生成NextAuth密钥
```bash
openssl rand -base64 32
```

### 2. 获取GitHub OAuth密钥
- 访问 https://github.com/settings/developers
- 创建新的OAuth应用
- 设置Authorization callback URL为：`https://your-app.netlify.app/api/auth/callback/github`

### 3. 设置数据库
- 推荐使用Supabase、Neon或Railway
- 获取数据库连接字符串

### 4. 配置Stripe
- 访问 https://dashboard.stripe.com/apikeys
- 获取API密钥和Webhook密钥
- 设置Webhook endpoint：`https://your-app.netlify.app/api/stripe/webhook`

### 5. 配置Resend
- 访问 https://resend.com/api-keys
- 获取API密钥

### 6. 配置Coze
- 访问 https://www.coze.cn/
- 获取API密钥和工作流ID

## Netlify配置步骤

1. **连接GitHub仓库**
   - 登录Netlify控制台
   - 点击"New site from Git"
   - 选择GitHub仓库
   - 授权Netlify访问

2. **设置构建配置**
   - Build command: `./netlify-build.sh`
   - Publish directory: `netlify-dist`
   - Node.js版本: 18

3. **配置环境变量**
   - 使用上述方法之一添加所有必需变量

4. **部署设置**
   - 启用自动部署（分支推送时自动构建）
   - 配置自定义域名（如果需要）
   - 设置HTTPS证书

## 构建脚本说明

项目包含以下部署文件：
- `netlify.toml` - Netlify配置文件
- `netlify-build.sh` - 构建脚本
- `saasfly/apps/nextjs/next.config.mjs` - Next.js配置（已调整为standalone模式）

## 故障排除

如果构建失败，检查：
1. 所有环境变量是否正确设置
2. Bun包管理器是否正确安装
3. 数据库连接是否正常
4. 依赖版本是否兼容
5. GitHub OAuth回调URL是否正确

## 部署后验证

部署完成后，验证：
1. 网站是否正常加载
2. 身份验证功能是否工作
3. 数据库连接是否正常
4. 所有API端点是否响应
5. Stripe支付功能是否正常
6. 邮件发送功能是否正常