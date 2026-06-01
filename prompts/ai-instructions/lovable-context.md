# Lovable — Persistent Context for RoadTracker Web App

Paste this into Lovable's project instructions or at the start of every session where you modify the RoadTracker web app. It gives the AI the shared contracts so it never invents incompatible field names, colors, or behaviors.

---

## YOU ARE MODIFYING THE ROADTRACKER WEB APP

RoadTracker is a cross-platform motorcycle road-coverage tracker. This web app shares a Supabase database with a separate Android app. **Data compatibility is critical — never change field names, types, or formats without being told the platform contract has been updated.**

## SUPABASE TABLE: routes

The table already exists. Do NOT create, drop, or alter it. Columns and their JS/TS mappings:

| DB column (snake_case) | JS property | Type | Notes |
|---|---|---|---|
| `id` | `id` | text | Generate with `crypto.randomUUID()` |
| `user_id` | `user_id` | uuid | Set to current user's auth id |
| `name` | `name` | text | |
| `date_ms` | `date_ms` | bigint | Epoch milliseconds (use `Date.now()` to create, `new Date(date_ms)` to display) |
| `coordinates` | `coordinates` | jsonb | `[{"lat":number,"lng":number}]` |
| `distance_km` | `distance_km` | numeric | Always kilometers |
| `mode` | `mode` | text | Only `'gps'` or `'manual'` |
| `duration_seconds` | `duration_seconds` | bigint | Default 0 for web routes |
| `max_speed` | `max_speed` | numeric | km/h. Default 0 for web routes |
| `avg_speed` | `avg_speed` | numeric | km/h. Default 0 for web routes |
| `max_lean_angle` | `max_lean_angle` | numeric | degrees. Default 0 for web routes |
| `max_g_force` | `max_g_force` | numeric | g. Default 0 for web routes |
| `elevation_gain` | `elevation_gain` | numeric | meters. Default 0 for web routes |
| `telemetry_json` | `telemetry_json` | text | Default '' for web routes. Parse as JSON when displaying phone routes. |
| `created_at` | — | timestamptz | Server-managed, don't set |
| `updated_at` | — | timestamptz | Server-managed, don't set |

## CRITICAL RULES

1. **Never rename DB columns.** The Android app reads the same table. If you rename `distance_km` to `distance`, the Android app breaks.
2. **Never change the coordinate format.** It's `{"lat": number, "lng": number}` — latitude first. OSRM uses `lng,lat` order, so flip when calling OSRM.
3. **`mode` is only `'gps'` or `'manual'`.** The DB has a CHECK constraint. Any other value will cause an insert failure.
4. **`date_ms` is epoch milliseconds**, not a Date object or ISO string. Use `Date.now()` when creating, convert for display only.
5. **When creating routes on web, set telemetry fields to defaults:** `duration_seconds: 0`, `max_speed: 0`, `avg_speed: 0`, `max_lean_angle: 0`, `max_g_force: 0`, `elevation_gain: 0`, `telemetry_json: ''`.
6. **When displaying phone-created routes, respect non-zero telemetry.** If `max_speed > 0` or `telemetry_json !== ''`, display them — the phone captured real data.
7. **ID is text, not uuid.** The Android app generates short base36 IDs like `"lt9f3k2x"`. This app uses `crypto.randomUUID()`. Both are valid. Never assume ID format.

## SHARED COLORS (for map polylines — must match Android exactly)

| Context | Hex |
|---|---|
| GPS route polyline | `#22D3EE` |
| Manual route polyline | `#F43F5E` |
| Active ride polyline | `#10B981` |
| Drawing mode polyline | `#FB923C` |

Polyline weight: 6, opacity: 0.85. Active ride: weight 8, opacity 0.95.

## UI CHROME COLORS (cockpit theme)

| Name | Hex |
|---|---|
| Deep dark bg | `#0E0E12` |
| Slate cockpit | `#1B1B21` |
| Geometric border | `#2B2B33` |
| Map subframe | `#050508` |
| Glassy overlay | `rgba(27, 27, 33, 0.9)` |
| Electric cyan | `#22D3EE` |
| Neon green | `#10B981` |
| Cockpit orange | `#FB923C` |
| Neon pink | `#F43F5E` |
| Text silver | `#E2E2E6` |
| Text muted | `#94A3B8` |

## EXTERNAL APIs (do not change URLs)

- Nominatim: `https://nominatim.openstreetmap.org/search?format=json&q={query}&limit=8`
- OSRM: `https://router.project-osrm.org/route/v1/driving/{lng,lat pairs}?overview=full&geometries=geojson`

## WHAT THIS WEB APP CAPTURES vs DISPLAYS

**Captures:** manual route drawing, GPX import, browser GPS (optional). All save as routes with telemetry defaults = 0/''.

**Displays but does not capture:** telemetry stats (speed, lean, g-force, elevation) — the Android app captures these during GPS rides. When `telemetry_json` is non-empty, parse it as: `[{"timeSec":int, "speedKmh":number, "leanAngle":number, "gForce":number, "altitude":number}]` and render charts/stats.

## UNIT FORMATTING

All distances stored as km. All speeds stored as km/h. All elevations stored as meters. Centralize formatting in one utility (`formatDistance(km)`, `formatSpeed(kmh)`, `formatElevation(m)`) so a miles toggle can be added later by changing one file.

## TELEMETRY DISPLAY (for phone-created routes)

When showing a route where telemetry is available:
- Parse `telemetry_json` as a JSON array of TelemetrySample objects
- Show speed-over-time chart (Recharts or similar)
- Show stat cards: Duration, Max Speed, Avg Speed, Max Lean Angle, Max G-Force, Elevation Gain
- Use monospace font for numbers, muted uppercase labels, cockpit aesthetic

When telemetry is empty (manual/web routes):
- Show "No telemetry — this route was drawn manually" placeholder
- Still show distance and date
