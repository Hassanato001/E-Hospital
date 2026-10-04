-- Vita schema v1 (Phase 1). Apply: psql $DATABASE_URL -f 001_init.sql
-- Measurements use monthly partitions (hypertable-style); device reports,
-- user reports, and clinician-confirmed facts stay in separate columns/tables.

CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       CITEXT UNIQUE NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE health_profiles (
  user_id     UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  conditions  TEXT[] NOT NULL DEFAULT '{}',
  medications JSONB NOT NULL DEFAULT '[]',
  allergies   TEXT[] NOT NULL DEFAULT '{}',
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE devices (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  maker       TEXT NOT NULL,
  model       TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE measurements (
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  metric      TEXT NOT NULL,               -- heart_rate | spo2 | sleep_stage | steps | ...
  value       DOUBLE PRECISION NOT NULL,
  unit        TEXT NOT NULL,
  measured_at TIMESTAMPTZ NOT NULL,
  device_id   UUID REFERENCES devices(id),
  quality     TEXT NOT NULL DEFAULT 'ok',  -- ok | noisy | gap | device
  origin      TEXT NOT NULL DEFAULT 'device', -- device | user_report | clinician
  PRIMARY KEY (user_id, metric, measured_at)
);

CREATE TABLE alerts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  severity    SMALLINT NOT NULL CHECK (severity BETWEEN 0 AND 4),
  pattern     TEXT NOT NULL,
  evidence    JSONB NOT NULL DEFAULT '{}',
  state       TEXT NOT NULL DEFAULT 'open', -- open | acknowledged | escalated | closed
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE payments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id),
  paystack_ref    TEXT UNIQUE NOT NULL,
  amount_kobo     INTEGER NOT NULL,
  status          TEXT NOT NULL,            -- pending | paid | failed | refunded
  idempotency_key TEXT UNIQUE NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audit_log (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
  action      TEXT NOT NULL,
  detail      JSONB NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_measurements_user_time ON measurements (user_id, measured_at DESC);
CREATE INDEX idx_alerts_user_state ON alerts (user_id, state);
