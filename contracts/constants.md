# Shared Constants

Both apps must use these exact values. When adding or changing a constant, update this file first, then update both apps.

## Colors — Route polylines

| Context | Hex | Usage |
|---|---|---|
| GPS route | `#22D3EE` | electric cyan — polyline for `mode='gps'` routes |
| Manual route | `#F43F5E` | neon pink — polyline for `mode='manual'` routes |
| Active GPS ride | `#10B981` | neon green — live tracking polyline |
| Drawing mode | `#FB923C` | cockpit orange — in-progress manual drawing |

Polyline rendering: weight 6, opacity 0.85, round line cap, round line join. Active ride: weight 8, opacity 0.95.

## Colors — UI chrome

| Name | Hex | Usage |
|---|---|---|
| Deep dark bg | `#0E0E12` | main background |
| Slate cockpit | `#1B1B21` | card/panel surfaces |
| Geometric border | `#2B2B33` | borders, dividers |
| Map subframe | `#050508` | map container background |
| Glassy overlay | `rgba(27, 27, 33, 0.9)` | floating HUDs |
| Electric cyan | `#22D3EE` | primary accent |
| Neon green | `#10B981` | active/live/success |
| Cockpit orange | `#FB923C` | manual/drawing mode |
| Neon pink | `#F43F5E` | manual routes, delete, alerts |
| Text silver | `#E2E2E6` | primary text |
| Text muted | `#94A3B8` | secondary/label text |

## Enums

### Route mode
Only two valid values. Never add to this without updating both apps AND the database check constraint.

| Value | Meaning | Created by |
|---|---|---|
| `gps` | Recorded via GPS tracking | Android (primary), Web browser GPS (secondary) |
| `manual` | Drawn by hand on map or imported from GPX | Android, Web |

### Sync status (internal to each app, not stored in DB)
| Value | Meaning |
|---|---|
| `synced` | Route exists in both local cache and Supabase |
| `pending_upload` | Saved locally, not yet synced to Supabase (offline) |
| `pending_delete` | Deleted locally, delete not yet synced to Supabase |

## Units

| Measurement | Storage unit | Display (km mode) | Display (miles mode, future) |
|---|---|---|---|
| Distance | kilometers (`distance_km`) | "12.4 km" | "7.7 mi" |
| Speed | km/h (`max_speed`, `avg_speed`) | "85 km/h" | "53 mph" |
| Elevation | meters (`elevation_gain`) | "340 m" | "1,115 ft" |
| Lean angle | degrees (`max_lean_angle`) | "32°" | "32°" (no conversion) |
| G-force | g (`max_g_force`) | "1.2 g" | "1.2 g" (no conversion) |
| Duration | seconds (`duration_seconds`) | "1h 23m" | "1h 23m" (no conversion) |
| Coordinates | decimal degrees (`lat`, `lng`) | not displayed raw | not displayed raw |
| Date/time | epoch milliseconds (`date_ms`) | local timezone format | local timezone format |

**Conversion factors (for future miles mode):**
- km to miles: × 0.621371
- km/h to mph: × 0.621371
- meters to feet: × 3.28084

Both apps must centralize formatting in one utility function so the miles toggle is a single change.

## External APIs

| Service | Base URL | Used for | Rate limits |
|---|---|---|---|
| Nominatim | `https://nominatim.openstreetmap.org/search` | Address/place search | 1 req/sec, include User-Agent |
| OSRM | `https://router.project-osrm.org/route/v1/driving/` | Road snapping for manual draws | Public demo server, no auth |

### Nominatim query format
```
GET /search?format=json&q={query}&limit=8&addressdetails=1
User-Agent: RoadTracker/1.0
```

### OSRM query format
```
GET /route/v1/driving/{lng1},{lat1};{lng2},{lat2};...?overview=full&geometries=geojson
```
Note: OSRM uses `lng,lat` order (reversed from our storage format). Both apps must flip coordinates before calling OSRM.

## Map tiles

| Theme | URL template | Attribution |
|---|---|---|
| Dark (default) | `https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png` | CartoDB |
| Light | `https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png` | CartoDB |

Both apps must include proper attribution: `© OpenStreetMap contributors © CARTO`

## Algorithms

### Haversine distance (must produce identical results)

```
R = 6371 (Earth radius in km)
dLat = (lat2 - lat1) × π / 180
dLng = (lng2 - lng1) × π / 180
a = sin²(dLat/2) + cos(lat1 × π/180) × cos(lat2 × π/180) × sin²(dLng/2)
c = 2 × atan2(√a, √(1-a))
distance = R × c
```

Total route distance = sum of Haversine between consecutive RoutePoint pairs.

## Date/time formatting

| Context | Format | Example |
|---|---|---|
| Route list | Short date + time | "Jun 1, 2026 14:30" |
| Route detail | Full date + time | "Sunday, June 1, 2026 at 14:30" |
| Duration | Hours + minutes | "1h 23m" (if < 1h, show "23m") |
| Stats | Date only | "Jun 1, 2026" |

Always display in the user's local timezone. Store in UTC epoch milliseconds.

## ID generation

| Platform | Method | Example |
|---|---|---|
| Android | `Date().time.toString(36) + random.toString(36)` | `"lt9f3k2x"` |
| Web | `crypto.randomUUID()` | `"46b82943-6ead-4b48-93ad-ffa4ec1fcee0"` |

Both are valid. The `id` column is `text`, not `uuid`. Never assume the format of an id from the other platform.
