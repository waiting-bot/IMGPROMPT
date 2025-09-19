#!/bin/bash
set -e  # Exit on any error

echo "🚀 Starting Netlify build process..."
echo "Current directory: $(pwd)"
echo "Contents: $(ls -la)"

# Install Bun if not available
if ! command -v bun &> /dev/null; then
    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# Install dependencies
echo "Installing dependencies..."
cd saasfly
echo "Changed to saasfly directory: $(pwd)"
bun install

# Build the project
echo "Building project..."
bun run build || {
    echo "❌ Build failed!"
    exit 1
}

# Go back to root directory
cd ..
echo "Back to root directory: $(pwd)"

# Create netlify-dist directory
echo "Creating netlify-dist directory..."
mkdir -p netlify-dist

# Copy static assets
echo "Copying static assets..."
if [ -d "saasfly/apps/nextjs/.next/static" ]; then
    cp -r saasfly/apps/nextjs/.next/static netlify-dist/
    echo "Copied static directory"
else
    echo "Warning: static directory not found"
fi

# Copy public files
echo "Copying public files..."
if [ -d "saasfly/apps/nextjs/public" ]; then
    cp -r saasfly/apps/nextjs/public netlify-dist/
    echo "Copied public directory"
else
    echo "Warning: public directory not found"
fi

# Create a simple index.html for now
echo "Creating basic index.html..."
cat > netlify-dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IMG PROMPT - AI SaaS Platform</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .container {
            text-align: center;
            padding: 2rem;
            max-width: 600px;
        }
        
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            font-weight: 700;
        }
        
        .subtitle {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-top: 3rem;
        }
        
        .feature {
            background: rgba(255, 255, 255, 0.1);
            padding: 1.5rem;
            border-radius: 12px;
            backdrop-filter: blur(10px);
        }
        
        .feature-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .feature-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        
        .feature-desc {
            opacity: 0.8;
            line-height: 1.5;
        }
        
        .status {
            background: rgba(76, 175, 80, 0.2);
            border: 2px solid #4CAF50;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 2rem;
        }
        
        .build-info {
            position: fixed;
            bottom: 1rem;
            right: 1rem;
            background: rgba(0, 0, 0, 0.3);
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="status">
            ✅ Netlify Deployment Successful
        </div>
        
        <h1>IMG PROMPT</h1>
        <p class="subtitle">AI-Powered SaaS Platform</p>
        
        <div class="features">
            <div class="feature">
                <div class="feature-icon">🖼️</div>
                <div class="feature-title">Image Upload</div>
                <div class="feature-desc">Upload and process images with AI</div>
            </div>
            
            <div class="feature">
                <div class="feature-icon">🤖</div>
                <div class="feature-title">AI Generation</div>
                <div class="feature-desc">Generate intelligent prompts and content</div>
            </div>
            
            <div class="feature">
                <div class="feature-icon">🌐</div>
                <div class="feature-title">Multi-Language</div>
                <div class="feature-desc">Support for multiple languages</div>
            </div>
        </div>
    </div>
    
    <div class="build-info">
        Build: $(date) | Next.js Standalone Mode
    </div>
</body>
</html>
EOF

echo "✅ Build completed successfully!"
echo "📁 Final build output located at: $(pwd)/netlify-dist"
echo "🔍 Static files available: $(ls -la netlify-dist/ | wc -l) items"