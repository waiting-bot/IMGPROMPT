"use client"

import { useState } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import Link from "next/link"

import { Button } from "@saasfly/ui"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@saasfly/ui"
import { Input } from "@saasfly/ui"
import { Label } from "@saasfly/ui"
import { Eye, EyeOff, Mail, Lock, User, Loader } from "lucide-react"

export default function LoginPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const [isLogin, setIsLogin] = useState(true)
  const [showPassword, setShowPassword] = useState(false)
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    confirmPassword: ""
  })

  const from = searchParams.get("from") || "/dashboard"

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError("")

    try {
      // 简单验证
      if (!isLogin && formData.password !== formData.confirmPassword) {
        setError("密码不匹配")
        return
      }
      
      // 开发模式：直接跳转
      await new Promise(resolve => setTimeout(resolve, 1000))
      router.push(from)
    } catch (error) {
      setError("操作失败，请重试")
    } finally {
      setIsLoading(false)
    }
  }

  const toggleMode = () => {
    setIsLogin(!isLogin)
    setError("")
    setFormData({
      name: "",
      email: "",
      password: "",
      confirmPassword: ""
    })
  }

  return (
    <div className="container flex h-screen w-screen flex-col items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">IMG PROMPT</h1>
          <p className="text-gray-600 mt-2">AI 驱动的图像提示词生成平台</p>
        </div>

        <Card className="shadow-xl">
          <CardHeader className="space-y-1">
            <CardTitle className="text-2xl text-center">
              {isLogin ? "登录" : "注册"}
            </CardTitle>
            <CardDescription className="text-center">
              {isLogin 
                ? "欢迎回来！请登录您的账户" 
                : "创建新账户开始您的AI之旅"
              }
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              {!isLogin && (
                <div className="space-y-2">
                  <Label htmlFor="name">用户名</Label>
                  <div className="relative">
                    <User className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                    <Input
                      id="name"
                      name="name"
                      type="text"
                      placeholder="请输入用户名"
                      value={formData.name}
                      onChange={handleInputChange}
                      className="pl-10"
                      required={!isLogin}
                    />
                  </div>
                </div>
              )}

              <div className="space-y-2">
                <Label htmlFor="email">邮箱</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                  <Input
                    id="email"
                    name="email"
                    type="email"
                    placeholder="请输入邮箱"
                    value={formData.email}
                    onChange={handleInputChange}
                    className="pl-10"
                    required
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="password">密码</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                  <Input
                    id="password"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    placeholder="请输入密码"
                    value={formData.password}
                    onChange={handleInputChange}
                    className="pl-10 pr-10"
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              {!isLogin && (
                <div className="space-y-2">
                  <Label htmlFor="confirmPassword">确认密码</Label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                    <Input
                      id="confirmPassword"
                      name="confirmPassword"
                      type={showPassword ? "text" : "password"}
                      placeholder="请再次输入密码"
                      value={formData.confirmPassword}
                      onChange={handleInputChange}
                      className="pl-10"
                      required={!isLogin}
                    />
                  </div>
                </div>
              )}

              {error && (
                <div className="text-red-600 text-sm text-center bg-red-50 p-2 rounded">
                  {error}
                </div>
              )}

              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading ? (
                  <>
                    <Loader className="mr-2 h-4 w-4 animate-spin" />
                    处理中...
                  </>
                ) : isLogin ? (
                  "登录"
                ) : (
                  "注册"
                )}
              </Button>
            </form>

            <div className="mt-6 text-center">
              <div className="text-sm text-gray-600">
                {isLogin ? "还没有账户？" : "已有账户？"}
                <button
                  onClick={toggleMode}
                  className="text-blue-600 hover:text-blue-800 font-medium ml-1"
                >
                  {isLogin ? "立即注册" : "立即登录"}
                </button>
              </div>
            </div>

            <div className="mt-6">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300" />
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-2 bg-card text-muted-foreground">或</span>
                </div>
              </div>

              <div className="mt-4">
                <Button 
                  variant="outline" 
                  className="w-full"
                  onClick={() => {
                    setIsLoading(true)
                    setTimeout(() => {
                      router.push(from)
                    }, 1000)
                  }}
                  disabled={isLoading}
                >
                  <Loader className={`mr-2 h-4 w-4 ${isLoading ? 'animate-spin' : ''}`} />
                  开发模式快速进入
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}