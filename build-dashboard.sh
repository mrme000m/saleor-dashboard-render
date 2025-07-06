#!/bin/bash

# Build script for Render deployment
# This script clones the Saleor Dashboard, builds it, and replaces environment variables

set -e

echo "Starting Saleor Dashboard build for Render..."

# Clone the Saleor Dashboard repository if not already present
if [ ! -d "saleor-dashboard" ]; then
    echo "Cloning Saleor Dashboard repository..."
    git clone https://github.com/saleor/saleor-dashboard.git saleor-dashboard
    cd saleor-dashboard
else
    echo "Saleor Dashboard repository already exists, updating..."
    cd saleor-dashboard
    git pull origin main
fi

# Set default environment variables if not provided
export API_URL=${API_URL:-"https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/"}
export APP_MOUNT_URI=${APP_MOUNT_URI:-"/"}
export APPS_MARKETPLACE_API_URL=${APPS_MARKETPLACE_API_URL:-"https://apps.saleor.io/api/v2/saleor-apps"}
export EXTENSIONS_API_URL=${EXTENSIONS_API_URL:-""}
export APPS_TUNNEL_URL_KEYWORDS=${APPS_TUNNEL_URL_KEYWORDS:-".ngrok.io;.saleor.live;.trycloudflare.com"}
export IS_CLOUD_INSTANCE=${IS_CLOUD_INSTANCE:-"false"}
export LOCALE_CODE=${LOCALE_CODE:-"en"}

echo "Environment variables:"
echo "API_URL: $API_URL"

# Install dependencies
echo "Installing dependencies..."
npm ci

# Build the application
echo "Building the application..."
npm run build

# Replace environment variables in the built index.html
echo "Replacing environment variables in index.html..."
INDEX_FILE="./dist/index.html"

if [ -f "$INDEX_FILE" ]; then
    # Replace environment variables using sed
    sed -i "s|<%= API_URL %>|$API_URL|g" "$INDEX_FILE"
    sed -i "s|<%= APP_MOUNT_URI %>|$APP_MOUNT_URI|g" "$INDEX_FILE"
    sed -i "s|<%= APPS_MARKETPLACE_API_URL %>|$APPS_MARKETPLACE_API_URL|g" "$INDEX_FILE"
    sed -i "s|<%= EXTENSIONS_API_URL %>|$EXTENSIONS_API_URL|g" "$INDEX_FILE"
    sed -i "s|<%= APPS_TUNNEL_URL_KEYWORDS %>|$APPS_TUNNEL_URL_KEYWORDS|g" "$INDEX_FILE"
    sed -i "s|<%= IS_CLOUD_INSTANCE %>|$IS_CLOUD_INSTANCE|g" "$INDEX_FILE"
    sed -i "s|<%= LOCALE_CODE %>|$LOCALE_CODE|g" "$INDEX_FILE"
    
    echo "Environment variables replaced successfully!"
else
    echo "Error: $INDEX_FILE not found!"
    exit 1
fi

# Copy dist files to root for Render
echo "Copying build files to root directory..."
cp -r dist/* ../
cd ..

echo "Build completed successfully!"
