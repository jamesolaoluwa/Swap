# Deployment Guide

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [Fly.io CLI](https://fly.io/docs/hands-on/install-flyctl/)
- Firebase service account JSON
- Qdrant Cloud account (free tier)

---

## Local Development

### 1. Setup Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Save as `firebase-credentials.json` in `wap-backend/`

### 2. Start Services

```bash
cd wap-backend

# Start FastAPI + Qdrant
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop
docker-compose down
```

### 3. Test

```bash
# Health check
curl http://localhost:8000/healthz

# Create profile
curl -X POST http://localhost:8000/profiles/upsert \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "test_user",
    "email": "test@example.com",
    "display_name": "Test User",
    "skills_to_offer": "Python",
    "services_needed": "Guitar"
  }'

# Search
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "guitar", "limit": 5}'
```

**API Docs**: http://localhost:8000/docs

---

## Production Deployment (Fly.io)

### 1. Setup Qdrant Cloud

1. Go to [cloud.qdrant.io](https://cloud.qdrant.io)
2. Create free cluster
3. Note the **URL** and **API Key**

### 2. Setup Fly.io

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login
flyctl auth login

# Launch app (first time only)
cd wap-backend
flyctl launch

# Follow prompts:
# - App name: swap-backend (or your choice)
# - Region: Choose closest to users
# - Postgres? No
# - Deploy now? No (we need to set secrets first)
```

### 3. Set Secrets

```bash
# Firebase credentials
flyctl secrets set FIREBASE_CREDENTIALS_JSON="$(cat firebase-credentials.json)"

# Qdrant Cloud
flyctl secrets set QDRANT_URL="https://your-cluster.cloud.qdrant.io:6333"
flyctl secrets set QDRANT_API_KEY="your-api-key-here"
```

### 4. Deploy

```bash
flyctl deploy
```

**Deployment takes 2-3 minutes.**

### 5. Verify

```bash
# Check status
flyctl status

# View logs
flyctl logs

# Test health
curl https://your-app.fly.dev/healthz
```

---

## Environment Variables

### Local (Docker)
Set in `docker-compose.yml`:
```yaml
environment:
  - FIREBASE_CREDENTIALS_PATH=/app/firebase-credentials.json
  - QDRANT_HOST=qdrant
  - QDRANT_PORT=6333
```

### Production (Fly.io)
Set via secrets:
```bash
FIREBASE_CREDENTIALS_JSON    # Full JSON string
QDRANT_URL                   # https://cluster.cloud.qdrant.io:6333
QDRANT_API_KEY               # Your Qdrant API key
```

---

## Troubleshooting

### Local Issues

**Docker not found:**
```bash
# Install Docker Desktop
brew install --cask docker
# Launch Docker Desktop from Applications
```

**Port 8000 in use:**
```bash
# Find and kill process
lsof -ti:8000 | xargs kill -9
```

**Qdrant connection error:**
```bash
# Check Qdrant is running
docker ps | grep qdrant

# Restart services
docker-compose restart
```

### Production Issues

**502 Bad Gateway:**
```bash
# Check logs
flyctl logs

# Common causes:
# 1. Model loading timeout (first request slow)
# 2. Out of memory
# 3. Missing secrets

# Increase timeout in fly.toml:
[[http_service.checks]]
  timeout = '10s'
  grace_period = '60s'
```

**Service Unavailable:**
```bash
# Check app status
flyctl status

# Restart app
flyctl apps restart swap-backend

# Check secrets are set
flyctl secrets list
```

**Slow first request:**
- ML model loads on startup (see `app/main.py` lifespan)
- First request after deploy may take 5-10s
- Subsequent requests fast (~80ms)

---

## Scaling

### Vertical (More Resources)

Edit `fly.toml`:
```toml
[[vm]]
  memory = '2gb'  # Increase from 1gb
  cpu_kind = 'shared'
  cpus = 2        # Increase from 1
```

Deploy:
```bash
flyctl deploy
```

### Horizontal (More Machines)

```bash
# Scale to 2 machines
flyctl scale count 2

# Auto-scale
flyctl autoscale set min=1 max=3
```

---

## Monitoring

### Fly.io Dashboard
- https://fly.io/dashboard
- View metrics: CPU, memory, requests
- Check machine status

### Logs
```bash
# Tail logs
flyctl logs

# Specific machine
flyctl logs -i MACHINE_ID
```

### Health Check
```bash
# Production
curl https://your-app.fly.dev/healthz

# Local
curl http://localhost:8000/healthz
```

---

## Updating

### Code Changes

```bash
# Local: Rebuild
docker-compose up -d --build

# Production: Redeploy
flyctl deploy
```

### Secrets

```bash
flyctl secrets set KEY="new-value"
# App automatically restarts
```

---

## Costs

### Free Tier (Fly.io)
- 3 shared-cpu-1x machines
- 256MB RAM each
- 160GB outbound data/month

**Your app uses:**
- 1 machine (1GB RAM, 1 CPU)
- ~$5-10/month estimate

### Qdrant Cloud
- Free tier: 1GB storage
- Sufficient for ~10,000 profiles

---

*For API documentation, see [API.md](API.md)*

