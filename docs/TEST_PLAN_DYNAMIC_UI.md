# Dynamic UI + API — manual test plan (live backend)

Base URL: `https://helio-back-end.onrender.com` (via `BlackLightConfig.apiBaseUrl`). All client calls use the `/api/v1` prefix.

## Prerequisites

1. Copy `assets/env.json.example` to `assets/env.json` and set `mapboxAccessToken` for address autocomplete (do not commit `assets/env.json`).
2. Sign in through the app so `UserRole` matches the flow under test. The stub session sets `X-Org-Id: local-org` for installers (`replaceSession`); replace with a real JWT and org id when the auth API is wired.

## Homeowner

| Step | Action | Expected |
|------|--------|----------|
| H1 | Web: sign in as homeowner; open **Projects** | Dashboard loads; list calls `GET /api/v1/projects` |
| H2 | Tap **New Design** (sidebar) or **New Design** on dashboard → intake | `HomeownerIntakePage`; address debounce hits Mapbox (if token set) |
| H3 | Submit intake | `POST /api/v1/projects` with `project_type: residential` and `custom_data` map |
| H4 | Open a project row | `GET /api/v1/projects/{id}`; read-only custom fields render |
| H5 | **Help** / chat tab (web idx 4) or mobile CRM tab for homeowner | Placeholder chat UI, no API |

## Org (installer)

| Step | Action | Expected |
|------|--------|----------|
| O1 | Sign in as org; **Projects** | `OrgProjectsPage`; filters hit `GET /api/v1/projects?project_type=` |
| O2 | FAB **New Project** | `OrgNewProjectPage`; layout from `GET /api/v1/org/intake-layout` + fields from `GET /api/v1/org/custom-fields` |
| O3 | Submit project | `POST /api/v1/projects` with `project_type` + `custom_data` |
| O4 | **CRM** | `CrmBoardPage`; pipelines `GET /api/v1/org/pipelines`, stages, deals |
| O5 | Design mode **on** (Settings hub): reorder stage columns (chevrons) | `POST .../stages/reorder` |
| O6 | **Settings → Field library** | CRUD `GET/POST/PATCH/DELETE /api/v1/org/custom-fields` |
| O7 | **Role management** | roles + assign endpoints |
| O8 | **Pipeline builder** | pipelines + stages + stage field ids |
| O9 | **Intake builder** (3 tabs) | `GET/PUT /api/v1/org/intake-layout` with drag between columns + **Save layout** |

## Security

- Confirm no geocoding token appears in logs or committed Dart.
- Mapbox only loads from `assets/env.json` / fallback example (see `lib/core/secrets/app_secrets.dart`).

## Regression

- Run `flutter analyze` and `flutter test`.
- Drone operator mobile flow still reachable from `MobileAuth` secondary action.
