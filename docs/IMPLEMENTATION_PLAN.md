# Project Vita V1 — Implementation Plan

Source: `mpv.docx` (V1 scope) aligned to the HealthGuard vision in
`Product Requirement Documents.docx`.
V1 proves one loop for one persona ("Health-Conscious Alex"):
**ingest data → detect anomalies → alert + recommendation.**

> Prototype rules: demo data only, no real PHI, not a medical device,
> no diagnosis claims, rule-based recommendations only.

## Scope notes (deviations from V1 PRD)

| PRD said | This plan does | Why |
|----------|----------------|-----|
| Single-user demo, no auth | BetterAuth (Node service, JWTs for Flask) | Requested stack; enables multi-user + clinician/caregiver roles |
| No payments/marketplace in V1 | Paystack wired for orders/subscriptions | Requested stack; marketplace enablement |
| Shared S3 bucket for dataset | Cloudflare R2 for datasets, models, uploads | Requested stack |
| No email specified | Zeptomail for transactional mail | Alerts, verification, receipts |
| SQLite/unspecified DB | PostgreSQL as primary store | Requested stack; audit + relational integrity |

## Stack

| Layer | Choice | Role |
|-------|--------|------|
| API | Flask (Python) | REST API, model serving |
| Auth | BetterAuth (Node service) | Sign-up/login, sessions, JWT issuance |
| Web app | Flask + Jinja2 + charts | Dashboard, alerts, trends |
| ML | scikit-learn (Isolation Forest), TensorFlow (LSTM) | Anomaly detection, `.pkl`/`.h5` artifacts |
| Database | PostgreSQL | Users, profiles, measurements, alerts, payments, audit |
| Object storage | Cloudflare R2 | Datasets, model files, uploads, exports |
| Payments | Paystack | Orders, subscriptions, billing |
| Email | Zeptomail | Verification, alert digests, receipts, notifications |
| Containers | Docker + Compose | api, auth, worker, postgres; image → AWS EB/ECS |
| Docs | Swagger/OpenAPI | API contract |

## Architectural decisions

| # | Decision | Rationale |
|---|----------|-----------|
| AD-1 | BetterAuth runs as a standalone Node service; Flask validates JWTs | BetterAuth is TS-first with no native Flask integration; keeps auth concerns isolated |
| AD-2 | PostgreSQL is the system of record; time-series measurements in hypertable-style partitioned tables | Relational integrity for profiles/permissions/audit + scalable metric storage |
| AD-3 | R2 holds all blobs (datasets, models, uploads); Postgres holds only keys/URLs | Keeps DB lean; presigned-URL downloads |
| AD-4 | ML served inside Flask via `/predict` (internal) in V1 | Avoids a separate model server until load demands it |
| AD-5 | Paystack webhooks → Postgres payment ledger (idempotent) | Auditable money trail; supports marketplace + subscriptions |
| AD-6 | All mail via Zeptomail templates; alert emails are digests, never diagnoses | Safety copy + deliverability |
| AD-7 | Docker Compose mirrors prod services locally (api/auth/worker/db) | Dev/prod parity; one-command onboarding |

## Phase 0 — Product design

| # | Task | Owner | Exit criteria |
|---|------|-------|---------------|
| 0.1 | User flows: onboarding → connect source → dashboard → alert → trends | Frontend/PM | Flow diagrams committed |
| 0.2 | Wireframes: dashboard, alert card, trends, auth screens, billing | Frontend | Reviewed wireframes |
| 0.3 | Design tokens: severity colors (L0–L4), alert copy guidelines | Frontend | Copy rules doc (uncertainty language, no diagnosis) |
| 0.4 | Data dictionary draft: HR, SpO2, sleep stages, steps (units, ranges) | Data Eng | Draft dictionary |

## Phase 1 — Architecture & setup

| # | Task | Owner | Exit criteria |
|---|------|-------|---------------|
| 1.1 | Repo layout: `backend/ auth/ ml/ frontend/ docker/ docs/ data/` | Backend | Scaffold committed |
| 1.2 | Docker Compose: api, auth, worker, postgres (healthchecks, volumes) | Backend | `docker compose up` green |
| 1.3 | PostgreSQL schema v1: users, profiles, devices, measurements, alerts, payments, audit | Backend | Migrations committed |
| 1.4 | BetterAuth service: email/password + verification via Zeptomail; JWT issuance | Backend | Login → JWT → Flask 200 |
| 1.5 | R2 buckets + presigned URL helper; env/secret management (no hardcoded secrets) | Backend | Upload/download round-trip |
| 1.6 | CI: lint, unit tests, image build | Backend | Green pipeline |

## Phase 2 — Data & ML

| # | Task | Owner | Exit criteria |
|---|------|-------|---------------|
| 2.1 | Acquire PhysioNet sources (MIMIC-III Waveform, Sleep-EDF Expanded); record licenses | Data Eng | Sources documented |
| 2.2 | Preprocessing pipeline: clean, normalize, resample; stored in R2 + dictionary | Data Eng | Dataset + dictionary published |
| 2.3 | Baseline Isolation Forest + eval notebook (precision/recall/F1) | AI/ML | First F1 reported |
| 2.4 | LSTM model; champion selection; **F1 > 0.85** on held-out set | AI/ML | Model file (`.pkl`/`.h5`) + eval committed |
| 2.5 | Alert-threshold mapping to severity L0–L4 | AI/ML | Threshold table reviewed |

## Phase 3 — Backend API

| # | Endpoint | Auth | Purpose |
|---|----------|------|---------|
| 3.1 | `GET /api/v1/user/{id}/dashboard` | JWT | Today's HR, SpO2, sleep, activity + active alerts; p95 < 500 ms |
| 3.2 | `GET /api/v1/user/{id}/history?metric=&period=` | JWT | Week/month time series |
| 3.3 | `POST /api/v1/predict` (internal) | Service key | Model inference |
| 3.4 | `POST /api/v1/webhooks/paystack` | Signature | Payment events → ledger (idempotent) |
| 3.5 | Swagger/OpenAPI for all routes | — | Live docs |

| # | Task | Owner | Exit criteria |
|---|------|-------|---------------|
| 3.6 | Flask validation, error shapes, audit logging of significant recommendations | Backend | Tests green |
| 3.7 | Zeptomail integration: verification, alert digest, receipt templates | Backend | Test mails delivered |

## Phase 4 — Web application

| # | Task (maps to user story) | Owner | Exit criteria |
|---|---------------------------|-------|---------------|
| 4.1 | Auth screens via BetterAuth (US-01 prerequisite) | Frontend | Login/session flow works |
| 4.2 | Dashboard snapshot: HR, SpO2, sleep, activity (US-02); load < 3 s | Frontend | Page renders from API |
| 4.3 | Data-source connection flow, no manual entry (US-01) | Frontend | Simulated connect works |
| 4.4 | Alert card on anomaly (US-03) + rule-based recommendation (US-04) | Frontend | Copy follows safety rules |
| 4.5 | Trends page: week/month line charts (US-05) | Frontend | Charts from `/history` |
| 4.6 | Billing screens: plans, Paystack checkout, receipts | Frontend | Test-mode purchase works |

## Phase 5 — Payments & email hardening

| # | Task | Owner | Exit criteria |
|---|------|-------|---------------|
| 5.1 | Paystack plans/products; test → live key rotation procedure | Backend | Test purchase end-to-end |
| 5.2 | Webhook retries, reconciliation job, refund path | Backend | Ledger balances |
| 5.3 | Zeptomail domain auth (SPF/DKIM), bounce handling, unsubscribe | Backend | Deliverability checks pass |
| 5.4 | Postgres backups + restore drill; R2 lifecycle rules | Backend | Restore verified |

## Phase 6 — Testing, deployment & launch

| # | Task | Owner | Exit criteria |
|---|------|-------|---------------|
| 6.1 | Unit + integration + E2E (dataset → model → API → UI) | All | Green suite |
| 6.2 | UAT: US-01..US-05 at 100%; perf (API p95, page load); security basics | PM | Signed UAT sheet |
| 6.3 | Docker image → AWS (EB or ECS); uptime > 99.5% final 2 weeks | Backend | Prod URL live |
| 6.4 | Final report: architecture, eval results, screenshots, V2 backlog | PM | Report committed |

## Success metrics

| Goal | Metric | Target |
|------|--------|--------|
| Model quality | F1 held-out | > 0.85 |
| User value | UAT completion | 100% |
| API perf | Dashboard p95 | < 500 ms |
| Page perf | Dashboard load | < 3 s |
| Stability | Uptime (final 2 wks) | > 99.5% |

## Risks

| Risk | Mitigation |
|------|------------|
| F1 ≤ 0.85 | Time-box tuning; simplify features; record decision |
| BetterAuth↔Flask session mismatch | Contract-test JWT validation in CI; shared JWKS |
| Paystack webhook loss/duplicates | Signature verify + idempotency keys + reconciler |
| Scope creep (marketplace depth, telemedicine) | Park in V2; Phase 5 covers payments plumbing only |
| Old local toolchain | Canonical env is CI/Docker; use `gh`/current Git for pushes |

## Definition of done

Deployed URL passing 100% UAT within perf targets; champion model beats F1 with eval
notebook; Postgres + R2 + Paystack + Zeptomail + BetterAuth all live on test mode
(minimum); audit trail for recommendations and payments; no PHI; nothing framed as a
medical device.
