# $wap Backend

Backend API for a skill exchange app. Matches users based on what they can teach and what they want to learn.

## What it does

- Semantic search using BERT embeddings to find relevant skill matches
- Reciprocal matching algorithm (finds people where both sides benefit)
- Uses Qdrant for vector search (~80ms) and Redis for caching (~5ms)
- Stores user profiles in Firebase Firestore

## Tech Stack

- FastAPI
- sentence-transformers (BERT, 384-dim vectors)
- Qdrant (vector database)
- Firebase Firestore
- Redis (caching layer)
- Docker
- Deployed on Fly.io

## Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Add Firebase credentials
# Download service account JSON and save as firebase-credentials.json

# Start local services (Qdrant + Redis)
docker-compose up -d

# Run the server
uvicorn app.main:app --reload

# Test it works
curl http://localhost:8000/healthz
```

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/healthz` | GET | Health check |
| `/profiles/upsert` | POST | Create/update profile |
| `/profiles/{uid}` | GET | Get profile |
| `/search` | POST | Semantic search (3 modes) |
| `/search/recommend-skills` | POST | Get skill recommendations |
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

### Skill Recommendations

Get personalized skill recommendations based on what you already know.

**Endpoint:** `POST /search/recommend-skills`

**How it works:**
1. Analyzes profiles with similar skills to yours
2. Extracts complementary skills that commonly appear together
3. Ranks by frequency and relevance
4. Returns top recommendations with reasoning

**Request:**
```bash
curl -X POST http://localhost:8000/search/recommend-skills \
  -H "Content-Type: application/json" \
  -d '{
    "current_skills": "Python programming and web development",
    "limit": 5
  }'
```

**Response:**
```json
[
  {
    "skill": "SQL databases and data modeling",
    "score": 0.845,
    "reason": "Common among 12 similar profiles"
  },
  {
    "skill": "Docker containerization", 
    "score": 0.732,
    "reason": "Common among 8 similar profiles"
  }
]
```

**Features:**
- Cached for 2 hours (fast repeat queries)
- Analyzes both what people teach and want to learn
- Smart scoring: balances frequency (how common) + relevance (how similar)
- Filters out short/vague skills

## How it works

**Profile Creation:**
1. User data gets saved to Firebase Firestore
2. Skills text gets converted to 384-dim vectors using BERT
3. Vectors stored in Qdrant for similarity search

**Semantic Search:**
1. Query text → convert to vector
2. Search Qdrant for similar vectors
3. Return ranked results

**Reciprocal Matching:**
1. Take what I offer + what I need → create 2 vectors
2. Run bidirectional search (my offers vs their needs, their offers vs my needs)
3. Score using harmonic mean (penalizes one-sided matches)
4. Return top mutual matches

The harmonic mean is useful here because it only gives high scores when both sides match well. For example, scores of (0.9, 0.3) → 0.45 not 0.6.

## Performance

| Operation | Cached | Uncached |
|-----------|--------|----------|
| Search | ~5ms | ~80ms |
| Profile Create | - | ~150ms |
| Profile Read | - | ~20ms |
| Reciprocal Match | ~8ms | ~120ms |

Tested with 1GB RAM, 1 CPU, 1000 profiles.

### Caching

Redis caching speeds up repeat queries by about 16x:

```
Search Request → Check Redis → Hit? Return (5ms)
                             → Miss? Query Qdrant (80ms) → Cache for 1hr
```

Cache automatically invalidates when profiles update. The app works fine without Redis if it's unavailable.

Currently only running in local dev (docker-compose). Not on production yet since the free Fly.io tier doesn't include Redis.

## Architecture

```
Flutter App
     ↓
FastAPI Backend
     ├─→ Redis (optional cache)
     ├─→ Firebase Firestore (user profiles)
     └─→ Qdrant (vector search)
```

### Project Structure
```
wap-backend/
├── app/
│   ├── main.py              # FastAPI app
│   ├── routers/             # API endpoints
│   ├── embeddings.py        # BERT model
│   ├── firebase_db.py       # Firestore client
│   ├── qdrant_client.py     # Vector DB client
│   ├── cache.py             # Redis caching
│   └── matching.py          # Matching algorithms
├── tests/
├── Dockerfile
├── docker-compose.yml
└── requirements.txt
```

## Deployment

Live API: `https://swap-backend.fly.dev`

Deploy to Fly.io:
```bash
flyctl deploy

# Set secrets
flyctl secrets set FIREBASE_CREDENTIALS_JSON="$(cat firebase-credentials.json)"
flyctl secrets set QDRANT_URL="https://your-cluster.cloud.qdrant.io:6333"
flyctl secrets set QDRANT_API_KEY="your-key"
```

## Docs

- Interactive API docs: http://localhost:8000/docs
- API reference: [docs/API.md](docs/API.md)
- Deployment guide: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## Testing

```bash
pytest tests/ -v --cov=app

# Test locally
curl http://localhost:8000/healthz
```

## Security

Currently no authentication (it's an MVP). For production you'd want:
- Firebase Auth JWT validation
- Rate limiting
- User ownership checks

## TODO

- Authentication
- User ratings/reviews
- In-app messaging
- Better ranking algorithm
- Multi-language support

## License

MIT
