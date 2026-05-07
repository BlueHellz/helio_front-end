# Environment variables (Render + local) — no secrets in repo

**Purpose:** Single reference for **name**, **role**, and **where used** (FastAPI and integrations). **Values are never committed**; set them in the Render dashboard and in local `.env`.

| Name | Purpose | Where used (typical) |
|------|---------|------------------------|
| `ENV` or `APP_ENV` | `development` vs `production` (logging, CORS strictness) | `config.py`, `main.py` |
| `CORS_ORIGINS` | Comma-separated list of allowed web origins (Vercel + localhost) | `CORSMiddleware` in FastAPI |
| `PORT` | HTTP port (Render injects; local often `8000`) | Uvicorn / Render |
| `JWT_SECRET` (or equivalent) | Sign/verify access tokens issued by your API | `/auth/verify`, `/me`, protected routes |
| `DEEPSEEK_API_KEY` | LLM (OpenAI-compatible) | `services/ai_brain.py` |
| `GOOGLE_SOLAR_API_KEY` | Rooftop / building solar API | Roof / design services |
| `MAPBOX_ACCESS_TOKEN` | Geocoding, map tiles, styles | Map / address services |
| `NREL_API_KEY` (if used) | NSRDB / weather if required by NREL | Energy simulation service |
| `TWILIO_ACCOUNT_SID` | Optional Twilio account | SMS / voice (optional) |
| `TWILIO_AUTH_TOKEN` | Optional Twilio auth | Twilio client |
| `REDIS_URL` | Upstash or Redis (cache, session hints) | Lifespan, cache helpers (often `rediss://` for TLS) |
| `SOLANA_RPC_URL` | Default `https://api.devnet.solana.com` for dev | `coin_service.py`, wallet simulation |
| `KYH_` * (optional) | Solana **KOO-YOH Coin (KYH)** mint, programs, treasury — **if** you add them | `coin_service.py` |
| `GUEY_` * (optional) | Native L1 **GUEY Coin** — **future** | `coin_service.py` |
| `INTERNAL_API_KEY` (optional) | Service-to-service auth | Webhooks, cron, Edge → Render |

**Flutter / client:** The app reads **`KooyohConfig.apiBaseUrl`**, which currently resolves to **`https://kooyoh-api.onrender.com`**. For flexibility, you can later move the **API base URL** to `--dart-define` or a small env on Vercel build — not part of Render’s server env, but the **Vercel** app must be built to call the **Render** API URL you deploy.

**Security reminders**

- **Never** put server signing secrets (e.g. `JWT_SECRET`) in the browser or in the Flutter app.  
- Rotate keys if a client bundle ever leaks.  
- Use **separate** secrets for dev vs prod when possible.

This table aligns with a typical KOOYOH stack (FastAPI on Render, JWT auth, external APIs, Redis, Solana devnet for simulation). Add rows as you introduce new services.
