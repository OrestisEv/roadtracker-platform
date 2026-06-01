# Architecture

## System overview

RoadTracker is a two-client, one-backend system. Both clients are thin — Supabase is the single source of truth.

```
┌──────────────┐     ┌──────────────┐
│  Android App │     │   Web App    │
│  Kotlin/     │     │   React/     │
│  Compose     │     │   Lovable    │
│  + Leaflet   │     │   + Leaflet  │
│  WebView     │     │              │
│  + Room cache│     │  Online-only │
└──────┬───────┘     └──────┬───────┘
       │                    │
       │  Google OAuth      │  Google OAuth
       │  CRUD + Realtime   │  CRUD + Realtime
       │                    │
       └────────┬───────────┘
                │
       ┌────────▼────────────┐
       │   Supabase          │
       │   ┌──────────────┐  │
       │   │ Google Auth   │  │
       │   ├──────────────┤  │
       │   │ PostgreSQL    │  │
       │   │ routes table  │  │
       │   │ + RLS         │  │
       │   ├──────────────┤  │
       │   │ Realtime      │  │
       │   └──────────────┘  │
       └─────────────────────┘
                │
       ┌────────▼────────────┐
       │  External APIs      │
       │  • Nominatim        │
       │  • OSRM             │
       └─────────────────────┘
```

## Data flow

1. **Rider goes on a ride (Android):** GPS tracks coordinates + telemetry → saves to Room → syncs to Supabase → Realtime notifies web app → route appears on web.

2. **Rider draws a past route (Web):** Click waypoints → OSRM snaps to roads → saves to Supabase → Realtime notifies Android → route appears on phone.

3. **Rider imports GPX (Web):** Upload .gpx → parse coordinates → Haversine distance → save to Supabase → syncs to Android.

4. **Rider is offline (Android):** GPS tracks and saves to Room → queued for sync → when back online, pushes to Supabase.

## Security model

- **Authentication:** Google OAuth via Supabase Auth. Same Google account = same data on both platforms.
- **Authorization:** Row Level Security on the `routes` table. Every query is filtered by `auth.uid() = user_id`. One user cannot see another's routes.
- **Transport:** All Supabase traffic over HTTPS. Nominatim and OSRM over HTTPS.

## Offline strategy

| Platform | Offline behavior |
|---|---|
| Android | Room (SQLite) acts as offline cache. Writes go to Room first, then queue for Supabase sync. Reads always from Room (fast). |
| Web | Online-only. No offline support. |
