# $wap

<img width="1411" height="625" alt="Screenshot 2025-11-08 at 1 12 02 AM" src="https://github.com/user-attachments/assets/78ca44bf-da91-40f6-87ad-34f9039469d5" />
<img width="1411" height="394" alt="Screenshot 2025-11-08 at 1 14 13 AM" src="https://github.com/user-attachments/assets/759a45b7-3e87-41f8-85ac-462b0f4aa8fa" />
<img width="1512" height="855" alt="Screenshot 2025-11-08 at 1 02 41 AM" src="https://github.com/user-attachments/assets/80a62cd2-2c5b-40ee-9871-e04365dee102" />
<img width="1195" height="761" alt="Screenshot 2025-11-08 at 1 05 32 AM" src="https://github.com/user-attachments/assets/251be873-25f8-4cdc-9bc7-f48cbf093c52" />
<img width="1507" height="863" alt="Screenshot 2025-11-08 at 1 06 08 AM" src="https://github.com/user-attachments/assets/47d7ac78-e97e-47f1-b782-7f0a9d0dce6b" />
<img width="1507" height="863" alt="Screenshot 2025-11-08 at 1 06 40 AM" src="https://github.com/user-attachments/assets/ddd18e3c-41d1-4bbe-b69e-5660e0367ccb" />
<img width="1507" height="863" alt="Screenshot 2025-11-08 at 1 06 47 AM" src="https://github.com/user-attachments/assets/fe64da47-431d-4636-94c0-6d2795b4b39f" />

## Challenge Statement(s) Addressed 🎯

In Arkansas, thousands of people have talent, but limited access to opportunity. Small businesses make up **99.3% of all enterprises (≈ 258,000)**, yet the state still ranks **40th out of 51** in overall economic activity.

Rising costs mean many small business owners skip professional services — not because they lack vision, but because every dollar goes toward staying open. At the same time, college students and freelancers across Little Rock possess valuable skills they can’t fully use or afford to market.  

The problem isn’t a lack of ability. it’s a **lack of access**.  

**$wap** addresses this by asking:  
- How might we help communities unlock value without relying on money?  
- How might we turn *“what you can do”* into *“what you need”*?  
- How might AI connect people so skills never go unused?
  
## 💡 Project Description  

**$wap** is an AI-powered skill-exchange platform that lets people **trade skills instead of cash**. It creates a new, inclusive economy where your abilities — not your wallet — open doors.  

### 🧠 How It Works  
1. **Create a Profile** — List the skills you can offer and what you need.  
2. **AI Matchmaking** — Machine learning pairs you with users whose skills and availability fit yours.  
3. **Swap Fairly** — Exchange services, time, or expertise — no money required.  
4. **Earn & Redeem Credits** — Every successful swap earns credibility and “swap credits.”  
5. **Build Trust** — Ratings and feedback verify quality and accountability.  

### 💬 Example  
A college student in Little Rock who codes websites can trade with a hairstylist who needs a site.  
She builds the website; he braids her hair.  
No cash — just community, fair value, and mutual growth.

## 🌍 Why It Matters to Little Rock and Arkansas  

- **Small Business Owners** often skip marketing or tech services because every dollar counts.  
- **College Students** need real-world experience but can’t afford mentorship or tools.  
- **Freelancers & Creators** have skills that sit idle without capital or visibility.  

By turning skills into currency, **$wap activates Arkansas’s underused talent** and fosters a local economy built on collaboration and trust — not cash.

## 💎 Unique Value Proposition  

Traditional freelance platforms require money, subscriptions, and transaction fees.  
**$wap reimagines value exchange as reciprocity, not currency.**  

- No middlemen — only fair exchange.  
- No barriers — anyone can start with what they know.  
- No limits — skills build community wealth.  

For **small businesses**, it means affordable growth.  
For **freelancers**, it means stronger portfolios and networks.  
For **college students**, it means real-world experience without debt. 

## 💻 Tech Overview & Tech Stack

Website / Frontend: Flutter (web) — responsive UI, single codebase targeting web/desktop/mobile.

#### Frontend

- Built with Flutter & Dart

![Dart](https://img.shields.io/badge/dart-%23039BE5.svg?style=for-the-badge&logo=dart) ![Flutter](https://img.shields.io/badge/flutter-%23039BE5.svg?style=for-the-badge&logo=flutter)

#### Backend

**FastAPI + Machine Learning Powered Matching Engine**

- **Python 3.11** with **FastAPI** - Modern async REST API
- **Firebase Firestore** - NoSQL database for profile storage
- **Qdrant Cloud** - Vector database for semantic search
- **sentence-transformers (BERT)** - ML model for natural language understanding
- **Docker** - Containerized deployment
- **Fly.io** - Production hosting with global edge deployment

![Python](https://img.shields.io/badge/python-3.11-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi) ![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

**Key Backend Features:**
- 🤖 **Semantic Search** - Find skills using natural language (e.g., "teach me guitar" matches "music lessons")
- 🔄 **Reciprocal Matching** - Smart algorithm finds mutual skill exchange partners
- ⚡ **Sub-100ms Search** - Lightning-fast vector similarity search
- 📊 **384-dimensional BERT Embeddings** - Each skill converted to semantic vectors
- 🎯 **Harmonic Mean Scoring** - Ensures balanced mutual matches

**Production API:** `https://swap-backend.fly.dev`

**[📚 Full Backend Documentation](wap-backend/README.md)**

#### Authentication & Database

- **Firebase Authentication** - Secure user management
- **Firebase Firestore** - Profile data storage with automatic indexing
- **Qdrant Cloud** - Vector storage for 10,000+ profiles (free tier)

## 🏗️ Architecture & Infrastructure

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
                    └──────┬─────────────────┬─────────────┘
                           │                 │
                           │                 │
            ┌──────────────▼───────┐    ┌────▼──────────────────┐
            │  Firebase Firestore  │    │   Qdrant Cloud        │
            │  (Profile Storage)   │    │   (Vector Database)   │
            │                      │    │                       │
            │  • User profiles     │    │  • 384-dim vectors    │
            │  • Skills data       │    │  • HNSW indexing      │
            │  • Metadata          │    │  • Cosine similarity  │
            └──────────────────────┘    └───────────────────────┘
```

### 🔄 Data Flow

**1. Profile Creation Flow**
```
User Input → FastAPI Validation → Firebase (store profile)
                                 ↓
                          ML Model (encode skills)
                                 ↓
                          Qdrant (store vectors)
```

**2. Semantic Search Flow**
```
Query "guitar lessons" → ML Model (text → 384-dim vector)
                              ↓
                       Qdrant (vector similarity search)
                              ↓
                       Firebase (fetch full profiles)
                              ↓
                       Ranked Results (by cosine similarity)
```

**3. Reciprocal Matching Flow**
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

### ⚡ Performance Metrics

| Operation | Latency | Components Used |
|-----------|---------|-----------------|
| Profile Create | ~150ms | FastAPI → Firebase → ML → Qdrant |
| Profile Read | ~20ms | FastAPI → Firebase |
| Semantic Search | ~80ms | FastAPI → ML → Qdrant → Firebase |
| Reciprocal Match | ~120ms | FastAPI → ML → Qdrant (2x) → Firebase |
| Health Check | ~1ms | FastAPI only |

*Tested on: Fly.io (1GB RAM, 1 CPU), 1000+ profiles*

## 📡 API Documentation

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
  "uid": "user123",
  "email": "developer@example.com",
  "display_name": "Jane Developer",
  "skills_to_offer": "Python, FastAPI, Machine Learning, React",
  "services_needed": "Guitar lessons, Photography, Spanish tutoring",
  "bio": "Full-stack developer passionate about music",
  "city": "Lagos"
}
```

**Response:** `200 OK`
```json
{
  "uid": "user123",
  "email": "developer@example.com",
  "display_name": "Jane Developer",
  "skills_to_offer": "Python, FastAPI, Machine Learning, React",
  "services_needed": "Guitar lessons, Photography, Spanish tutoring",
  "bio": "Full-stack developer passionate about music",
  "city": "Lagos",
  "created_at": "2025-11-08T10:30:00.000Z",
  "updated_at": "2025-11-08T10:30:00.000Z"
}
```

**What happens internally:**
1. Profile saved to Firebase Firestore
2. Skills converted to 384-dimensional vectors using BERT
3. Vectors stored in Qdrant for semantic search

**Example:**
```bash
curl -X POST https://swap-backend.fly.dev/profiles/upsert \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "user123",
    "email": "dev@example.com",
    "display_name": "Jane Dev",
    "skills_to_offer": "Python programming",
    "services_needed": "Guitar lessons"
  }'
```

##### Get Profile
**Endpoint:** `GET /profiles/{uid}`

Retrieve a user profile by ID.

**Response:** `200 OK`
```json
{
  "uid": "user123",
  "email": "developer@example.com",
  "display_name": "Jane Developer",
  "skills_to_offer": "Python, FastAPI, Machine Learning",
  "services_needed": "Guitar lessons",
  "bio": "Full-stack developer",
  "city": "Lagos",
  "created_at": "2025-11-08T10:30:00.000Z",
  "updated_at": "2025-11-08T10:30:00.000Z"
}
```

**Example:**
```bash
curl https://swap-backend.fly.dev/profiles/user123
```

---

#### 3. Semantic Search API

**Endpoint:** `POST /search`

Find users by natural language query using AI-powered semantic matching.

**Search Modes:**
- **`offers`** (default): Find people who **can teach** what you want to learn
- **`needs`**: Find people who **want to learn** what you can teach
- **`both`**: Search all skills (offers + needs)

**Request Body:**
```json
{
  "query": "teach me guitar and music production",
  "mode": "offers",
  "limit": 10
}
```

**Response:** `200 OK`
```json
[
  {
    "uid": "musician_001",
    "display_name": "Mike Guitar",
    "email": "mike@example.com",
    "skills_to_offer": "Guitar, Music production, Audio engineering",
    "services_needed": "Web development, UI design",
    "bio": "Professional guitarist with 10 years experience",
    "city": "Lagos",
    "score": 0.89
  },
  {
    "uid": "producer_002",
    "display_name": "Sarah Beats",
    "email": "sarah@example.com",
    "skills_to_offer": "Music production, Piano, Sound design",
    "services_needed": "Python programming",
    "bio": "Music producer and audio engineer",
    "city": "Abuja",
    "score": 0.84
  }
]
```

**Score:** Float between 0.0 and 1.0 (higher = better semantic match)

**Examples:**

Find guitar teachers:
```bash
curl -X POST https://swap-backend.fly.dev/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "learn guitar and music theory",
    "mode": "offers",
    "limit": 5
  }'
```

Find people who want to learn Python:
```bash
curl -X POST https://swap-backend.fly.dev/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Python programming and web development",
    "mode": "needs",
    "limit": 5
  }'
```

Search everything:
```bash
curl -X POST https://swap-backend.fly.dev/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "photography",
    "mode": "both",
    "limit": 10
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
- Penalizes lopsided matches
- Both scores must be high for good match
- Example: `(0.9, 0.9) → 0.90` ✅ vs `(0.9, 0.3) → 0.45` ❌

**Request Body:**
```json
{
  "my_offer_text": "Python programming, FastAPI, Machine Learning",
  "my_need_text": "Guitar lessons, Music theory, Songwriting",
  "limit": 10
}
```

**Response:** `200 OK`
```json
[
  {
    "uid": "guitarist_dev",
    "display_name": "John Music",
    "email": "john@example.com",
    "skills_to_offer": "Guitar, Music theory, Songwriting",
    "services_needed": "Python, API development, Machine Learning",
    "bio": "Guitarist who wants to learn coding",
    "city": "Lagos",
    "score": 0.91
  },
  {
    "uid": "musician_coder",
    "display_name": "Lisa Tech",
    "email": "lisa@example.com",
    "skills_to_offer": "Piano, Music production",
    "services_needed": "Python, Web development",
    "bio": "Music teacher learning to code",
    "city": "Abuja",
    "score": 0.78
  }
]
```

**Example:**
```bash
curl -X POST https://swap-backend.fly.dev/match/reciprocal \
  -H "Content-Type: application/json" \
  -d '{
    "my_offer_text": "Python programming and web development",
    "my_need_text": "Guitar lessons and music production",
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

#### 4. Fly.io Platform
- **Service:** Cloud application hosting
- **Region:** US East (Virginia)
- **Features:**
  - Auto-scaling
  - Global CDN
  - HTTPS by default
  - Health checks

---

**[📖 Complete API Documentation with Postman Examples](wap-backend/docs/API.md)**

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

### Team Checklist ✅
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

### ✨ Contributors ✨
* Immanuella Emem Umoren
* Kenna Agbugba
* Otito Udedibor
* Olaoluwa James-Owolabi
* Emmanuella Turkson
