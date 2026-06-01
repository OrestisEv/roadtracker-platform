# Onboarding — New Contributor Guide

Welcome to RoadTracker. Here's how to get oriented.

## What is RoadTracker?

A motorcycle road-coverage tracker. Riders "paint" every road they've ridden on a map — the more you ride, the more the map fills in. There's a native Android app for riding and a web app for managing routes at home. Both share the same database.

## Repo map

| Repo | What's in it | When to touch it |
|---|---|---|
| `roadtracker-platform` (this one) | Contracts, schema, docs, governance | Shared changes, schema changes, docs |
| `Riders-track-map` | Android app (Kotlin/Compose) | Android-only features |
| `road-tracker-web` | Web app (React/Lovable) | Web-only features |

## First steps

1. Read [FEATURE_MATRIX.md](../FEATURE_MATRIX.md) — understand what exists
2. Read [architecture.md](architecture.md) — understand the system
3. Read [change-process.md](change-process.md) — understand how to make changes
4. Read [CONTRIBUTING.md](../CONTRIBUTING.md) — understand the rules and stakeholder model
5. Pick an issue from any of the three repos and start

## Key concepts

- **The platform repo is the boss.** If the Android app says a column is called `distance` and this repo says it's `distance_km`, this repo is right.
- **Tier determines workflow.** Check the feature matrix before coding anything. If it's Tier 1, you touch multiple repos. If it's Tier 3, you touch one.
- **Both apps talk to Supabase.** You don't need to run a backend server. Supabase is hosted and the schema is already deployed.
- **AI tools build both apps.** The Android app is built in Google AI Studio, the web app in Lovable. The `prompts/ai-instructions/` folder has the context each AI needs.

## Local development

- **Android:** Clone `Riders-track-map`, open in Android Studio, add Supabase keys to `local.properties` or hardcode for dev
- **Web:** The Lovable project is at `road-tracker-web.lovable.app`. For local dev, clone and run `npm install && npm run dev`
- **You don't need Supabase access to read code.** You only need it to test against the live DB. Ask the maintainer for the anon key.
