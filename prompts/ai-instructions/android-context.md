# AI Studio — Persistent Context for RoadTracker Android App

Paste this into AI Studio's system instructions or at the start of every session where you modify the RoadTracker Android app. It gives the AI the shared contracts so it never invents incompatible field names, colors, or behaviors.

---

## YOU ARE MODIFYING THE ROADTRACKER ANDROID APP

RoadTracker is a cross-platform motorcycle road-coverage tracker. This Android app shares a Supabase database with a separate web app. **Data compatibility is critical — never change field names, types, or formats without being told the platform contract has been updated.**

## SUPABASE TABLE: routes

The table already exists. Do NOT create, drop, or alter it. Columns and their Kotlin mappings:

| DB column (snake_case) | Kotlin field (camelCase) | Type | Notes |
|---|---|---|---|
| `id` | `id` | text | Client-generated, send on insert |
| `user_id` | — | uuid | Set to current user's auth id |
| `name` | `name` | text | |
| `date_ms` | `date` | bigint | Epoch milliseconds |
| `coordinates` | `coordinates` | jsonb | `[{"lat":Double,"lng":Double}]` |
| `distance_km` | `distance` | numeric | Always kilometers |
| `mode` | `mode` | text | Only 'gps' or 'manual' |
| `duration_seconds` | `durationSeconds` | bigint | |
| `max_speed` | `maxSpeed` | numeric | km/h |
| `avg_speed` | `avgSpeed` | numeric | km/h |
| `max_lean_angle` | `maxLeanAngle` | numeric | degrees |
| `max_g_force` | `maxGForce` | numeric | g |
| `elevation_gain` | `elevationGain` | numeric | meters |
| `telemetry_json` | `telemetryJson` | text | JSON array of TelemetrySample |
| `created_at` | — | timestamptz | Server-managed, don't set |
| `updated_at` | — | timestamptz | Server-managed, don't set |

## CRITICAL RULES

1. **Never rename DB columns.** The web app reads the same table. If you rename `distance_km` to `distance`, the web app breaks.
2. **Never change the coordinate format.** It's `{"lat": number, "lng": number}` — latitude first. OSRM uses `lng,lat` order, so flip when calling OSRM.
3. **`mode` is only 'gps' or 'manual'.** The DB has a CHECK constraint. Any other value will cause an insert failure.
4. **`date_ms` is epoch milliseconds**, not a Date object or ISO string. Convert for display only.
5. **Telemetry fields default to 0 or '' for web-created routes.** Don't crash or show errors when these are zero — it means the route was drawn on the web or imported from GPX.
6. **ID is text, not uuid.** This app generates IDs as `Date().time.toString(36) + random.toString(36)`. The web app uses `crypto.randomUUID()`. Both are valid.

## SHARED COLORS (for map polylines)

| Context | Hex |
|---|---|
| GPS route polyline | `#22D3EE` |
| Manual route polyline | `#F43F5E` |
| Active ride polyline | `#10B981` |
| Drawing mode polyline | `#FB923C` |

Polyline weight: 6, opacity: 0.85. Active ride: weight 8, opacity 0.95.

## EXTERNAL APIs (do not change URLs)

- Nominatim: `https://nominatim.openstreetmap.org/search?format=json&q={query}&limit=8`
- OSRM: `https://router.project-osrm.org/route/v1/driving/{lng,lat pairs}?overview=full&geometries=geojson`

## WHAT THIS APP CAPTURES THAT THE WEB DOESN'T

This Android app is the only place that captures: live GPS tracking, accelerometer lean angle, g-force, speed from GPS, altitude/elevation, and real-time telemetry samples. The web app can only display these values — it cannot capture them. So these fields must always be populated during GPS rides.

## UNIT FORMATTING

All distances stored as km. All speeds stored as km/h. All elevations stored as meters. Centralize formatting in one helper (UnitFormatter or similar) so a miles toggle can be added later.
