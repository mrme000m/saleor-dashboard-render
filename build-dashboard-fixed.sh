#!/bin/bash

# Build script for Render deployment
# This script clones the Saleor Dashboard, builds it, and replaces environment variables

set -e

echo "=== Starting Saleor Dashboard build for Render ==="

# Print environment info
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "Current directory: $(pwd)"
echo "Available space: $(df -h . | tail -1)"

# Set default environment variables if not provided
export API_URL=${API_URL:-"https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/"}
export APP_MOUNT_URI=${APP_MOUNT_URI:-"/"}
export APPS_MARKETPLACE_API_URL=${APPS_MARKETPLACE_API_URL:-"https://apps.saleor.io/api/v2/saleor-apps"}
export EXTENSIONS_API_URL=${EXTENSIONS_API_URL:-""}
export APPS_TUNNEL_URL_KEYWORDS=${APPS_TUNNEL_URL_KEYWORDS:-".ngrok.io;.saleor.live;.trycloudflare.com"}
export IS_CLOUD_INSTANCE=${IS_CLOUD_INSTANCE:-"false"}
export LOCALE_CODE=${LOCALE_CODE:-"en"}

echo "=== Environment variables ==="
echo "API_URL: $API_URL"
echo "APP_MOUNT_URI: $APP_MOUNT_URI"
echo "APPS_MARKETPLACE_API_URL: $APPS_MARKETPLACE_API_URL"
echo "IS_CLOUD_INSTANCE: $IS_CLOUD_INSTANCE"
echo "LOCALE_CODE: $LOCALE_CODE"

# Clone the Saleor Dashboard repository
echo "=== Cloning Saleor Dashboard repository ==="
if [ -d "saleor-dashboard" ]; then
    echo "Removing existing saleor-dashboard directory..."
    rm -rf saleor-dashboard
fi

git clone --depth 1 --branch main https://github.com/saleor/saleor-dashboard.git saleor-dashboard
cd saleor-dashboard

echo "=== Repository cloned successfully ==="
echo "Current directory: $(pwd)"
echo "Files in directory: $(ls -la | wc -l) items"

# Install dependencies
echo "=== Installing dependencies ==="
npm ci --production=false

# Build the application
echo "=== Building the application ==="
npm run build

# Check if build was successful
if [ ! -d "dist" ]; then
    echo "ERROR: Build failed - dist directory not found!"
    exit 1
fi

echo "=== Build completed successfully ==="
echo "Dist directory contents:"
ls -la dist/

# Replace environment variables in the built index.html
echo "=== Replacing environment variables in index.html ==="
INDEX_FILE="./dist/index.html"

if [ -f "$INDEX_FILE" ]; then
    echo "Found index.html, replacing environment variables..."
    
    # Use more compatible sed syntax for Linux
    sed -i.bak "s|<%= API_URL %>|$API_URL|g" "$INDEX_FILE"
    sed -i.bak "s|<%= APP_MOUNT_URI %>|$APP_MOUNT_URI|g" "$INDEX_FILE"
    sed -i.bak "s|<%= APPS_MARKETPLACE_API_URL %>|$APPS_MARKETPLACE_API_URL|g" "$INDEX_FILE"
    sed -i.bak "s|<%= EXTENSIONS_API_URL %>|$EXTENSIONS_API_URL|g" "$INDEX_FILE"
    sed -i.bak "s|<%= APPS_TUNNEL_URL_KEYWORDS %>|$APPS_TUNNEL_URL_KEYWORDS|g" "$INDEX_FILE"
    sed -i.bak "s|<%= IS_CLOUD_INSTANCE %>|$IS_CLOUD_INSTANCE|g" "$INDEX_FILE"
    sed -i.bak "s|<%= LOCALE_CODE %>|$LOCALE_CODE|g" "$INDEX_FILE"
    
    echo "Environment variables replaced successfully!"
    
    # Show a sample of the config
    echo "Sample of window.__SALEOR_CONFIG__:"
    grep -A 5 -B 5 "window.__SALEOR_CONFIG__" "$INDEX_FILE" || echo "Config section not found (this might be normal)"
else
    echo "ERROR: $INDEX_FILE not found!"
    echo "Contents of dist directory:"
    ls -la dist/
    exit 1
fi

# Copy dist files to root for Render
echo "=== Copying build files to root directory ==="
cd ..
echo "Current directory: $(pwd)"

# Copy all files from dist to current directory
cp -r saleor-dashboard/dist/* ./

# Also copy the _redirects file to ensure SPA routing works
if [ -f "_redirects" ]; then
    echo "_redirects file already exists"
else
    echo "Creating _redirects file for SPA routing"
    echo "/*    /index.html   200" > _redirects
fi

echo "=== Final directory contents ==="
ls -la

echo "=== Build completed successfully! ==="
