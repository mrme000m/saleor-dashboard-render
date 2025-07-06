# Saleor Dashboard Deployment on Render

This repository contains the Saleor Dashboard configured for deployment on Render's free tier, connecting to your Heroku-hosted Saleor API.

## 🚀 Quick Deploy to Render

### Option 1: Deploy from GitHub (Recommended)

1. **Fork this repository** or push it to your GitHub account
2. **Connect to Render**:
   - Go to [Render Dashboard](https://dashboard.render.com/)
   - Click "New +" → "Static Site"
   - Connect your GitHub repository
   - Select this repository

3. **Configure the deployment**:
   - **Name**: `saleor-dashboard` (or your preferred name)
   - **Branch**: `main`
   - **Build Command**: `./build-for-render.sh`
   - **Publish Directory**: `dist`

4. **Set Environment Variables** (in Render dashboard):
   ```
   API_URL=https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/
   APP_MOUNT_URI=/
   APPS_MARKETPLACE_API_URL=https://apps.saleor.io/api/v2/saleor-apps
   EXTENSIONS_API_URL=
   APPS_TUNNEL_URL_KEYWORDS=.ngrok.io;.saleor.live;.trycloudflare.com
   IS_CLOUD_INSTANCE=false
   LOCALE_CODE=en
   NODE_VERSION=20
   ```

5. **Deploy**: Click "Create Static Site"

### Option 2: Deploy using render.yaml

1. **Push this repository** to GitHub
2. **Connect to Render**:
   - Go to [Render Dashboard](https://dashboard.render.com/)
   - Click "New +" → "Blueprint"
   - Connect your GitHub repository
   - Render will automatically detect the `render.yaml` file

3. **Deploy**: Follow the prompts to deploy

## 🔧 Configuration

### Environment Variables

The dashboard connects to your Saleor API using these environment variables:

- **API_URL**: Your Heroku Saleor API GraphQL endpoint
  - Default: `https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/`
- **APP_MOUNT_URI**: Dashboard mount path (usually `/`)
- **APPS_MARKETPLACE_API_URL**: Saleor Apps marketplace URL
- **EXTENSIONS_API_URL**: Extensions API URL (optional)
- **APPS_TUNNEL_URL_KEYWORDS**: Tunnel URL keywords for development
- **IS_CLOUD_INSTANCE**: Set to `false` for self-hosted instances
- **LOCALE_CODE**: Dashboard language (default: `en`)

### Updating API URL

If your Heroku API URL changes, update the `API_URL` environment variable in:
1. Render dashboard → Your service → Environment
2. Or update the `render.yaml` file and redeploy

## 🏗️ Build Process

The build process:
1. Installs dependencies with `npm ci`
2. Builds the React application with `npm run build`
3. Replaces environment variables in the generated `index.html`
4. Outputs static files to the `dist` directory

## 🔐 Access

Once deployed, you can access the dashboard at your Render URL (e.g., `https://your-dashboard.onrender.com`).

### Login Credentials

Use the credentials from your Heroku Saleor API:
- **Admin**: `admin@example.com` / `admin`
- **Test User**: `tu00@example.com` / `TestPassword123!`

## 🛠️ Local Development

To run the dashboard locally:

```bash
# Install dependencies
npm install

# Set environment variables
export API_URL=https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/

# Start development server
npm run dev
```

## 📝 Notes

- **Free Tier Limitations**: Render's free tier may have some limitations like sleep mode after inactivity
- **HTTPS**: Render automatically provides HTTPS for all deployments
- **Custom Domain**: You can configure a custom domain in Render's dashboard
- **Automatic Deploys**: Render will automatically redeploy when you push to the connected branch

## 🔄 Updates

To update the dashboard:
1. Pull the latest changes from the Saleor dashboard repository
2. Push to your GitHub repository
3. Render will automatically redeploy

## 🐛 Troubleshooting

### Dashboard won't load
- Check that the `API_URL` environment variable is correct
- Verify your Heroku API is running and accessible

### Build fails
- Check the build logs in Render dashboard
- Ensure all environment variables are set correctly
- Verify the `build-for-render.sh` script has execute permissions

### API connection issues
- Verify the API URL is accessible from the internet
- Check CORS settings in your Saleor API configuration
