# E-Hospital — HealthGuard / Project Vita

AI-powered personal health monitoring and care-navigation platform.
Connects continuous health data (wearables, medical devices, user-reported info) to
personalized insights and the appropriate level of human medical care.

> **Prototype disclaimer:** V1 is a single-user demo. It is **not a medical device**,
> handles **no real PHI**, and does not replace physicians or emergency services.
> User-facing insights communicate risk + recommended action, never an AI diagnosis as fact.

## Vision

A single platform that turns raw wearable measurements into contextual information
and actionable next steps:

**Monitor → Understand → Recommend → Connect → Escalate**

Long-term product name: **HealthGuard — Intelligent Personal Health Monitoring & Care Platform**.
V1 implementation codename: **Project Vita** (proves the data → anomaly detection → recommendation pipeline).

## The problem

Wearable users collect vast amounts of data (heart rate, SpO2, sleep, activity) but get
simple graphs with little context. They see the *what* but not the *so what*:
what it means, whether it matters, and what to do next.

## Who it serves

**Primary (broad population):** general adults, cardiovascular / hypertension / diabetes /
stroke-history / hepatitis A-D monitoring, pregnant women, menstrual-cycle tracking,
older adults, chronic-disease management, post-illness recovery, preventive health.

**Secondary:** family/caregivers, GPs, specialists, nurses, pharmacists,
emergency/urgent-care staff, hospitals.

V1 persona: **"Health-Conscious Alex" (30–45)** — tech-savvy wearable user who wants
trends, early alerts, and simple evidence-based advice.

## How it works

1. **Data ingestion** — smartwatches, fitness trackers, rings, BP monitors,
   pulse oximeters, ECG devices, CGMs, thermometers (V1 uses a PhysioNet-derived dataset).
2. **Health profile** — demographics, conditions, meds, allergies, pregnancy/menstrual info,
   procedures, hospitalizations, lifestyle, preferences.
3. **Health intelligence engine** — `personal baseline + clinical thresholds + context + clinician rules`.
4. **Recommendation engine** — action based on pattern, severity, confidence, profile,
   symptoms, meds, activity, sleep.
5. **Escalation engine** — Monitor → Inform → Contact clinician → Urgent care → Emergency.
6. **Healthcare connectivity** — doctors, specialists, nurses, pharmacists, hospitals,
   emergency services (where supported).

### Detection layers

1. Data quality (is the measurement reliable?)
2. Personal baseline (deviation from *your* normal)
3. Clinical thresholds (validated rules)
4. Context (age, sex, pregnancy, history, meds, activity, sleep, illness)
5. Clinician rules (per-patient parameters)

### Alert severity

| Level | Meaning | Example |
|-------|---------|---------|
| 0 Informational | No concern | "Activity was lower than usual today." |
| 1 Monitor | Deviation worth watching | "Resting HR above usual for several readings. Monitor + log symptoms." |
| 2 Clinical follow-up | Warrants professional review | "Persistent change from usual pattern. Consider contacting your clinician." |
| 3 Urgent | Seek prompt care per pathway | — |
| 4 Emergency | Predefined emergency pattern | Immediate instructions + emergency contact where supported |

Design rule: **Measurement ≠ anomaly ≠ risk ≠ diagnosis ≠ treatment.**

## V1 scope (Project Vita, 8-week target)

User stories: connect data source (US-01), dashboard snapshot of HR/SpO2/sleep/activity (US-02),
anomaly alert card (US-03), rule-based recommendation (US-04), historical trend charts (US-05).

- **Data:** simulated/normalized PhysioNet combination — MIMIC-III Waveform (HR, SpO2)
  + Sleep-EDF Expanded (sleep) + daily steps. Clean dataset + data dictionary in shared storage.
- **AI:** Isolation Forest + LSTM anomaly detection, saved as `.pkl`/`.h5`,
  target **F1 > 0.85** on held-out test set. Recommendations are rule-based in V1.
- **Backend:** Flask REST API —
  `GET /api/v1/user/{user_id}/dashboard`,
  `GET /api/v1/user/{user_id}/history?metric=<name>&period=<period>`,
  `POST /api/v1/predict` (internal). Swagger/OpenAPI docs, p95 < 500 ms.
- **Frontend:** responsive Flask + Jinja2 web app — dashboard, alert card,
  trends page (line charts). Dashboard load < 3 s.
- **Deploy:** Docker container, AWS (Elastic Beanstalk or ECS), uptime > 99.5% (final 2 weeks).

**Out of scope for V1:** direct wearable APIs (Fitbit/HealthKit → V2), native mobile app,
multi-user auth (single-user demo mode), ML-learned recommendations, HIPAA compliance.

## Roadmap

- **MVP (this repo):** account/profile, medical/medication/pregnancy/cycle tracking,
  wearable integration (HR, activity, sleep, SpO2, BP where supported), personal baselines,
  severity alerts, recommendations, first-aid info, provider/hospital discovery,
  consent + caregiver permissions, clinician portal (trends, alerts, notes, monitoring params).
- **Phase 2:** telemedicine, medication + equipment marketplaces, pharmacy integration,
  EHR integrations, more wearables, CGM/ECG workflows, pregnancy + chronic-disease programs.
- **Phase 3 (subject to validation + regulatory clearance):** advanced CDS,
  predictive models, hospital/RPM integrations, population analytics (de-identified),
  expanded emergency integrations.

## Repository contents

- `Product Requirement Documents.docx` — full HealthGuard PRD (vision, architecture, safety, roadmap).
- `mpv.docx` — Project Vita V1 PRD + implementation plan (MVP scope, team tasks).
- `README.md` — this file.

## Getting started

V1 build not yet scaffolded. Planned layout per PRD:

- `data/` — dataset + dictionary (PhysioNet-derived, simulated)
- `ml/` — training notebooks, model files, evaluation
- `backend/` — Flask API (`/api/v1/...`), Swagger docs
- `frontend/` — Jinja2 templates, static assets, charts
- `docker/` — Dockerfile, deployment configs

## Safety, privacy, regulatory

- Communicate uncertainty; distinguish measurement vs. interpretation; never fabricate
  or claim a physical exam; never present inference as confirmed diagnosis.
- Explain key factors; encourage professional evaluation; avoid alarm and false reassurance.
- Audit significant AI recommendations; log all emergency accesses.
- Encryption in transit/at rest, MFA, RBAC, consent management, minimum-necessary access,
  user-controlled sharing, data export/deletion (subject to law).
- Regulatory classification (SaMD, privacy, telemedicine, pharmacy, AI/CDS, data residency)
  must be resolved per jurisdiction **before** clinical functionality ships.

## Success metrics

- Product: device connection rate, DAU/WAU, data availability, recommendation/alert engagement,
  clinician connection rate, adherence engagement.
- Safety (critical): false-positive rate, measurable false negatives, response time,
  escalation accuracy, clinician override rate, inappropriate-recommendation reports, data-quality failures.
- Clinical (where validated): agreement with clinical criteria, sensitivity/specificity,
  appropriate escalation/referral rates. Optimize safety + usefulness, not alert volume.
