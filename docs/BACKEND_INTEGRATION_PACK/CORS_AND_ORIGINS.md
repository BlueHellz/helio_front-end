# CORS and allowed origins (Black Light)

**Context:** The Flutter app ships as a **web build on Vercel** and may run **locally** for development (`flutter run -d web-server` or `flutter run -d chrome`). The **FastAPI** service on **Render** must return appropriate **`Access-Control-*`** headers for browser calls from those origins.

## Flutter web (Vercel)

- Production traffic will come from your Vercel deployment URL, for example:
  - `https://<vercel-app>.vercel.app`
  - Custom domain, e.g. `https://app.blacklight.example` (replace with your real host)

**Backend action:** Set `CORS_ORIGINS` (or equivalent) on Render to **include the exact Vercel origin** (scheme + host + port if non-default). Browsers do not treat `https://a.vercel.app` and `https://b.vercel.app` as the same origin.

## Local development

Allow at least one of the following patterns used by `flutter run`:

| Example origin | When |
|------------------|------|
| `http://localhost:8080` | Default or chosen `--web-port` |
| `http://127.0.0.1:7357` | Example custom port |
| `http://localhost:3000` | If you proxy or use another dev server |

**Note:** CORS is **origin-based** — `http://localhost:5000` and `http://127.0.0.1:5000` are **different** origins. During dev, you can list multiple exact origins or use a small set of known ports.

Wildcards: **`http://localhost:*`** is **not** valid in the CORS `Access-Control-Allow-Origin` header; browsers require either a **single explicit origin** or (for credentialed requests) a matching origin per request. In **Starlette/FastAPI**, the typical pattern is a **list of allowed origins** in settings (e.g. split from `CORS_ORIGINS`).

## Render ↔ Vercel

- **Vercel** only hosts the static Flutter web bundle; it does not run your API.
- **Render** hosts FastAPI. The Flutter app’s `BlackLightConfig.apiBaseUrl` (or env-based URL) should point to your **Render** HTTPS URL.
- **HTTPS:** Production API should use **https://** on Render; match `CORS` to **https** Vercel origins only.

## Preflight and credentials

- If the app later uses **`Authorization: Bearer <jwt>`** only (no cookies), simple CORS with allowed origins and `Authorization` in allowed headers is usually enough.
- If you add **cookies** (session), you must set `allow_credentials` and **cannot** use `*` for origin.

## Checklist (backend)

- [ ] `CORS` allows Vercel production origin(s)  
- [ ] `CORS` allows local dev origins you actually use (localhost + port)  
- [ ] `GET` and `POST` (and any `PUT`/`DELETE`) for `/projects`, `/leads`, etc. are covered  
- [ ] `Authorization` header allowed if using Bearer tokens  

This file is documentation only; implement CORS in FastAPI `main.py` / middleware per your `config` module.
