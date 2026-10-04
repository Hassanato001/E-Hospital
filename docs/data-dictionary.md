# Phase 0.4 — Data Dictionary (draft)

Metrics supported in V1. All demo/simulated data unless stated.

| Metric | Unit | Source | Sampling | Normal range note |
|--------|------|--------|----------|-------------------|
| Heart rate | bpm | MIMIC-III Waveform | 1 Hz → 1-min median | Personal baseline ± context |
| Resting HR | bpm | Derived (sleep + stillness) | Daily | Personal baseline, multi-day window |
| SpO₂ | % | MIMIC-III Waveform | 1 Hz → 1-min median | 95–100 typical; device-grade only |
| Sleep stages | code | Sleep-EDF Expanded | 30-s epochs | awake/light/deep/REM |
| Sleep duration | hours | Derived | Daily | 7–9 typical adult |
| Steps | count | Simulated | Daily total | Personal baseline |
| Activity intensity | level | Derived | Daily | sedentary/light/moderate/vigorous |

## Quality flags (every measurement carries these)

| Flag | Meaning |
|------|---------|
| `ok` | Reliable enough to interpret |
| `noisy` | Motion/artifact suspected — down-weighted |
| `gap` | Missing data — never interpolated silently |
| `device` | Which device + model produced it |

## Rules

- Raw data lands in R2; Postgres stores keys + aggregates, never silently-filled gaps.
- Device readings, user reports, and clinician-confirmed facts are stored separately.
- Inferred risk is never stored as a diagnosis.
