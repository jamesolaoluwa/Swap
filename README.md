# $wap

<img width="1411" height="625" alt="Screenshot 2025-11-08 at 1 12 02 AM" src="https://github.com/user-attachments/assets/78ca44bf-da91-40f6-87ad-34f9039469d5" />
<img width="1411" height="394" alt="Screenshot 2025-11-08 at 1 14 13 AM" src="https://github.com/user-attachments/assets/759a45b7-3e87-41f8-85ac-462b0f4aa8fa" />
<img width="1512" height="855" alt="Screenshot 2025-11-08 at 1 02 41 AM" src="https://github.com/user-attachments/assets/80a62cd2-2c5b-40ee-9871-e04365dee102" />
<img width="1195" height="761" alt="Screenshot 2025-11-08 at 1 05 32 AM" src="https://github.com/user-attachments/assets/251be873-25f8-4cdc-9bc7-f48cbf093c52" />
<img width="1507" height="863" alt="Screenshot 2025-11-08 at 1 06 08 AM" src="https://github.com/user-attachments/assets/47d7ac78-e97e-47f1-b782-7f0a9d0dce6b" />
<img width="1507" height="863" alt="Screenshot 2025-11-08 at 1 06 40 AM" src="https://github.com/user-attachments/assets/ddd18e3c-41d1-4bbe-b69e-5660e0367ccb" />
<img width="1507" height="863" alt="Screenshot 2025-11-08 at 1 06 47 AM" src="https://github.com/user-attachments/assets/fe64da47-431d-4636-94c0-6d2795b4b39f" />

## Challenge Statement

In Arkansas, thousands of people have talent, but limited access to opportunity. Small businesses make up **99.3% of all enterprises (≈ 258,000)**, yet the state still ranks **40th out of 51** in overall economic activity.

Rising costs mean many small business owners skip professional services — not because they lack vision, but because every dollar goes toward staying open. At the same time, college students and freelancers across Little Rock possess valuable skills they can’t fully use or afford to market.  

The problem isn’t a lack of ability. it’s a **lack of access**.  

**$wap** addresses this by asking:  
- How might we help communities unlock value without relying on money?  
- How might we turn *“what you can do”* into *“what you need”*?  
- How might AI connect people so skills never go unused?
  
## Project Description  

**$wap** is an AI-powered skill-exchange platform that lets people **trade skills instead of cash**. It creates a new, inclusive economy where your abilities — not your wallet — open doors.  

### How It Works  
1. **Create a Profile** — List the skills you can offer and what you need.  
2. **AI Matchmaking** — Machine learning pairs you with users whose skills and availability fit yours.  
3. **Swap Fairly** — Exchange services, time, or expertise — no money required.  
4. **Earn & Redeem Credits** — Every successful swap earns credibility and “swap credits.”  
5. **Build Trust** — Ratings and feedback verify quality and accountability.  

### Example  
A college student in Little Rock who codes websites can trade with a hairstylist who needs a site.  
She builds the website; he braids her hair.  
No cash — just community, fair value, and mutual growth.

## Why It Matters to Little Rock and Arkansas  
## Why It Matters to Little Rock and Arkansas  

- **Small Business Owners** often skip marketing or tech services because every dollar counts.  
- **College Students** need real-world experience but can’t afford mentorship or tools.  
- **Freelancers & Creators** have skills that sit idle without capital or visibility.  

By turning skills into currency, **$wap activates Arkansas’s underused talent** and fosters a local economy built on collaboration and trust — not cash.

## Unique Value Proposition  

Traditional freelance platforms require money, subscriptions, and transaction fees.  
**$wap reimagines value exchange as reciprocity, not currency.**  

- No middlemen — only fair exchange.  
- No barriers — anyone can start with what they know.  
- No limits — skills build community wealth.  

For **small businesses**, it means affordable growth.  
For **freelancers**, it means stronger portfolios and networks.  
For **college students**, it means real-world experience without debt. 

## Tech Stack

Website / Frontend: Flutter (web) — responsive UI, single codebase targeting web/desktop/mobile.

#### Frontend

- Built with Flutter & Dart

![Dart](https://img.shields.io/badge/dart-%23039BE5.svg?style=for-the-badge&logo=dart) ![Flutter](https://img.shields.io/badge/flutter-%23039BE5.svg?style=for-the-badge&logo=flutter)

#### Backend

Built with FastAPI and machine learning for smart skill matching.

- **Python 3.11** + **FastAPI** - REST API
- **Firebase Firestore** - User profile storage
- **Qdrant Cloud** - Vector database for semantic search
- **Redis** - Caching layer (16x faster repeat queries)
- **sentence-transformers (BERT)** - Text embedding model
- **Docker** - Containerization
- **Fly.io** - Production hosting

![Python](https://img.shields.io/badge/python-3.11-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi) ![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

**Backend Features:**
- Semantic search using BERT (finds skills by meaning, not just keywords)
- Reciprocal matching algorithm (finds mutual exchanges)
- Fast vector similarity search (~80ms, ~5ms with cache)
- Redis caching layer (16x speedup on repeat queries)
- 384-dimensional embeddings for each skill
- Harmonic mean scoring for balanced matches

**Production API:** `https://swap-backend.fly.dev`

**[Full Backend Documentation](wap-backend/README.md)**

#### Authentication & Database

- **Firebase Authentication** - Secure user management
- **Firebase Firestore** - Profile data storage with automatic indexing
- **Qdrant Cloud** - Vector storage for 10,000+ profiles (free tier)
- **Redis** - Cache layer (local dev only, not on production yet)

## Architecture

```
                    ┌──────────────────────────────────────┐
                    │       Flutter Web Application        │
                    │    (User Interface - Web/Mobile)     │
                    └─────────────────┬────────────────────┘
                                      │
                                      │ HTTPS/REST API
                                      │
                    ┌─────────────────▼────────────────────┐
                    │      FastAPI Backend Server          │
                    │         (Fly.io Cloud)               │
                    │                                      │
                    │  ┌────────────────────────────────┐  │
                    │  │  Profile Management Router     │  │
                    │  ├────────────────────────────────┤  │
                    │  │  Semantic Search Router        │  │
                    │  ├────────────────────────────────┤  │
                    │  │  Reciprocal Matching Router    │  │
                    │  ├────────────────────────────────┤  │
                    │  │  ML Embeddings Service         │  │
                    │  │  (BERT sentence-transformers)  │  │
                    │  └────────────────────────────────┘  │
                    └──────┬──────────┬──────────┬─────────────┘
                           │          │          │
                           │          │          │
            ┌──────────────▼───────┐  │   ┌──────▼──────────────────┐
            │  Firebase Firestore  │  │   │   Qdrant Cloud          │
            │  (Profile Storage)   │  │   │   (Vector Database)     │
            │                      │  │   │                         │
            │  • User profiles     │  │   │  • 384-dim vectors      │
            │  • Skills data       │  │   │  • HNSW indexing        │
            │  • Metadata          │  │   │  • Cosine similarity    │
            └──────────────────────┘  │   └─────────────────────────┘
                                      │
                               ┌──────▼──────┐
                               │    Redis    │
                               │  (Cache)    │
                               │             │
                               │  • 5ms hits │
                               │  • 1hr TTL  │
                               └─────────────┘
```

### Data Flow

**Profile Creation:**
```
User Input → FastAPI Validation → Firebase (store profile)
                                 ↓
                          ML Model (encode skills)
                                 ↓
                          Qdrant (store vectors)
```

**Semantic Search:**
```
Query "guitar lessons" → ML Model (text → 384-dim vector)
                              ↓
                       Qdrant (vector similarity search)
                              ↓
                       Firebase (fetch full profiles)
                              ↓
                       Ranked Results (by cosine similarity)
```

**Reciprocal Matching:**
```
My Skills: "Python"  }
My Needs: "Guitar"   } → ML Model → 2 vectors
                              ↓
                    ┌─────────┴──────────┐
                    ▼                    ▼
           Search their offers    Search my offers
           vs my needs           vs their needs
                    │                    │
                    └─────────┬──────────┘
                              ▼
                    Harmonic Mean Score
                              ↓
                    Top Mutual Matches
```

### Performance

| Operation | Cached | Uncached | Components Used |
|-----------|--------|----------|-----------------|
| Semantic Search | ~5ms | ~80ms | FastAPI → ML → Qdrant → Firebase |
| Reciprocal Match | ~8ms | ~120ms | FastAPI → ML → Qdrant (2x) → Firebase |
| Profile Create | - | ~150ms | FastAPI → Firebase → ML → Qdrant |
| Profile Read | - | ~20ms | FastAPI → Firebase |
| Health Check | - | ~1ms | FastAPI only |

*Tested on: Fly.io (1GB RAM, 1 CPU), 1000+ profiles*

**Note:** Redis caching speeds up repeat queries by ~16x. Currently only running in local dev (docker-compose), not deployed to production yet.

## API Documentation

### Backend REST APIs

**Production Base URL:** `https://swap-backend.fly.dev`  
**Local Base URL:** `http://localhost:8000`  
**Interactive Docs:** `https://swap-backend.fly.dev/docs` (Swagger UI)

---

#### 1. Health Check API

**Endpoint:** `GET /healthz`

Verify backend services are operational.

**Request:**
```bash
curl https://swap-backend.fly.dev/healthz
```

**Response:** `200 OK`
```json
{
  "status": "healthy",
  "firebase": "connected",
  "qdrant": "connected"
}
```

---

#### 2. Profile Management API

##### Create/Update Profile
**Endpoint:** `POST /profiles/upsert`

Create a new user profile or update existing one with skill embeddings.

**Request Body:**
```json
{
  "uid": "sarah_j_2024",
  "email": "sarah.johnson@gmail.com",
  "display_name": "Sarah Johnson",
  "skills_to_offer": "I can teach web development with React and JavaScript. I also help people build their first website from scratch.",
  "services_needed": "Looking for someone who can teach me product photography and basic photo editing skills.",
  "bio": "Software engineer who loves building things",
  "city": "Little Rock"
}
```

**Response:** `200 OK`
```json
{
  "uid": "sarah_j_2024",
  "email": "sarah.johnson@gmail.com",
  "display_name": "Sarah Johnson",
  "skills_to_offer": "I can teach web development with React and JavaScript. I also help people build their first website from scratch.",
  "services_needed": "Looking for someone who can teach me product photography and basic photo editing skills.",
  "bio": "Software engineer who loves building things",
  "city": "Little Rock",
  "created_at": "2025-11-08T10:30:00.000Z",
  "updated_at": "2025-11-08T10:30:00.000Z"
}
```

What happens:
1. Profile stored in Firebase Firestore
2. Skills text converted to vectors using BERT
3. Vectors indexed in Qdrant for search

**Try it:**
```bash
curl -X POST https://swap-backend.fly.dev/profiles/upsert \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "marcus_williams",
    "email": "marcus.w@email.com",
    "display_name": "Marcus Williams",
    "skills_to_offer": "I can help you learn how to play bass guitar and understand music theory basics",
    "services_needed": "Want to learn mobile app development, especially Flutter"
  }'
```

##### Get Profile
**Endpoint:** `GET /profiles/{uid}`

Retrieve someone's profile.

**Response:** `200 OK`
```json
{
  "uid": "tyler_designs",
  "email": "tyler.mitchell@yahoo.com",
  "display_name": "Tyler Mitchell",
  "skills_to_offer": "I can teach graphic design using Figma and Adobe Illustrator. I also do logo design and brand identity work.",
  "services_needed": "Need help learning Spanish for an upcoming trip to Barcelona",
  "bio": "Creative designer in Fayetteville",
  "city": "Fayetteville",
  "created_at": "2025-11-07T14:22:00.000Z",
  "updated_at": "2025-11-08T09:15:00.000Z"
}
```

**Try it:**
```bash
curl https://swap-backend.fly.dev/profiles/tyler_designs
```

---

#### 3. Semantic Search API

**Endpoint:** `POST /search`

Search using natural language. Works by meaning, not just keywords.

**Search Modes:**
- **`offers`**: Find people who can teach you something
- **`needs`**: Find people who want to learn what you know
- **`both`**: Search everything

**Request:**
```json
{
  "query": "someone who can help me understand how to make beats and produce music",
  "mode": "offers",
  "limit": 5
}
```

**Response:** `200 OK`
```json
[
  {
    "uid": "dj_carlos",
    "display_name": "Carlos Rodriguez",
    "email": "carlosr.beats@gmail.com",
    "skills_to_offer": "I teach music production using FL Studio and Ableton. I can show you how to make trap, hip-hop, and R&B instrumentals.",
    "services_needed": "Want to get better at video editing, especially transitions and color grading",
    "bio": "Producer and DJ, been making beats for 8 years",
    "city": "Conway",
    "score": 0.87
  },
  {
    "uid": "melody_davis",
    "display_name": "Melody Davis",
    "email": "melody.davis@outlook.com",
    "skills_to_offer": "Can teach you music theory, sound design, and how to mix your own tracks professionally",
    "services_needed": "Looking for someone to teach me content writing and copywriting",
    "city": "Jonesboro",
    "score": 0.82
  }
]
```

Score ranges from 0 to 1 (higher = better match).

**More examples:**

Looking for a language tutor:
```bash
curl -X POST https://swap-backend.fly.dev/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "someone who speaks French fluently and can teach me conversational French",
    "mode": "offers",
    "limit": 5
  }'
```

Want to teach your coding skills:
```bash
curl -X POST https://swap-backend.fly.dev/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "I know JavaScript and React, looking for people who want to learn web development",
    "mode": "needs",
    "limit": 5
  }'
```

General search:
```bash
curl -X POST https://swap-backend.fly.dev/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "cooking and baking skills",
    "mode": "both",
    "limit": 8
  }'
```

---

#### 4. Reciprocal Matching API

**Endpoint:** `POST /match/reciprocal`

Find mutual skill exchange partners where **you teach them** and **they teach you**.

**Algorithm:**
1. Search **their offers** vs **your needs** → Score A
2. Search **your offers** vs **their needs** → Score B  
3. Calculate **harmonic mean**: `2 × (A × B) / (A + B)`
4. Rank by combined score

**Why Harmonic Mean?**
Penalizes one-sided matches. Both scores need to be high.
- Good match: `(0.9, 0.9) → 0.90`
- One-sided: `(0.9, 0.3) → 0.45`

**Request:**
```json
{
  "my_offer_text": "I can teach web development, specifically building sites with React and handling databases",
  "my_need_text": "Want to learn acoustic guitar, maybe some basic music theory too",
  "limit": 10
}
```

**Response:** `200 OK`
```json
[
  {
    "uid": "brandon_strings",
    "display_name": "Brandon Hayes",
    "email": "brandonh.music@gmail.com",
    "skills_to_offer": "I teach acoustic guitar, electric guitar, and music theory for beginners and intermediate players",
    "services_needed": "Really want to learn web development so I can build my own website for my music lessons",
    "bio": "Guitarist in Hot Springs, been playing for 12 years",
    "city": "Hot Springs",
    "score": 0.91
  },
  {
    "uid": "jasmine_codes",
    "display_name": "Jasmine Parker",
    "email": "jasmine.p@outlook.com",
    "skills_to_offer": "Can teach you piano basics and how to read sheet music",
    "services_needed": "Need help understanding how to code and build web applications",
    "bio": "Piano teacher trying to transition to tech",
    "city": "Bentonville",
    "score": 0.78
  }
]
```

**Try it:**
```bash
curl -X POST https://swap-backend.fly.dev/match/reciprocal \
  -H "Content-Type: application/json" \
  -d '{
    "my_offer_text": "I can help with graphic design and teach you Adobe Photoshop and Illustrator",
    "my_need_text": "Looking to learn how to bake bread and pastries from scratch",
    "limit": 10
  }'
```

---

### API Response Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 400 | Bad Request | Invalid input (validation error) |
| 404 | Not Found | Profile not found |
| 500 | Internal Server Error | Server-side error |

---

### External Services & APIs Used

#### 1. Firebase Services
- **Firebase Authentication** - User identity management
- **Firebase Firestore** - NoSQL document database
  - Collection: `profiles`
  - Auto-indexing on `uid`, `email`
  - Real-time sync capabilities

#### 2. Qdrant Cloud API
- **Service:** Vector similarity search database
- **Plan:** Free tier (1GB storage, ~10,000 profiles)
- **Features Used:**
  - Named vectors (`offer_vec`, `need_vec`)
  - HNSW indexing for fast search
  - Cosine similarity matching
  - REST API over HTTPS

#### 3. Hugging Face Transformers
- **Model:** `sentence-transformers/all-MiniLM-L6-v2`
- **Purpose:** Convert text to semantic embeddings
- **Output:** 384-dimensional vectors
- **Features:**
  - Pre-trained on semantic similarity tasks
  - Normalized embeddings
  - Fast inference (~10-20ms per encoding)

#### 4. Redis
- **Service:** In-memory data store for caching
- **Deployment:** Local development only (via docker-compose)
- **Features:**
  - Sub-5ms response times
  - 1 hour TTL on cached results
  - Automatic cache invalidation on profile updates
  - Graceful degradation if unavailable

#### 5. Fly.io Platform
- **Service:** Cloud application hosting
- **Region:** US East (Virginia)
- **Features:**
  - Auto-scaling
  - Global CDN
  - HTTPS by default
  - Health checks

---

**[Complete API Documentation with Postman Examples](wap-backend/docs/API.md)**

## User Stories

- As a Creator, I want to post a skill with a clear title, description, tags, and deliverables so buyers can understand what I'll provide.
- As a Buyer, I want to search or browse listings and preview deliverables so I can quickly find a suitable service.
- As a User, I want to receive requests and manage them from a dashboard to track ongoing and completed work.

## Walkthrough: Using Swap

Basic flow (quick):

1. Sign up / Sign in (placeholder test credentials below if you want to demo quickly).
2. Creators: Click "Post Skill", fill the Basic Information and Details & Logistics sections, then Publish.
3. Buyers: Browse the Discover page or use tags to find skills, preview a skill, and send a Request.

### Test/demo credentials (placeholder)
- Creator: email: creator@example.com, password: password123
- Buyer: email: buyer@example.com, password: password123

### Link to Video Pitch
- placeholder: https://your-video-link

### Link to Demo Presentation
- placeholder: https://your-presentation-link

### Team Checklist
- [x] Team photo
- [x] Team Slack channel
- [x] Communication established with mentor
- [x] Repo created from template
- [ ] Flight Deck / Hangar registration (placeholder)

### Project Checklist
- [ ] Presentation complete and linked (placeholder)
- [ ] Video pitch recorded and linked (placeholder)
- [x] Code merged to main branch

### School Name
Philander Smith University

### Team Name
Panthers

### Contributors
* Immanuella Emem Umoren
* Kenna Agbugba
* Otito Udedibor
* Olaoluwa James-Owolabi
* Emmanuella Turkson
