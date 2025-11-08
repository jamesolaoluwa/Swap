# $wap Backend Architecture

## System Overview

```
┌─────────────┐
│ Flutter App │
└──────┬──────┘
       │ HTTPS/REST
       ▼
┌──────────────────┐
│  FastAPI Backend │
│  ┌────────────┐  │
│  │  Routers   │  │
│  ├────────────┤  │
│  │  Services  │  │
│  ├────────────┤  │
│  │ ML Model   │  │
│  └────────────┘  │
└───┬──────────┬───┘
    │          │
    ▼          ▼
┌─────────┐ ┌────────┐
│Firebase │ │Qdrant  │
│Firestore│ │Vectors │
└─────────┘ └────────┘
```

## Request Flow

### Profile Creation
```
1. POST /profiles/upsert
   ↓
2. Validate with Pydantic
   ↓
3. Firebase: Store profile data
   ↓
4. ML Model: Generate embeddings (skills → vectors)
   ↓
5. Qdrant: Store vectors for search
   ↓
6. Return profile
```

### Semantic Search
```
1. POST /search {"query": "guitar", "mode": "offers"}
   ↓
2. ML Model: query → 384-dim vector
   ↓
3. Qdrant: Vector similarity search
   ↓
4. Firebase: Fetch full profiles
   ↓
5. Return ranked results
```

### Reciprocal Matching
```
1. POST /match/reciprocal
   {
     "my_offer_text": "Python",
     "my_need_text": "Guitar"
   }
   ↓
2. Generate 2 vectors (offer_vec, need_vec)
   ↓
3. Search their offers vs my needs
   ↓
4. Search my offers vs their needs
   ↓
5. Calculate harmonic mean:
   score = 2*(a*b)/(a+b)
   ↓
6. Return top matches
```

## Data Models

### Profile Schema
```python
{
  "uid": string (required),
  "email": string (required, validated),
  "display_name": string,
  "skills_to_offer": string,     # → offer_vec (384-dim)
  "services_needed": string,     # → need_vec (384-dim)
  "bio": string,
  "city": string,
  "created_at": timestamp,
  "updated_at": timestamp
}
```

### Vector Storage (Qdrant)
```python
{
  "id": UUID(uid),
  "vector": {
    "offer_vec": [0.1, -0.2, ...],  # 384 floats
    "need_vec": [0.3, 0.4, ...]     # 384 floats
  },
  "payload": {profile_data}
}
```

## Technology Choices

### Why sentence-transformers?
- 95% accuracy of BERT at 4x smaller size
- 384 dimensions vs 768 (BERT)
- Fast inference (~10-20ms)
- Pre-trained on semantic similarity

### Why Qdrant?
- Named vectors (2 vectors per user: offers + needs)
- HNSW index (fast ~O(log n) search)
- Simple API
- Cloud + self-hosted options

### Why Firebase?
- NoSQL flexibility
- Automatic scaling
- Built-in indexing
- Real-time capabilities (future)

### Why FastAPI?
- Automatic API docs
- Type validation with Pydantic
- High performance (async capable)
- Modern Python standards

## Performance Optimizations

1. **Model Pre-loading**: Load ML model on startup (not first request)
2. **Vector Indexing**: HNSW for O(log n) search
3. **Connection Pooling**: Reuse Firebase/Qdrant connections
4. **Batch Fetching**: Get multiple profiles in one query

## Scalability

### Current Capacity
- 1GB RAM, 1 CPU
- ~1000 profiles
- ~10-50 req/s

### Scaling Strategy
1. **Horizontal**: Add more Fly.io machines
2. **Database**: Firestore auto-scales
3. **Vectors**: Qdrant Cloud scales to millions
4. **Caching**: Add Redis for frequent queries

## Security (Production TODO)

Current: No auth (MVP)

Production needs:
1. Firebase Auth JWT validation
2. Rate limiting (per user)
3. CORS configuration
4. Input sanitization (✅ done via Pydantic)

## Deployment

### Local Development
```bash
docker-compose up -d
# → FastAPI (port 8000)
# → Qdrant (port 6333)
```

### Production (Fly.io)
```bash
flyctl deploy
# → Builds Docker image
# → Deploys to global edge
# → Auto HTTPS
```

**Environment Variables:**
- `FIREBASE_CREDENTIALS_JSON`: Service account
- `QDRANT_URL`: Vector DB endpoint
- `QDRANT_API_KEY`: Auth key

## Monitoring

- **Health Check**: `/healthz` (1ms response)
- **Fly.io Metrics**: CPU, memory, requests
- **Application Logs**: stdout/stderr

---

*For detailed API documentation, see [API.md](API.md)*

