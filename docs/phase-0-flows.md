# Phase 0.1 — User Flows

Persona: Health-Conscious Alex. One loop: connect → see → alerted → act → track.

## Flow 1 — Onboarding + connect source

```mermaid
flowchart LR
    A[Open app] --> B[Sign up via BetterAuth]
    B --> C[Verify email - Zeptomail]
    C --> D[Fill health profile]
    D --> E[Connect data source]
    E --> F[Dashboard]
```

Steps: sign up → verify email → health profile (conditions, meds, pregnancy/menstrual
where relevant) → connect source (simulated in V1, no manual entry) → land on dashboard.
Exit: dashboard shows today's metrics.

## Flow 2 — Daily check (dashboard)

```mermaid
flowchart LR
    A[Open dashboard] --> B{Active alerts?}
    B -->|No| C[View HR, SpO2, sleep, activity]
    B -->|Yes| D[Read alert card]
    C --> E[Done]
```

Exit: Alex sees today's snapshot in under 3 seconds.

## Flow 3 — Alert → action

```mermaid
flowchart LR
    A[Alert card appears] --> B[Read pattern + recommendation]
    B --> C{Severity?}
    C -->|L0-L1| D[Check again / dismiss]
    C -->|L2| E[Contact a clinician]
    C -->|L3| F[Find urgent care]
    C -->|L4| G[Emergency help]
    D --> H[Logged to timeline]
    E --> H
    F --> H
    G --> H
```

Copy rule: explain pattern + uncertainty + next action. Never a diagnosis.
Every action is logged to the health timeline.

## Flow 4 — Trends

```mermaid
flowchart LR
    A[Open Trends] --> B[Pick metric: HR, SpO2, sleep, steps]
    B --> C[Pick period: week / month]
    C --> D[View line chart vs personal baseline]
```

Exit: chart renders from `GET /history`.
