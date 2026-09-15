# Deployment Guide

Deploy $wap backend to Fly.io.

## Prerequisites

- Fly.io account ([sign up](https://fly.io/))
- Fly CLI installed
- Firebase credentials JSON

## Install Fly CLI

### macOS

```bash
brew install flyctl
```

### Linux

```bash
curl -L https://fly.io/install.sh | sh
```

### Windows

```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

## Deploy Steps

### 1. Login

```bash
fly auth login
```

### 2. Launch App

```bash
# This creates the app
fly launch --no-deploy

# Answer prompts:
# - App name: wap-backend (or your choice)
# - Region: Choose closest to your users
# - Setup PostgreSQL? → No (we use Firestore)
# - Setup Redis? → No
```

### 3. Set Secrets

```bash
# Firebase credentials
fly secrets set FIREBASE_CREDENTIALS_JSON="$(cat firebase-credentials.json | jq -c .)"

# Azure OpenAI
fly secrets set AZURE_OPENAI_ENDPOINT="https://your-resource.openai.azure.com"
fly secrets set AZURE_OPENAI_API_KEY="your-key"
fly secrets set AZURE_OPENAI_API_VERSION="2024-02-01"
fly secrets set AZURE_EMBEDDING_DEPLOYMENT="text-embedding-3-small"

# Azure AI Search
fly secrets set AZURE_SEARCH_ENDPOINT="https://your-search.search.windows.net"
fly secrets set AZURE_SEARCH_API_KEY="your-key"
```

### 4. Deploy

```bash
fly deploy
```

### 5. Verify

```bash
# Check status
fly status

# View logs
fly logs

# Test health
curl https://your-app.fly.dev/healthz
```

## Azure Services Setup

### Azure OpenAI

1. Go to [Azure Portal](https://portal.azure.com)
2. Create an Azure OpenAI resource
3. Deploy `text-embedding-3-small` model
4. Get the endpoint and API key from the resource

### Azure AI Search

1. Create an Azure AI Search service in Azure Portal
2. Get the endpoint and admin API key
3. The index will be created automatically on first profile upsert

## Scaling

### Increase Memory

```bash
fly scale memory 1024
```

### Add Instances

```bash
fly scale count 2
```

## Monitoring

### View Logs

```bash
# Real-time
fly logs

# Historical
fly logs --history
```

### SSH Access

```bash
fly ssh console

# Inside: reindex Azure AI Search
python scripts/reindex.py
```

## CI/CD with GitHub Actions

### 1. Get API Token

```bash
fly auth token
```

### 2. Add to GitHub Secrets

1. Go to repo → Settings → Secrets → Actions
2. New secret: `FLY_API_TOKEN`
3. Paste token

### 3. Auto-Deploy

The workflow in `.github/workflows/cd.yml` will auto-deploy on push to `main`.

## Custom Domain (Optional)

```bash
# Add domain
fly certs add yourdomain.com

# Follow DNS instructions
fly certs show yourdomain.com
```

## Update Fly Config

Edit `fly.toml` if needed:

```toml
app = "wap-backend"
primary_region = "iad"

[env]
  # Azure services configured via secrets

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0

[[http_service.checks]]
  interval = "10s"
  timeout = "2s"
  grace_period = "5s"
  method = "GET"
  path = "/healthz"
```

## Costs

**Free Tier:**

- 3 shared-cpu-1x VMs
- 160GB storage

**Estimated Monthly (beyond free):**

- App (1GB RAM): ~$5-10
- Azure OpenAI: Pay-per-use (embeddings)
- Azure AI Search: ~$275/month (Basic tier) or pay-per-use

For MVP, free tier should be sufficient!

## Troubleshooting

### App won't start

```bash
fly logs
```

Common issues:

- Missing `FIREBASE_CREDENTIALS_JSON` secret
- Missing Azure OpenAI or Azure AI Search secrets
- Incorrect Azure endpoint URLs

### Need more memory

```bash
fly scale memory 2048
```

## Resources

- [Fly.io Docs](https://fly.io/docs)
- [Fly.io Community](https://community.fly.io)
