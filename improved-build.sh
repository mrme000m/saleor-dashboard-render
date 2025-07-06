#!/bin/bash
set -e

echo "=== Improved Saleor Dashboard Build ==="
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"

# Create a functional dashboard interface
cat > index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saleor Dashboard - Dhaka Grocery Supplier</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8f9fa; color: #333; }
        .loading-container { display: flex; justify-content: center; align-items: center; min-height: 100vh; background: #f5f5f5; }
        .loading-box { text-align: center; background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-width: 500px; }
        .spinner { border: 4px solid #f3f3f3; border-top: 4px solid #3498db; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto 1rem; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .error { color: #e74c3c; margin-top: 1rem; }
        .retry-btn { background: #3498db; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer; margin-top: 1rem; }
        .dashboard { display: none; min-height: 100vh; }
        .header { background: #2c3e50; color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 1.5rem; font-weight: bold; }
        .user-info { font-size: 0.9rem; }
        .main-content { display: flex; min-height: calc(100vh - 70px); }
        .sidebar { width: 250px; background: white; border-right: 1px solid #e0e0e0; padding: 1rem 0; }
        .nav-item { padding: 0.75rem 1.5rem; cursor: pointer; border-bottom: 1px solid #f0f0f0; transition: background 0.2s; }
        .nav-item:hover { background: #f8f9fa; }
        .nav-item.active { background: #e3f2fd; border-right: 3px solid #2196f3; }
        .content { flex: 1; padding: 2rem; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stat-value { font-size: 2rem; font-weight: bold; color: #2c3e50; }
        .stat-label { color: #666; margin-top: 0.5rem; }
        .section { background: white; border-radius: 8px; padding: 1.5rem; margin-bottom: 1rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .section h3 { margin-bottom: 1rem; color: #2c3e50; }
        .api-status { display: inline-block; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.8rem; font-weight: bold; }
        .api-status.connected { background: #d4edda; color: #155724; }
        .api-status.error { background: #f8d7da; color: #721c24; }
        .btn { background: #3498db; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer; margin: 0.25rem; }
        .btn:hover { background: #2980b9; }
        .btn.success { background: #27ae60; }
        .btn.success:hover { background: #229954; }
    </style>
</head>
<body>
    <div id="loading" class="loading-container">
        <div class="loading-box">
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
    </div>

    <div id="dashboard" class="dashboard">
        <div class="header">
            <div class="logo">🛒 Saleor Dashboard</div>
            <div class="user-info">
                <span id="shop-name">Dhaka Grocery Supplier</span>
                <span class="api-status connected" id="api-status">API Connected</span>
            </div>
        </div>
        <div class="main-content">
            <div class="sidebar">
                <div class="nav-item active" onclick="showSection('overview')">📊 Overview</div>
                <div class="nav-item" onclick="showSection('products')">📦 Products</div>
                <div class="nav-item" onclick="showSection('orders')">��️ Orders</div>
                <div class="nav-item" onclick="showSection('customers')">👥 Customers</div>
                <div class="nav-item" onclick="showSection('settings')">⚙️ Settings</div>
                <div class="nav-item" onclick="openGraphQL()">🔧 GraphQL Playground</div>
            </div>
            <div class="content">
                <div id="overview-section">
                    <h2>Dashboard Overview</h2>
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value" id="total-products">-</div>
                            <div class="stat-label">Total Products</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" id="total-orders">-</div>
                            <div class="stat-label">Total Orders</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" id="total-customers">-</div>
                            <div class="stat-label">Total Customers</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" id="total-categories">-</div>
                            <div class="stat-label">Categories</div>
                        </div>
                    </div>
                    
                    <div class="section">
                        <h3>Quick Actions</h3>
                        <button class="btn" onclick="loadProducts()">View Products</button>
                        <button class="btn" onclick="loadOrders()">View Orders</button>
                        <button class="btn success" onclick="openGraphQL()">Open GraphQL Playground</button>
                    </div>
                    
                    <div class="section">
                        <h3>API Connection Status</h3>
                        <p>✅ Connected to: <strong>https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/</strong></p>
                        <p>🏪 Store: <span id="store-name">Dhaka Grocery Supplier</span></p>
                        <p>📝 Description: <span id="store-description">Fresh groceries delivered to your business</span></p>
                    </div>
                </div>
                
                <div id="products-section" style="display: none;">
                    <h2>Products Management</h2>
                    <div class="section">
                        <h3>Product List</h3>
                        <div id="products-list">Loading products...</div>
                    </div>
                </div>
                
                <div id="orders-section" style="display: none;">
                    <h2>Orders Management</h2>
                    <div class="section">
                        <h3>Recent Orders</h3>
                        <div id="orders-list">Loading orders...</div>
                    </div>
                </div>
                
                <div id="customers-section" style="display: none;">
                    <h2>Customer Management</h2>
                    <div class="section">
                        <h3>Customer List</h3>
                        <div id="customers-list">Loading customers...</div>
                    </div>
                </div>
                
                <div id="settings-section" style="display: none;">
                    <h2>Settings</h2>
                    <div class="section">
                        <h3>Store Configuration</h3>
                        <p>This is a simplified dashboard interface. For full administrative features, you would typically use the complete Saleor Dashboard application.</p>
                        <p><strong>API Endpoint:</strong> https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/</p>
                        <p><strong>Dashboard Type:</strong> Simplified Web Interface</p>
                        <button class="btn success" onclick="openGraphQL()">Access Full GraphQL API</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const API_URL = 'https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/';
        const statusEl = document.getElementById('status');
        const errorEl = document.getElementById('error');
        let shopData = null;
        
        async function checkAPI() {
            try {
                statusEl.textContent = 'Checking API connection...';
                
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        query: '{ shop { name description } }'
                    })
                });
                
                if (response.ok) {
                    const data = await response.json();
                    if (data.data && data.data.shop) {
                        shopData = data.data.shop;
                        statusEl.textContent = 'API connected! Loading dashboard...';
                        setTimeout(() => showDashboard(), 1000);
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
        
        function showDashboard() {
            document.getElementById('loading').style.display = 'none';
            document.getElementById('dashboard').style.display = 'block';
            
            if (shopData) {
                document.getElementById('shop-name').textContent = shopData.name;
                document.getElementById('store-name').textContent = shopData.name;
                document.getElementById('store-description').textContent = shopData.description;
            }
            
            loadStats();
        }
        
        async function loadStats() {
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        query: `{
                            products(first: 100) { totalCount }
                            orders(first: 100) { totalCount }
                            users(first: 100) { totalCount }
                            categories(first: 100) { totalCount }
                        }`
                    })
                });
                
                if (response.ok) {
                    const data = await response.json();
                    if (data.data) {
                        document.getElementById('total-products').textContent = data.data.products.totalCount;
                        document.getElementById('total-orders').textContent = data.data.orders.totalCount;
                        document.getElementById('total-customers').textContent = data.data.users.totalCount;
                        document.getElementById('total-categories').textContent = data.data.categories.totalCount;
                    }
                }
            } catch (error) {
                console.error('Failed to load stats:', error);
            }
        }
        
        function showSection(section) {
            // Hide all sections
            document.querySelectorAll('[id$="-section"]').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
            
            // Show selected section
            document.getElementById(section + '-section').style.display = 'block';
            event.target.classList.add('active');
            
            // Load section-specific data
            if (section === 'products') loadProducts();
            else if (section === 'orders') loadOrders();
            else if (section === 'customers') loadCustomers();
        }
        
        async function loadProducts() {
            const container = document.getElementById('products-list');
            container.innerHTML = 'Loading products...';
            
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        query: `{
                            products(first: 10) {
                                edges {
                                    node {
                                        id
                                        name
                                        description
                                        category { name }
                                    }
                                }
                            }
                        }`
                    })
                });
                
                if (response.ok) {
                    const data = await response.json();
                    if (data.data && data.data.products) {
                        const products = data.data.products.edges;
                        container.innerHTML = products.map(p => `
                            <div style="border: 1px solid #ddd; padding: 1rem; margin: 0.5rem 0; border-radius: 4px;">
                                <h4>${p.node.name}</h4>
                                <p>${p.node.description || 'No description'}</p>
                                <small>Category: ${p.node.category?.name || 'Uncategorized'}</small>
                            </div>
                        `).join('');
                    }
                }
            } catch (error) {
                container.innerHTML = 'Error loading products: ' + error.message;
            }
        }
        
        async function loadOrders() {
            const container = document.getElementById('orders-list');
            container.innerHTML = 'Loading orders...';
            
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        query: `{
                            orders(first: 10) {
                                edges {
                                    node {
                                        id
                                        number
                                        status
                                        created
                                        total { gross { amount currency } }
                                    }
                                }
                            }
                        }`
                    })
                });
                
                if (response.ok) {
                    const data = await response.json();
                    if (data.data && data.data.orders) {
                        const orders = data.data.orders.edges;
                        container.innerHTML = orders.length ? orders.map(o => `
                            <div style="border: 1px solid #ddd; padding: 1rem; margin: 0.5rem 0; border-radius: 4px;">
                                <h4>Order #${o.node.number}</h4>
                                <p>Status: ${o.node.status}</p>
                                <p>Total: ${o.node.total.gross.amount} ${o.node.total.gross.currency}</p>
                                <small>Created: ${new Date(o.node.created).toLocaleDateString()}</small>
                            </div>
                        `).join('') : '<p>No orders found.</p>';
                    }
                }
            } catch (error) {
                container.innerHTML = 'Error loading orders: ' + error.message;
            }
        }
        
        async function loadCustomers() {
            const container = document.getElementById('customers-list');
            container.innerHTML = 'Loading customers...';
            
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        query: `{
                            users(first: 10) {
                                edges {
                                    node {
                                        id
                                        email
                                        firstName
                                        lastName
                                        dateJoined
                                    }
                                }
                            }
                        }`
                    })
                });
                
                if (response.ok) {
                    const data = await response.json();
                    if (data.data && data.data.users) {
                        const users = data.data.users.edges;
                        container.innerHTML = users.length ? users.map(u => `
                            <div style="border: 1px solid #ddd; padding: 1rem; margin: 0.5rem 0; border-radius: 4px;">
                                <h4>${u.node.firstName} ${u.node.lastName}</h4>
                                <p>Email: ${u.node.email}</p>
                                <small>Joined: ${new Date(u.node.dateJoined).toLocaleDateString()}</small>
                            </div>
                        `).join('') : '<p>No customers found.</p>';
                    }
                }
            } catch (error) {
                container.innerHTML = 'Error loading customers: ' + error.message;
            }
        }
        
        function openGraphQL() {
            window.open('https://rb00-saleor-api-46439a8b0dc8.herokuapp.com/graphql/', '_blank');
        }
        
        // Start checking API after 2 seconds
        setTimeout(checkAPI, 2000);
    </script>
</body>
</html>
HTML

echo "=== Created functional dashboard interface ==="
ls -la index.html
echo "=== Build completed successfully ==="
