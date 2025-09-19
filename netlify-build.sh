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

# Copy server files for standalone mode
echo "Copying server files..."
if [ -f "saasfly/apps/nextjs/.next/standalone/apps/nextjs/server.js" ]; then
    cp saasfly/apps/nextjs/.next/standalone/apps/nextjs/server.js netlify-dist/
else
    echo "Error: server.js not found in standalone output!"
    exit 1
fi

if [ -d "saasfly/apps/nextjs/.next/standalone/apps/nextjs/.next/server" ]; then
    cp -r saasfly/apps/nextjs/.next/standalone/apps/nextjs/.next/server netlify-dist/
else
    echo "Error: server directory not found in standalone output!"
    exit 1
fi

# Copy locale-specific static pages
echo "Copying locale-specific static pages..."
LOCALE_DIR="saasfly/apps/nextjs/.next/standalone/apps/nextjs/.next/server/app"

if [ -d "$LOCALE_DIR/en" ]; then
  echo "Copying English locale pages..."
  mkdir -p netlify-dist/en
  cp -r "$LOCALE_DIR/en"/* netlify-dist/en/
else
  echo "Warning: English locale directory not found"
fi

if [ -d "$LOCALE_DIR/zh" ]; then
  echo "Copying Chinese locale pages..."
  mkdir -p netlify-dist/zh
  cp -r "$LOCALE_DIR/zh"/* netlify-dist/zh/
else
  echo "Warning: Chinese locale directory not found"
fi

if [ -d "$LOCALE_DIR/ko" ]; then
  echo "Copying Korean locale pages..."
  mkdir -p netlify-dist/ko
  cp -r "$LOCALE_DIR/ko"/* netlify-dist/ko/
else
  echo "Warning: Korean locale directory not found"
fi

if [ -d "$LOCALE_DIR/ja" ]; then
  echo "Copying Japanese locale pages..."
  mkdir -p netlify-dist/ja
  cp -r "$LOCALE_DIR/ja"/* netlify-dist/ja/
else
  echo "Warning: Japanese locale directory not found"
fi

# Create root index files for each locale
echo "Creating root index files..."
for locale in en zh ko ja; do
  if [ -d "netlify-dist/$locale" ]; then
    # Copy the locale's page to root for direct access
    cp -r netlify-dist/$locale/* netlify-dist/ 2>/dev/null || true
  fi
done

# Copy main index.html to root directory
echo "Copying main index.html to root directory..."
if [ -f "netlify-dist/server/app/index.html" ]; then
    cp netlify-dist/server/app/index.html netlify-dist/
    echo "Main index.html copied to root"
else
    echo "Warning: Main index.html not found"
fi

# Create locale-specific HTML files for Netlify routing
echo "Creating locale-specific HTML files..."
for locale in en zh ko ja; do
    if [ -f "netlify-dist/server/app/index.html" ]; then
        cp netlify-dist/server/app/index.html "netlify-dist/$locale.html"
        echo "Created $locale.html"
    fi
done

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

echo "✅ Build completed successfully!"
echo "📁 Final build output located at: $(pwd)/netlify-dist"