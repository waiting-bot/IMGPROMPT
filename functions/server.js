const path = require('path')

// Set correct directory for Netlify Functions - use standalone output
const dir = path.join(__dirname, '..', 'netlify-dist', 'apps', 'nextjs')

process.env.NODE_ENV = 'production'
process.chdir(dir)

const currentPort = parseInt(process.env.PORT, 10) || 3000
const hostname = process.env.HOSTNAME || '0.0.0.0'

let keepAliveTimeout = parseInt(process.env.KEEP_ALIVE_TIMEOUT, 10)

// Simplified Next.js config for standalone mode
const nextConfig = {
  output: 'standalone',
  distDir: '.next',
  cleanDistDir: true,
  assetPrefix: '',
  generateEtags: true,
  poweredByHeader: true,
  compress: true,
  swcMinify: true,
  trailingSlash: true,
  images: {
    domains: ['images.unsplash.com', 'avatars.githubusercontent.com'],
    unoptimized: false
  }
}

process.env.__NEXT_PRIVATE_STANDALONE_CONFIG = JSON.stringify(nextConfig)

// Load Next.js from the standalone installation
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
  try {
    // For Netlify Functions, handle the request directly
    const url = new URL(event.path, `http://${event.headers.host}`)
    
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

    // Create request object
    const request = {
      method: event.httpMethod,
      headers: event.headers,
      url: url.pathname + url.search,
    }

    // Handle the request through Next.js
    const response = await global.__nextServer.getRequestHandler()(request, {
      method: event.httpMethod,
      headers: event.headers,
      body: event.body,
    })

    // Return the response in Netlify format
    return {
      statusCode: response.statusCode || 200,
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        ...response.headers,
      },
      body: response.body || '',
    }
  } catch (error) {
    console.error('Error in Netlify Function:', error)
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ 
        error: 'Internal Server Error',
        message: error.message 
      }),
    }
  }
}