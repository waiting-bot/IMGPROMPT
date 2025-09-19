import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@saasfly/ui"
import { Button } from "@saasfly/ui"
import { Image as ImageIcon, Sparkles, Zap, Brain } from "lucide-react"

export default function HomePage() {
  const models = [
    {
      name: "GPT-4",
      description: "最强大的语言模型",
      icon: Brain,
      color: "text-blue-600"
    },
    {
      name: "Claude",
      description: "智能对话助手",
      icon: Sparkles,
      color: "text-purple-600"
    },
    {
      name: "Gemini",
      description: "多模态AI模型",
      icon: Zap,
      color: "text-orange-600"
    },
    {
      name: "DALL-E",
      description: "图像生成模型",
      icon: ImageIcon,
      color: "text-green-600"
    }
  ]

  return (
    <div className="container flex h-screen w-screen flex-col items-center justify-center">
      <div className="max-w-4xl w-full text-center space-y-6 pt-8">
        <h1 className="text-4xl font-bold">欢迎使用 IMG PROMPT</h1>
        <p className="text-lg text-muted-foreground">
          开发模式 - AI SaaS 平台
        </p>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 my-8">
          {models.map((model, index) => (
            <Card key={index} className="hover:shadow-lg transition-shadow">
              <CardHeader className="text-center">
                <model.icon className={`h-8 w-8 mx-auto ${model.color}`} />
                <CardTitle className="text-lg">{model.name}</CardTitle>
                <CardDescription>{model.description}</CardDescription>
              </CardHeader>
            </Card>
          ))}
        </div>
        
        <div className="space-y-4">
          <Link href="/zh/dashboard">
            <Button className="w-full sm:w-auto">
              进入开发模式
            </Button>
          </Link>
        </div>
      </div>
    </div>
  )
}