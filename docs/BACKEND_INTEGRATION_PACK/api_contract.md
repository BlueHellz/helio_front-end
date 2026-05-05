# LIMYÈ — API contract (derived from Flutter client)

**Sources:** `lib/core/app_state.dart`, `lib/core/models/project.dart`, `lib/core/models/chat_message.dart`, `lib/config.dart`, `lib/core/router.dart`

**Intended API base (client):** `BlackLightConfig.apiBaseUrl` resolves to **`https://limye-api.onrender.com`** (see `lib/config.dart`). The Flutter app does not call this URL yet; wire HTTP when implementing the client.

---

## 1. User roles

| `UserRole` (Dart) | Suggested API value | Notes |
|-------------------|---------------------|--------|
| `UserRole.homeowner` | `homeowner` | Web homeowner dashboard + chat. |
| `UserRole.organization` | `organization` | Installer / org (web + mobile installer). |
| `UserRole.droneOperator` | `droneOperator` | Mobile drone-operator shell. |
| `UserRole.none` | `none` (or omit) | Logged out / unknown. |

**Backend expectation:** The authoritative role should come from **your DB** (or `/me` / token claims) after auth, not only from client-selected UI. The app currently sets role via `signIn(role: ...)` with no network call.

---

## 2. `BlackLightAppState` (session + collections)

| Field | Type (Dart) | Backend responsibility |
|-------|----------------|------------------------|
| `role` | `UserRole` | Return from `/me` or token claims. |
| `isAuthenticated` | `bool` | True when access token valid. |
| `userName` | `String` | Profile display name. |
| `companyName` | `String` | Org name (installer flows). |
| `hlioBalance` | `double` | HLIO balance (on-chain, indexer, or ledger). |
| `walletAddress` | `String?` | Linked wallet (after connect / verify). |
| `projects` | `List<Project>` | `GET /projects` (scoped by user/org). |
| `chatMessages` | `List<ChatMessage>` | `GET/POST` project-scoped messages (see below). |

Navigation indices (`webSidebarIndex`, `mobileNavIndex`, `droneOperatorNavIndex`) are **client-only** and are not API concerns.

**Auth/session expectations**

- **API auth:** Login/register (`POST /api/v1/auth/login`, `POST /api/v1/auth/signup`) returns **access/refresh tokens**. The Flutter client stores the session and sends `Authorization: Bearer <access_token>` to FastAPI.
- **`/auth/verify`:** Server validates the access JWT and returns 200 with normalized user + role, or 401/403. Used to sync `BlackLightAppState` on app load when needed.
- **`signOut`:** Client clears local state; server may revoke refresh tokens if you implement a revoke endpoint.
- **Wallet:** `connectWallet` today only stores address locally. Backend should support **link wallet** (sign message) and return updated `walletAddress` + `hlioBalance`.

---

## 3. `Project` (fields)

| Field | Dart type | JSON (camelCase) | Required |
|-------|-----------|------------------|----------|
| `id` | `String` | `id` | yes |
| `address` | `String` | `address` | yes |
| `clientName` | `String` | `clientName` | yes |
| `clientEmail` | `String?` | `clientEmail` | no |
| `clientPhone` | `String?` | `clientPhone` | no |
| `status` | `ProjectStatus` | `status` (see enum below) | yes |
| `type` | `ProjectType` | `type` (see enum below) | yes |
| `date` | `DateTime` | `date` (ISO-8601 string) | yes |
| `systemSizeKw` | `double?` | `systemSizeKw` | no |
| `panelCount` | `int?` | `panelCount` | no |
| `annualProductionKwh` | `double?` | `annualProductionKwh` | no |
| `yearOneSavings` | `double?` | `yearOneSavings` | no |
| `assignee` | `String?` | `assignee` | no |

### `ProjectStatus`

`designing` | `ready` | `quoted` | `contracted` | `permitted` | `installed` | `completed` | `inProgress` | `pendingInspection`

### `ProjectType`

`residential` | `commercial` | `industrial`

---

## 4. `Lead` (fields)

| Field | Dart type | JSON (camelCase) | Required |
|-------|-----------|------------------|----------|
| `id` | `String` | `id` | yes |
| `name` | `String` | `name` | yes |
| `address` | `String` | `address` | yes |
| `systemSizeKw` | `String?` | `systemSizeKw` | no (UI stores as string) |
| `source` | `String` | `source` | yes |
| `addedAt` | `DateTime` | `addedAt` (ISO-8601) | yes |
| `stage` | `LeadStage` | `stage` (see enum) | yes |
| `intent` | `String?` | `intent` | no |

### `LeadStage`

`newLead` | `contacted` | `quoted` | `negotiation` | `won` | `lost`

---

## 5. `ChatMessage` (fields)

| Field | Dart type | JSON (camelCase) | Required |
|-------|-----------|------------------|----------|
| `id` | `String` | `id` | yes |
| `text` | `String` | `text` | yes |
| `sender` | `MessageSender` | `sender` — `user` \| `ai` \| `system` | yes |
| `timestamp` | `DateTime` | `timestamp` (ISO-8601) | yes |
| `actions` | `List<ChatAction>?` | `actions` | no |
| `dataChip` | `ChatDataChip?` | `dataChip` | no |

**Nested: `ChatAction`:** `label`, `icon` (string), `isPrimary` (bool)

**Nested: `ChatDataChip`:** `label`, `value`, `icon` (string)

> **Threading:** The router uses a **single** `state.chatMessages` list for all flows. For production, use **`projectId`** (or thread id) on the server; extend the client model when you add `projectId` to `ChatMessage`.

**`ActivityEntry`** (in `project.dart`) uses `IconData` — not JSON-friendly as-is. If you add activity via API, prefer **`iconName`** (string) or a small enum on the server.

---

## 6. Screen / flow map → backend operations

Mapping is from **`lib/core/router.dart`** only (which widgets mount and which `state` methods run).

### Web — not authenticated (`_WebPreAuthFlow`)

| UI | Entry | Backend operations (to implement) |
|----|--------|-----------------------------------|
| `LandingPage` | Default | Marketing; optional `POST` lead / address interest. |
| `DroneOpsInfoPage` | Pillar | Drone program info; form submit → `POST` operator application. |
| `PoolInfoPage` | Pillar | Waitlist / whitepaper; `onJoinWaitlist` → auth or `POST` waitlist. |
| `EvInfoPage` | Pillar | Host interest → auth or `POST` host interest. |
| `AuthPage` | Sign in / get started | **Backend auth:** register/login; then load `/me`, projects, etc. |

### Web — homeowner (`_HomeownerFlow`, `UserRole.homeowner`)

| UI / state | `webSidebarIndex` or overlay | `BlackLightAppState` / action |
|------------|-----------------------------|------------------------------|
| `HomeownerDashboard` | Home (0, default) | `projects`, `onProjectTap`, `onNewDesign` |
| `HomeownerChatDesign` | Chat (1) or `_showChat` | `addChatMessage` per send |
| `HomeownerDesignSummary` | `_showSummary` | `project` from selection; `onDownload` not wired |
| `HomeownerQuoteRequest` | `_showQuote` | `onSubmit` not wired |
| `SettingsWallet` | 2, 3, 4 | `userName`, `hlioBalance`, `onConnectWallet` stub, `signOut` |

**Flows:** list/load **projects**; **chat** send/receive (and later AI by `MessageSender.ai`); **quote submit**; **file download** for design; **wallet** + balance.

### Web — organization (`_OrgFlow`, not homeowner on web)

| UI / state | `webSidebarIndex` or overlay | `BlackLightAppState` / local |
|------------|-----------------------------|-----------------------------|
| `OrgDashboard` | 0 | `companyName`, `projects`; navigate to new project, CRM, detail |
| `OrgNewProject` | 1 / `_showNewProject` | `onSubmit` → `addProject` (local `Project` create) |
| `OrgProjectDetail` | `_showDetail` | Selected `Project`; `onOpenChat` |
| `OrgChatDesign` | with chat | `addChatMessage`; `onViewDesign` not wired |
| `OrgCrm` | 2 | `_leads` **local** list; `onMoveStage`; `onAddLead` not wired |
| `SettingsWallet` | 3–5 | `userName`, `companyName`, `hlioBalance`, wallet stub, `signOut` |

**Flows:** org-scoped **projects** CRUD; **leads** CRUD + stage updates; **chat** per project; **settings** + wallet.

### Mobile — not authenticated

| UI | Backend |
|----|---------|
| `MobileAuth` | Same auth as web; `onAuthenticated` → `signIn` |

### Mobile — installer (`_MobileAuthenticatedFlow`)

| UI | `mobileNavIndex` | Notes |
|----|------------------|--------|
| `MobileProjects` | 0 | `projects`, tap, new project |
| `MobileNewProject` | 1 or overlay | `addProject` on submit |
| `MobileCrm` | 2 | `leads: []` (empty const) — **needs API** |
| `MobileSettings` | 3 | `userName`, `companyName`, `hlioBalance`, `walletAddress`, connect wallet stub, `signOut` |
| `MobileProjectDetail` / `MobileChatDesign` | overlays | same patterns as org web |

### Mobile — drone operator (`_MobileDroneOperatorFlow`)

| UI | `droneOperatorNavIndex` | Notes |
|----|-------------------------|--------|
| `DroneJobsScreen` | 0, default, capture fallback | Missions list — **future API** |
| `DroneCaptureScreen` | overlay (tab 1) | Upload / session — **future API** |
| `DroneEarningsScreen` | 2 | `hlioBalance` from state |
| `DroneProfileScreen` | 3 | `userName`, `walletAddress`, connect stub, `signOut` |

---

## 7. Gaps (stubs in router, need backend or product decisions)

- **Homeowner:** `onDownload` (summary), `onSubmit` (quote), `onConnectWallet`
- **Org / mobile:** `onViewDesign` (chat), `onAddLead` (CRM), `onConnectWallet`
- **Drone:** jobs, capture upload, profile wallet — not tied to API in router
- **Chat:** no `projectId` in `ChatMessage` yet; server should still model **threads** and return messages filtered by project/user

---

## 8. Not in this contract (other features)

- Pillar page copy, forms (drone/pool/EV) — see feature files for fields when defining `POST` bodies.
- `test/` and assets — N/A to REST contract.

This document is the handoff for implementing FastAPI + JWT-backed auth to match the app’s data shapes and navigation intent.
