# RoadTracker Platform

The single source of truth for the RoadTracker motorcycle road-coverage tracking system.

RoadTracker lets riders paint every road they've ridden on a map — a coloring book where riding is the crayon. This repo governs the **shared contracts, schema, feature matrix, and documentation** across all RoadTracker clients.

## The system

| Component | Repo | Tech |
|---|---|---|
| Android app | [Riders-track-map](https://github.com/OrestisEv/Riders-track-map) | Kotlin, Jetpack Compose, Leaflet WebView |
| Web app | [road-tracker-web](https://github.com/OrestisEv/road-tracker-web) | React (Lovable), Leaflet |
| Platform contracts | **this repo** | Schema, docs, governance |
| Backend | Supabase (hosted) | PostgreSQL, Auth, Realtime |

## How this repo works

**Rule: if a change affects both apps, it starts here. If it only affects one app, it stays in that app's repo.**

- `schema/` — the canonical database schema. All migrations happen here first, then get applied to Supabase, then both apps update.
- `contracts/` — shared type definitions, constants, and enums that both apps must agree on.
- `docs/` — architecture, setup guides, onboarding.
- `prompts/` — reference prompts for AI Studio and Lovable, plus persistent AI instructions.
- `FEATURE_MATRIX.md` — what each platform does, organized by tier.

## Quick links

- [Feature Matrix](FEATURE_MATRIX.md) — what's shared vs platform-specific
- [Architecture](docs/architecture.md) — system diagram and data flows
- [Route Schema Contract](contracts/route.schema.json) — the canonical Route object
- [Constants](contracts/constants.md) — shared colors, enums, units
- [Supabase Setup](docs/supabase-setup.md) — backend setup guide
- [Change Process](docs/change-process.md) — how to make changes across the system
- [Contributing](CONTRIBUTING.md) — how to contribute + stakeholder model
- [License](LICENSE) — non-commercial source-available
