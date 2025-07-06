# Troubleshooting Render Deployment

## Common Issues and Solutions

### 1. Build Failed with Status 1

**Symptoms**: Deploy fails with "Exited with status 1 while building your code"

**Solutions**:
- Check the deploy logs in Render dashboard for specific error messages
- Ensure Node.js version is set to 20 in environment variables
- Verify all required environment variables are set

### 2. Git Clone Fails

**Symptoms**: "fatal: could not read Username for 'https://github.com'"

**Solutions**:
- Use `--depth 1` flag for shallow clone to reduce download size
- Ensure stable internet connection during build

### 3. NPM Install Fails

**Symptoms**: "npm ERR! code ENOTFOUND" or dependency installation errors

**Solutions**:
- Set `NPM_CONFIG_PRODUCTION=false` in environment variables
- Use `npm ci` instead of `npm install` for faster, reliable builds
- Check if package-lock.json exists in the cloned repository

### 4. Build Process Runs Out of Memory

**Symptoms**: "JavaScript heap out of memory" or build process killed

**Solutions**:
- Use `--max-old-space-size=4096` flag for Node.js
- Optimize build process by removing unnecessary files
- Use production build flags

### 5. Environment Variables Not Applied

**Symptoms**: Dashboard shows default configuration instead of your API URL

**Solutions**:
- Verify environment variables are set in Render dashboard
- Check sed command syntax for your operating system
- Ensure index.html contains the placeholder variables

## Debugging Steps

1. **Check Render Deploy Logs**:
   - Go to Render Dashboard → Your Service → Deploys
   - Click on the failed deploy to see detailed logs

2. **Verify Environment Variables**:
   - Go to Render Dashboard → Your Service → Environment
   - Ensure all required variables are set with correct values

3. **Test Build Locally** (if possible):
   ```bash
   export API_URL="https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/"
   ./build-dashboard-fixed.sh
   ```

4. **Check Repository Structure**:
   - Ensure all files are present in GitHub repository
   - Verify file permissions (build scripts should be executable)

## Current Configuration

- **API URL**: `https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/`
- **Node.js Version**: 20
- **Build Command**: `chmod +x ./build-dashboard-fixed.sh && ./build-dashboard-fixed.sh`
- **Publish Directory**: `./`

## Getting Help

If issues persist:
1. Check the full deploy logs in Render dashboard
2. Verify your Heroku API is accessible: `curl https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/`
3. Try redeploying from Render dashboard (sometimes temporary issues resolve themselves)
