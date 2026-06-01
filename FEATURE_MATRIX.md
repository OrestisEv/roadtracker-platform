# Feature Matrix

Every feature in RoadTracker belongs to one of three tiers. This matrix is the single source of truth — check it before building anything.

## How to read this

- **Tier 1 (Shared):** Must work identically on both platforms. Changes start in `roadtracker-platform`, then propagate to both apps.
- **Tier 2 (Platform-native):** Only implemented on one platform due to hardware/context, but data flows through the shared schema so the other platform can display results.
- **Tier 3 (UX divergence):** Acceptable visual/interaction differences. No shared contract needed.

## Tier 1 — Shared features

These touch the same data. If one app changes behavior, the other must follow.

| Feature | Android | Web | Shared contract | Notes |
|---|---|---|---|---|
| Google sign-in | ✅ | ✅ | Supabase Auth | Same Google account = same data |
| Sign out | ✅ | ✅ | Supabase Auth | |
| View all routes on map | ✅ | ✅ | `route.schema.json` | GPS=cyan, Manual=pink, same weight/opacity |
| Route list/journal | ✅ | ✅ | `route.schema.json` | Name, date, distance, mode, color bar |
| Route stats display | ✅ | ✅ | `constants.md` → stats | Distance, duration, max/avg speed, elevation gain, max lean, max g-force |
| Create manual route | ✅ | ✅ | `route.schema.json` | Draw waypoints → OSRM snap → save |
| Delete route | ✅ | ✅ | `route.schema.json` | Delete from Supabase by id |
| Rename route | ✅ | ✅ | `route.schema.json` | Update `name` in Supabase |
| Address search | ✅ | ✅ | `constants.md` → APIs | Nominatim, same endpoint |
| OSRM road snapping | ✅ | ✅ | `constants.md` → APIs | Same endpoint, snap before save |
| Distance in km | ✅ | ✅ | `constants.md` → units | Always store km; display formatted |
| Realtime sync | ✅ | ✅ | Supabase Realtime | Route saved anywhere appears everywhere |
| Route polyline colors | ✅ | ✅ | `constants.md` → colors | GPS=#22D3EE, Manual=#F43F5E |
| Dark map theme | ✅ | ✅ | `constants.md` → map | CartoDB dark_all as default |
| Light map theme toggle | ✅ | ✅ | `constants.md` → map | CartoDB light_all |
| Date/time display | ✅ | ✅ | `constants.md` → formats | Store epoch ms, display local time |
| Route mode values | ✅ | ✅ | `constants.md` → enums | Only 'gps' or 'manual', no other values |
| Haversine distance calc | ✅ | ✅ | `constants.md` → algorithms | Same formula, km output |

## Tier 2 — Platform-native features

Hardware or context-dependent. One platform captures, both display where possible.

| Feature | Android | Web | Data flow | Notes |
|---|---|---|---|---|
| Live GPS tracking | ✅ CAPTURE | ❌ | Writes `mode='gps'` route to Supabase | Phone on handlebars |
| Browser GPS tracking | ❌ | ✅ CAPTURE | Writes `mode='gps'` route to Supabase | Optional, less accurate than phone |
| Accelerometer/lean angle | ✅ CAPTURE | ❌ | Writes to `max_lean_angle` + `telemetry_json` | Hardware sensor |
| G-force measurement | ✅ CAPTURE | ❌ | Writes to `max_g_force` + `telemetry_json` | Hardware sensor |
| Speed from GPS | ✅ CAPTURE | ❌ | Writes to `max_speed`, `avg_speed` | GPS provider |
| Altitude tracking | ✅ CAPTURE | ❌ | Writes to `elevation_gain` + `telemetry_json` | GPS/barometer |
| Real-time telemetry HUD | ✅ | ❌ | In-memory only during ride | Speed, lean, g-force live gauges |
| Telemetry chart display | ✅ | ✅ DISPLAY | Reads `telemetry_json` | Both parse and chart the data |
| Telemetry stats display | ✅ | ✅ DISPLAY | Reads aggregate columns | max_speed, avg_speed, etc. |
| GPX file import | ❌ | ✅ CAPTURE | Parses file → writes route to Supabase | Drag & drop on web |
| GPX file export | ❌ | ✅ | Reads coordinates → generates .gpx | Download file |
| Bulk route management | ❌ | ✅ | Multi-select → batch delete | Wide screen advantage |
| Offline ride caching | ✅ | ❌ | Room DB → queue sync on reconnect | Phone loses signal |
| Foreground service | ✅ | ❌ | Android OS requirement | Keeps GPS alive |
| Background location | ✅ | ❌ | Android OS requirement | Screen-off tracking |
| Notification during ride | ✅ | ❌ | Android notification channel | "Recording ride..." |

## Tier 3 — Acceptable UX divergence

These can differ without breaking consistency. No shared contract.

| Aspect | Android | Web | Notes |
|---|---|---|---|
| Navigation pattern | Bottom sheet + FABs | Sidebar + bottom sheet | Platform conventions |
| Touch targets | 48dp minimum | 44px minimum | Platform guidelines |
| Map container shape | Rounded 32dp | Rounded 32px | Similar but not pixel-identical |
| Splash/loading screen | Branded splash | Instant load | Android convention |
| Settings location | Profile menu | Header dropdown | Platform convention |
| Animations | Compose animations | CSS transitions | Platform-native |
| Font rendering | System (Roboto) | System sans-serif | OS-dependent |
| Offline indicator | Status bar in stats | Banner/toast | Different UX patterns |
| Keyboard shortcuts | N/A | Ctrl+D draw, Esc cancel | Web advantage |

## Adding a new feature

1. Determine the tier (use the decision tree in `docs/change-process.md`)
2. Add it to this matrix FIRST with status markers
3. If Tier 1: update contracts in this repo → update both apps
4. If Tier 2: note which platform captures vs displays → update relevant app(s)
5. If Tier 3: update relevant app only, note it here for awareness
