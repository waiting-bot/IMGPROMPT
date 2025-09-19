#!/bin/bash
set -e  # Exit on any error

# Netlify Build Script for Saasfly Project
# This script handles the build process for Netlify deployment

echo "🚀 Starting Netlify build process..."
echo "Current directory: $(pwd)"
echo "Contents: $(ls -la)"

# Install Bun if not available
if ! command -v bun &> /dev/null; then
    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# Clean up problematic files before build
echo "Cleaning up problematic files..."
find saasfly -name "*" | grep -E "[#?]" | grep -v node_modules | while read file; do
    echo "Removing problematic file: $file"
    rm -f "$file"
done

# Install dependencies
echo "Installing dependencies..."
cd saasfly
echo "Changed to saasfly directory: $(pwd)"
echo "Contents: $(ls -la)"
bun install

# Build the project
echo "Building project..."
bun run build || {
    echo "❌ Build failed!"
    exit 1
}

# Copy standalone output to Netlify publish directory
echo "Preparing build output..."
cd ..
echo "Back to root directory: $(pwd)"
mkdir -p netlify-dist

# Check if build output exists
echo "Checking build output..."
if [ ! -d "saasfly/apps/nextjs/.next" ]; then
    echo "❌ Build output directory does not exist!"
    exit 1
fi

echo "Build output contents:"
ls -la saasfly/apps/nextjs/.next/

# Copy static assets
echo "Copying static assets..."
cp -r saasfly/apps/nextjs/.next/static netlify-dist/

# Copy public files (check if directory exists)
echo "Copying public files..."
if [ -d "saasfly/apps/nextjs/public" ]; then
    echo "Found public directory, copying..."
    cp -r saasfly/apps/nextjs/public netlify-dist/
else
    echo "Warning: public directory not found, skipping..."
fi

# Clean up old HTML files that may interfere with server routing
echo "Cleaning up old HTML files..."
rm -f netlify-dist/index.html netlify-dist/en.html netlify-dist/zh.html netlify-dist/ja.html netlify-dist/ko.html 2>/dev/null || true

# Copy complete standalone structure
echo "Copying complete standalone structure..."
if [ -d "saasfly/apps/nextjs/.next/standalone/apps/nextjs/.next" ]; then
    cp -r saasfly/apps/nextjs/.next/standalone/apps/nextjs/.next netlify-dist/
    echo "Copied .next directory"
else
    echo "Error: .next directory not found in standalone output!"
    exit 1
fi

# Copy server.js and package.json
echo "Copying server files..."
if [ -f "saasfly/apps/nextjs/.next/standalone/apps/nextjs/server.js" ]; then
    cp saasfly/apps/nextjs/.next/standalone/apps/nextjs/server.js netlify-dist/
    echo "Copied server.js"
else
    echo "Error: server.js not found in standalone output!"
    exit 1
fi

if [ -f "saasfly/apps/nextjs/.next/standalone/apps/nextjs/package.json" ]; then
    cp saasfly/apps/nextjs/.next/standalone/apps/nextjs/package.json netlify-dist/
    echo "Copied package.json"
else
    echo "Error: package.json not found in standalone output!"
    exit 1
fi

# Copy node_modules (standalone version)
if [ -d "saasfly/apps/nextjs/.next/standalone/node_modules" ]; then
    cp -r saasfly/apps/nextjs/.next/standalone/node_modules netlify-dist/
    echo "Copied node_modules"
else
    echo "Error: node_modules not found in standalone output!"
    exit 1
fi

# Note: Static HTML files are not needed in standalone mode
# All pages are served through the Next.js server function

# Create Netlify Functions server handler
echo "Setting up Netlify Functions..."
mkdir -p netlify-dist/functions

# Create Netlify-compatible server.js
cat > netlify-dist/functions/server.js << 'EOF'
const path = require('path')

// Set correct directory for Netlify Functions
const dir = path.join(__dirname, '..')

process.env.NODE_ENV = 'production'
process.chdir(dir)

const currentPort = parseInt(process.env.PORT, 10) || 3000
const hostname = process.env.HOSTNAME || '0.0.0.0'

let keepAliveTimeout = parseInt(process.env.KEEP_ALIVE_TIMEOUT, 10)
const nextConfig = {"env":{},"eslint":{"ignoreDuringBuilds":false},"typescript":{"ignoreBuildErrors":false,"tsconfigPath":"tsconfig.json"},"distDir":"./.next","cleanDistDir":true,"assetPrefix":"","cacheMaxMemorySize":52428800,"configOrigin":"next.config.mjs","useFileSystemPublicRoutes":true,"generateEtags":true,"pageExtensions":["ts","tsx","mdx"],"poweredByHeader":true,"compress":true,"analyticsId":"","images":{"deviceSizes":[640,750,828,1080,1200,1920,2048,3840],"imageSizes":[16,32,48,64,96,128,256,384],"path":"/_next/image","loader":"default","loaderFile":"","domains":["images.unsplash.com","avatars.githubusercontent.com","www.twillot.com","cdnv2.ruguoapp.com","www.setupyourpay.com"],"disableStaticImages":false,"minimumCacheTTL":60,"formats":["image/webp"],"dangerouslyAllowSVG":false,"contentSecurityPolicy":"script-src 'none'; frame-src 'none'; sandbox;","contentDispositionType":"inline","remotePatterns":[],"unoptimized":false},"devIndicators":{"buildActivity":true,"buildActivityPosition":"bottom-right"},"onDemandEntries":{"maxInactiveAge":60000,"pagesBufferLength":5},"amp":{"canonicalBase":""},"basePath":"","sassOptions":{},"trailingSlash":true,"i18n":null,"productionBrowserSourceMaps":false,"optimizeFonts":true,"excludeDefaultMomentLocales":true,"serverRuntimeConfig":{},"publicRuntimeConfig":{},"reactProductionProfiling":false,"reactStrictMode":true,"httpAgentOptions":{"keepAlive":true},"outputFileTracing":true,"staticPageGenerationTimeout":60,"swcMinify":true,"output":"standalone","modularizeImports":{"@mui/icons-material":{"transform":"@mui/icons-material/{{member}}"},"lodash":{"transform":"lodash/{{member}}"}},"experimental":{"prerenderEarlyExit":false,"serverMinification":true,"serverSourceMaps":false,"linkNoTouchStart":false,"caseSensitiveRoutes":false,"clientRouterFilter":true,"clientRouterFilterRedirects":false,"fetchCacheKeyPrefix":"","middlewarePrefetch":"flexible","optimisticClientCache":true,"manualClientBasePath":false,"cpus":7,"memoryBasedWorkersCount":false,"isrFlushToDisk":true,"workerThreads":false,"optimizeCss":false,"nextScriptWorkers":false,"scrollRestoration":false,"externalDir":false,"disableOptimizedLoading":false,"gzipSize":true,"craCompat":false,"esmExternals":true,"fullySpecified":false,"outputFileTracingRoot":"/Users/waiting/Documents/VS/img prommpt/saasfly","swcTraceProfiling":false,"forceSwcTransforms":false,"largePageDataBytes":128000,"adjustFontFallbacks":false,"adjustFontFallbacksWithSizeAdjust":false,"typedRoutes":false,"instrumentationHook":false,"bundlePagesExternals":false,"parallelServerCompiles":false,"parallelServerBuildTraces":false,"ppr":false,"missingSuspenseWithCSRBailout":true,"optimizeServerReact":true,"useEarlyImport":false,"staleTimes":{"dynamic":30,"static":300},"mdxRs":true,"optimizePackageImports":["lucide-react","date-fns","lodash-es","ramda","antd","react-bootstrap","ahooks","@ant-design/icons","@headlessui/react","@headlessui-float/react","@heroicons/react/20/solid","@heroicons/react/24/solid","@heroicons/react/24/outline","@visx/visx","@tremor/react","rxjs","@mui/material","@mui/icons-material","recharts","react-use","@material-ui/core","@material-ui/icons","@tabler/icons-react","mui-core","react-icons/ai","react-icons/bi","react-icons/bs","react-icons/cg","react-icons/ci","react-icons/di","react-icons/fa","react-icons/fa6","react-icons/fc","react-icons/fi","react-icons/gi","react-icons/go","react-icons/gr","react-icons/hi","react-icons/hi2","react-icons/im","react-icons/io","react-icons/io5","react-icons/lia","react-icons/lib","react-icons/lu","react-icons/md","react-icons/pi","react-icons/ri","react-icons/rx","react-icons/si","react-icons/sl","react-icons/tb","react-icons/tfi","react-icons/ti","react-icons/vsc","react-icons/wi"],"skipTrailingSlashRedirect":true}

process.env.__NEXT_PRIVATE_STANDALONE_CONFIG = JSON.stringify(nextConfig)

require('next')
const { startServer } = require('next/dist/server/lib/start-server')

if (
  Number.isNaN(keepAliveTimeout) ||
  !Number.isFinite(keepAliveTimeout) ||
  keepAliveTimeout < 0
) {
  keepAliveTimeout = undefined
}

// Netlify serverless function handler
exports.handler = async (event, context) => {
  // For Netlify Functions, we need to simulate the HTTP server
  const url = new URL(event.path, `http://${event.headers.host}`)
  
  // Create a mock request object
  const request = {
    method: event.httpMethod,
    headers: event.headers,
    url: url.pathname + url.search,
  }

  try {
    // Start the Next.js server if not already started
    if (!global.__nextServer) {
      global.__nextServer = await startServer({
        dir,
        isDev: false,
        config: nextConfig,
        hostname,
        port: currentPort,
        allowRetry: false,
        keepAliveTimeout,
      })
    }

    // Handle the request through Next.js
    const response = await global.__nextServer.getRequestHandler()(request, {
      method: event.httpMethod,
      headers: event.headers,
      body: event.body,
    })

    // Return the response in Netlify format
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'text/html',
        ...response.headers,
      },
      body: response.body,
    }
  } catch (error) {
    console.error('Error handling request:', error)
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal Server Error' }),
    }
  }
}
EOF

echo "Netlify Functions server.js created"

# Verify no problematic files in output
echo "Verifying output files..."
find netlify-dist -name "*" | grep -E "[#?]" | while read file; do
    echo "Warning: Found problematic file in output: $file"
    rm -f "$file"
done

# List what we've created
echo "Build output contents:"
ls -la netlify-dist/

# Verify netlify-dist directory exists
if [ ! -d "netlify-dist" ]; then
    echo "❌ netlify-dist directory was not created!"
    exit 1
fi

# Verify functions directory exists
if [ ! -d "netlify-dist/functions" ]; then
    echo "❌ functions directory was not created!"
    exit 1
fi

echo "✅ Build completed successfully!"
echo "📁 Final build output located at: $(pwd)/netlify-dist"
echo "🔧 Netlify Functions configured in: $(pwd)/netlify-dist/functions"