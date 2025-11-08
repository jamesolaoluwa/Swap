# $wap API Documentation

Base URL (Production): `https://swap-backend.fly.dev`  
Base URL (Local): `http://localhost:8000`

**Interactive Docs**: `/docs` (Swagger UI)

---

## Endpoints

### 1. Health Check

**GET** `/healthz`

```bash
curl http://localhost:8000/healthz
```

**Response:**
```json
{
  "status": "healthy",
  "firebase": "connected",
  "qdrant": "connected"
}
```

---

### 2. Create/Update Profile

**POST** `/profiles/upsert`

```bash
curl -X POST http://localhost:8000/profiles/upsert \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "user123",
    "email": "dev@example.com",
    "display_name": "Jane Dev",
    "skills_to_offer": "Python, FastAPI, React",
    "services_needed": "Guitar lessons, Photography",
    "bio": "Full-stack developer",
    "city": "Lagos"
  }'
```

**Response:**
```json
{
  "uid": "user123",
  "email": "dev@example.com",
  "display_name": "Jane Dev",
  "skills_to_offer": "Python, FastAPI, React",
  "services_needed": "Guitar lessons, Photography",
  "bio": "Full-stack developer",
  "city": "Lagos",
  "created_at": "2025-11-08T10:30:00",
  "updated_at": "2025-11-08T10:30:00"
}
```

---

### 3. Get Profile

**GET** `/profiles/{uid}`

```bash
curl http://localhost:8000/profiles/user123
```

**Response:**
```json
{
  "uid": "user123",
  "email": "dev@example.com",
  "display_name": "Jane Dev",
  ...
}
```

---

### 4. Semantic Search

**POST** `/search`

Find users by natural language query with 3 search modes.

#### Mode: `offers` (default)
Find people who **can teach** what you want to learn.

```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "teach me guitar and music production",
    "mode": "offers",
    "limit": 5
  }'
```

#### Mode: `needs`
Find people who **want to learn** what you can teach.

```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Python programming",
    "mode": "needs",
    "limit": 5
  }'
```

#### Mode: `both`
Search **everything** (offers + needs).

```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "web development",
    "mode": "both",
    "limit": 10
  }'
```

**Response:**
```json
[
  {
    "uid": "musician_001",
    "display_name": "Mike Guitar",
    "skills_to_offer": "Guitar, Music production, Audio engineering",
    "services_needed": "Web development, UI design",
    "score": 0.87,
    "city": "Lagos"
  },
  {
    "uid": "producer_002",
    "display_name": "Sarah Beats",
    "skills_to_offer": "Music production, Piano, Mixing",
    "services_needed": "Python programming",
    "score": 0.82,
    "city": "Abuja"
  }
]
```

**Score**: 0.0 to 1.0 (higher = better match)

---

### 5. Reciprocal Matching

**POST** `/match/reciprocal`

Find **mutual skill exchange partners** (I teach you X, you teach me Y).

```bash
curl -X POST http://localhost:8000/match/reciprocal \
  -H "Content-Type: application/json" \
  -d '{
    "my_offer_text": "Python, FastAPI, Machine Learning",
    "my_need_text": "Guitar lessons, Music theory",
    "limit": 10
  }'
```

**Response:**
```json
[
  {
    "uid": "guitarist_123",
    "display_name": "John Music",
    "skills_to_offer": "Guitar, Music theory, Songwriting",
    "services_needed": "Python, API development",
    "score": 0.89,
    "explanation": "Strong mutual match: they teach what you need, you teach what they need"
  }
]
```

**Algorithm:**
1. Search **their offers** vs **my needs** → score A
2. Search **my offers** vs **their needs** → score B
3. **Harmonic mean**: `2*(A*B)/(A+B)`

Why harmonic mean? Penalizes lopsided matches:
- (0.9, 0.9) → 0.90 ✅ Great mutual match
- (0.9, 0.3) → 0.45 ❌ One-sided

---

## Request Schema

### ProfileCreate
```json
{
  "uid": "string (required)",
  "email": "string (required, validated)",
  "display_name": "string (optional)",
  "skills_to_offer": "string (optional)",
  "services_needed": "string (optional)",
  "bio": "string (optional)",
  "city": "string (optional)"
}
```

### SearchRequest
```json
{
  "query": "string (required)",
  "mode": "offers | needs | both (optional, default: offers)",
  "limit": "integer (optional, default: 10, max: 50)"
}
```

### ReciprocalMatchRequest
```json
{
  "my_offer_text": "string (required)",
  "my_need_text": "string (required)",
  "limit": "integer (optional, default: 10, max: 50)"
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Validation error message"
}
```

### 404 Not Found
```json
{
  "detail": "Profile not found"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal error message"
}
```

---

## Testing with Postman

### 1. Create Collection
- Name: `$wap Backend`
- Base URL: `{{base_url}}`
- Variable: `base_url = http://localhost:8000`

### 2. Add Requests

**Request 1: Health Check**
- Method: GET
- URL: `{{base_url}}/healthz`

**Request 2: Create Profile**
- Method: POST
- URL: `{{base_url}}/profiles/upsert`
- Body (raw JSON):
```json
{
  "uid": "test_user",
  "email": "test@example.com",
  "display_name": "Test User",
  "skills_to_offer": "Python, JavaScript",
  "services_needed": "Guitar, Photography"
}
```

**Request 3: Search (Offers)**
- Method: POST
- URL: `{{base_url}}/search`
- Body:
```json
{
  "query": "guitar lessons",
  "mode": "offers",
  "limit": 5
}
```

**Request 4: Reciprocal Match**
- Method: POST
- URL: `{{base_url}}/match/reciprocal`
- Body:
```json
{
  "my_offer_text": "Python programming",
  "my_need_text": "Guitar lessons",
  "limit": 10
}
```

---

## Performance

| Endpoint | Avg Latency | Notes |
|----------|-------------|-------|
| `/healthz` | ~1ms | Connection check only |
| `/profiles/upsert` | ~150ms | Firestore + Qdrant write |
| `/profiles/{uid}` | ~20ms | Firestore read |
| `/search` | ~80ms | ML inference + vector search |
| `/match/reciprocal` | ~120ms | Dual vector search |

*Tested on Fly.io (1GB RAM, 1 CPU)*

---

## Rate Limits

⚠️ **MVP - No rate limiting**

Production recommendation: 100 req/min per user

---

*For architecture details, see [ARCHITECTURE.md](ARCHITECTURE.md)*
