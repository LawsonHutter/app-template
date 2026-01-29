# How Your Domain Works - From URL to Your App

This explains the complete flow of how typing `dipoll.net` in your browser shows your app.

---

## 🌐 The Complete Journey

```
You type: https://dipoll.net
    ↓
DNS Lookup: dipoll.net → 52.73.150.104 (EC2 IP)
    ↓
Request hits EC2 server on port 443 (HTTPS)
    ↓
Nginx (reverse proxy) receives request
    ↓
Nginx routes to appropriate service:
    - / → Frontend container (Flutter web app)
    - /api/ → Backend container (Django API)
    ↓
Docker containers process request
    ↓
Response sent back through Nginx
    ↓
Your browser displays the app
```

---

## Step-by-Step Breakdown

### 1. DNS Resolution (Domain → IP)

**What happens:**
- You type `https://dipoll.net` in your browser
- Browser asks DNS servers: "What IP is dipoll.net?"
- DNS responds: "52.73.150.104"
- Browser connects to that IP

**Where configured:**
- At your domain registrar (GoDaddy, Namecheap, etc.)
- You set A records pointing `dipoll.net` → `52.73.150.104`

---

### 2. Request Arrives at EC2

**What happens:**
- Request arrives at EC2 instance IP: `52.73.150.104`
- Port 443 (HTTPS) or port 80 (HTTP, then redirects to HTTPS)
- EC2 security group allows these ports from anywhere

**Docker services running:**
- `nginx` container listening on ports 80 and 443
- `backend` container (Django) on port 8000 (internal)
- `frontend` container (Flutter) on port 80 (internal)
- `db` container (PostgreSQL) on port 5432 (internal)

---

### 3. Nginx Reverse Proxy (The Traffic Director)

**What Nginx does:**
Nginx acts as a **reverse proxy** - it receives all incoming requests and routes them to the right service.

**Configuration** (`infra/nginx/nginx.prod.conf`):

```nginx
# HTTPS server
server {
    listen 443 ssl http2;
    server_name dipoll.net www.dipoll.net;

    # Frontend (Flutter web app)
    location / {
        proxy_pass http://frontend:80;  # Routes to frontend container
    }

    # Backend API
    location /api/ {
        proxy_pass http://backend:8000;  # Routes to backend container
    }
}
```

**How it works:**
- Request to `https://dipoll.net/` → Goes to `frontend` container
- Request to `https://dipoll.net/api/counter/` → Goes to `backend` container
- Nginx uses Docker's internal network to communicate with containers

---

### 4. Docker Network (Container Communication)

**Docker Compose creates a network:**
```yaml
networks:
  survey-network:
    driver: bridge
```

**All containers are on this network:**
- `nginx` can reach `frontend` by name: `http://frontend:80`
- `nginx` can reach `backend` by name: `http://backend:8000`
- `backend` can reach `db` by name: `postgresql://db:5432`

**Why this works:**
- Docker DNS resolves container names to internal IPs
- Containers talk to each other using service names
- No need to know actual IP addresses

---

### 5. Frontend Container (Flutter Web App)

**What happens when you visit `https://dipoll.net/`:**

1. **Nginx receives request** → Routes to `frontend:80`
2. **Frontend container** (nginx serving Flutter):
   - Serves `index.html`
   - Serves compiled JavaScript (`main.dart.js`)
   - Serves assets (CSS, images, fonts)
3. **Browser loads the Flutter app**
4. **Flutter app makes API calls** to `https://dipoll.net/api/counter/`

**Frontend container contains:**
- Nginx web server
- Compiled Flutter web files (HTML, JS, CSS)
- All static assets

---

### 6. Backend Container (Django API)

**What happens when Flutter calls `https://dipoll.net/api/counter/`:**

1. **Nginx receives request** → Routes to `backend:8000`
2. **Backend container** (Django with Gunicorn):
   - Gunicorn receives request
   - Django processes it
   - Queries database if needed
   - Returns JSON response
3. **Response goes back through Nginx** → To browser

**Backend container contains:**
- Python 3.11
- Django framework
- Gunicorn (production server)
- Your Django code (`click_counter` app)
- Database connection to PostgreSQL

---

### 7. Database Container (PostgreSQL)

**What happens when backend needs data:**

1. **Django makes database query**
2. **Connects to** `postgresql://db:5432/survey_db`
3. **Database container** (PostgreSQL):
   - Executes query
   - Returns data
4. **Django processes data** → Returns JSON to frontend

**Database container contains:**
- PostgreSQL database server
- Your data (click counter values)
- Persistent storage (volume)

---

## 🔒 SSL/HTTPS (Security)

**How HTTPS works:**

1. **SSL Certificate** (from Let's Encrypt):
   - Stored in: `/etc/letsencrypt/live/dipoll.net/`
   - Proves your server owns `dipoll.net`
   - Enables encrypted connection

2. **Nginx configuration:**
```nginx
ssl_certificate /etc/letsencrypt/live/dipoll.net/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/dipoll.net/privkey.pem;
```

3. **Browser checks certificate** → Shows green lock 🔒

---

## 📊 Complete Request Flow Example

### Example: User clicks the counter button

```
1. User clicks button in Flutter app
   ↓
2. Flutter sends POST to: https://dipoll.net/api/counter/
   ↓
3. DNS resolves: dipoll.net → 52.73.150.104
   ↓
4. Request hits EC2 on port 443
   ↓
5. Nginx receives request
   - Sees /api/ path
   - Routes to: http://backend:8000/api/counter/
   ↓
6. Backend container (Gunicorn) receives request
   ↓
7. Django processes:
   - Increments counter in database
   - Queries: db container (PostgreSQL)
   ↓
8. Database returns updated count
   ↓
9. Django returns JSON: {"count": 5, "updated_at": "..."}
   ↓
10. Response goes: backend → nginx → browser
   ↓
11. Flutter app updates UI with new count
```

---

## 🐳 Docker's Role

### Why Docker?

**Without Docker:**
- Install Python, Django, Flutter, PostgreSQL, Nginx on server
- Configure each service manually
- Different versions on different machines
- Hard to reproduce environment

**With Docker:**
- Each service in isolated container
- Same environment everywhere
- Easy to start/stop/update
- All services work together automatically

### Docker Compose Orchestration

```yaml
services:
  nginx:      # Receives all traffic, routes to others
  frontend:   # Serves Flutter web app
  backend:    # Django API server
  db:         # PostgreSQL database
```

**Docker Compose:**
- Starts all containers together
- Creates network for communication
- Manages volumes (persistent data)
- Handles dependencies (backend waits for db)

---

## 🔧 Key Components Summary

| Component | Port | Purpose |
|-----------|------|---------|
| **Nginx** | 80, 443 | Reverse proxy, SSL, routes traffic |
| **Frontend** | 80 (internal) | Serves Flutter web app |
| **Backend** | 8000 (internal) | Django API server |
| **Database** | 5432 (internal) | PostgreSQL data storage |

**External ports (accessible from internet):**
- 80 (HTTP) → Redirects to HTTPS
- 443 (HTTPS) → Main entry point

**Internal ports (Docker network only):**
- Frontend: 80
- Backend: 8000
- Database: 5432

---

## 🎯 Why This Architecture?

### Separation of Concerns
- **Nginx**: Handles SSL, routing, static files
- **Frontend**: Just serves web app
- **Backend**: Just handles API logic
- **Database**: Just stores data

### Scalability
- Can run multiple backend containers
- Can add more frontend instances
- Database can be moved to RDS later

### Security
- Only Nginx exposed to internet
- Backend and database not directly accessible
- SSL encryption for all traffic

---

## 📝 Quick Reference

**When you type `https://dipoll.net`:**
1. DNS → `52.73.150.104`
2. EC2 security group → Allows port 443
3. Nginx container → Receives request
4. Routes `/` → Frontend container
5. Frontend serves Flutter app
6. App loads in browser

**When app calls API:**
1. Request to `https://dipoll.net/api/counter/`
2. Nginx routes `/api/` → Backend container
3. Backend processes → Queries database
4. Returns JSON → Frontend updates UI

---

**In simple terms:** Nginx is like a receptionist that directs visitors (requests) to the right department (container), and Docker makes sure all departments can talk to each other!
