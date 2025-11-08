# $wap Backend

> Intelligent skill-for-skill exchange platform powered by semantic search

FastAPI backend that uses machine learning to match users for reciprocal skill exchanges through natural language queries.

## 🎯 Key Features

- **Semantic Search** - Find skill matches using natural language (powered by BERT)
- **Reciprocal Matching** - Bidirectional algorithm finds mutual exchange partners
- **Vector Similarity** - Sub-100ms search using Qdrant vector database
- **NoSQL Storage** - Firebase Firestore for scalable profile data

## 🏗️ Tech Stack

- **FastAPI** - Modern Python web framework
- **sentence-transformers** - BERT embeddings (384-dimensional vectors)
- **Qdrant** - Vector similarity search with HNSW indexing
- **Firebase Firestore** - NoSQL database
- **Docker** - Containerization
- **Fly.io** - Production hosting

## 🚀 Quick Start

```bash
# Install
pip install -r requirements.txt

# Setup Firebase
# Download service account JSON → save as firebase-credentials.json

# Start services
docker-compose up -d

# Test
curl http://localhost:8000/healthz
```

## 📡 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/healthz` | GET | Health check |
| `/profiles/upsert` | POST | Create/update profile |
| `/profiles/{uid}` | GET | Get profile |
| `/search` | POST | Semantic search (3 modes) |
| `/match/reciprocal` | POST | Find mutual matches |

### Search Modes

- **`offers`**: Find people who can teach what you want to learn
- **`needs`**: Find people who want to learn what you can teach  
- **`both`**: Search everything

**Example:**
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "teach me guitar",
    "mode": "offers",
    "limit": 5
  }'
```

## 🧠 How It Works

### 1. Profile Creation
```
User data → Firebase Firestore (profile storage)
Skills text → ML Model → 384-dim vectors → Qdrant (search index)
```

### 2. Semantic Search
```
Query text → ML Model → Vector
→ Qdrant similarity search → Ranked results
```

### 3. Reciprocal Matching
```
My offer + need → 2 vectors
→ Bidirectional search (their offers vs my needs, my offers vs their needs)
→ Harmonic mean scoring → Top mutual matches
```

**Why Harmonic Mean?**
- Penalizes lopsided matches
- Both scores must be high
- Example: `(0.9, 0.3) → 0.45` not `0.6`

## 📊 Performance

| Operation | Latency | Notes |
|-----------|---------|-------|
| Search | ~80ms | Including ML inference |
| Profile Create | ~150ms | Firestore + Qdrant write |
| Profile Read | ~20ms | Firestore lookup |
| Reciprocal Match | ~120ms | Dual vector search |

*Tested: 1GB RAM, 1 CPU, 1000 profiles*

## 🏗️ Architecture

```
Flutter App
     ↓ HTTPS/REST
FastAPI Backend
     ├─→ Firebase Firestore (profiles)
     └─→ Qdrant (vectors)
```

### Project Structure
```
wap-backend/
├── app/
│   ├── main.py              # FastAPI app
│   ├── routers/             # API endpoints
│   ├── embeddings.py        # ML model
│   ├── firebase_db.py       # Firestore
│   ├── qdrant_client.py     # Vector DB
│   └── matching.py          # Algorithms
├── tests/                   # Unit tests
├── Dockerfile              
├── docker-compose.yml       # Local dev
└── requirements.txt
```

## 🚀 Production Deployment

**Live API:** `https://swap-backend.fly.dev`

```bash
# Deploy to Fly.io
flyctl deploy

# Set secrets
flyctl secrets set FIREBASE_CREDENTIALS_JSON="$(cat firebase-credentials.json)"
flyctl secrets set QDRANT_URL="https://your-cluster.cloud.qdrant.io:6333"
flyctl secrets set QDRANT_API_KEY="your-key"
```

## 📚 Documentation

- **Interactive API**: http://localhost:8000/docs (Swagger UI)
- **Full API Reference**: [docs/API.md](docs/API.md)
- **Deployment Guide**: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## 🧪 Testing

```bash
# Run tests
pytest tests/ -v --cov=app

# Test locally (all endpoints working ✅)
curl http://localhost:8000/healthz
```

## 🔐 Security Note

⚠️ **MVP - No authentication implemented**

For production, add:
- Firebase Auth JWT validation
- Rate limiting
- User ownership enforcement

## 📈 Future Enhancements

- [ ] Authentication & authorization
- [ ] User ratings & reviews
- [ ] In-app messaging
- [ ] Personalized rankings
- [ ] Multi-language support

## 📄 License

MIT License

---

**Built for BE Hackathon 2025** | [GitHub](https://github.com/BE-Hackathon-2025/Panthers)
