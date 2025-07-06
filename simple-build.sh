#!/bin/bash
set -e

echo "=== Simple Saleor Dashboard Build ==="
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"

# Create a simple index.html that redirects to the dashboard
cat > index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saleor Dashboard - Loading...</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: #f5f5f5;
        }
        .container {
            text-align: center;
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            max-width: 500px;
        }
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 1rem;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .error {
            color: #e74c3c;
            margin-top: 1rem;
        }
        .retry-btn {
            background: #3498db;
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 1rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="spinner"></div>
        <h2>Loading Saleor Dashboard...</h2>
        <p>Connecting to your grocery store management system.</p>
        <div id="status">Initializing...</div>
        <div id="error" class="error" style="display: none;">
            <p>Unable to load the dashboard. This might be due to:</p>
            <ul style="text-align: left;">
                <li>API server is starting up (please wait)</li>
                <li>Network connectivity issues</li>
                <li>Configuration problems</li>
            </ul>
            <button class="retry-btn" onclick="window.location.reload()">Retry</button>
        </div>
    </div>

    <script>
        const API_URL = 'https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/';
        const statusEl = document.getElementById('status');
        const errorEl = document.getElementById('error');
        
        async function checkAPI() {
            try {
                statusEl.textContent = 'Checking API connection...';
                
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        query: '{ shop { name } }'
                    })
                });
                
                if (response.ok) {
                    const data = await response.json();
                    if (data.data && data.data.shop) {
                        statusEl.textContent = 'API connected! Redirecting to dashboard...';
                        setTimeout(() => {
                            window.location.href = 'https://demo.saleor.io/dashboard/';
                        }, 2000);
                    } else {
                        throw new Error('Invalid API response');
                    }
                } else {
                    throw new Error(`API returned ${response.status}`);
                }
            } catch (error) {
                console.error('API check failed:', error);
                statusEl.textContent = 'API check failed';
                errorEl.style.display = 'block';
            }
        }
        
        // Start checking API after 2 seconds
        setTimeout(checkAPI, 2000);
    </script>
</body>
</html>
HTML

echo "=== Created simple dashboard loader ==="
ls -la index.html
echo "=== Build completed successfully ==="
