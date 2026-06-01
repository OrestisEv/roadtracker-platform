# Change Process

How to make changes across the RoadTracker system without breaking consistency.

## Decision tree

When you want to add or change a feature, ask these questions in order:

```
1. Does this change the database schema?
   YES → Start here (schema/migrations/), then update BOTH apps
   NO  → Continue

2. Does this feature need to behave identically on both platforms?
   YES → Tier 1. Update contracts/ and FEATURE_MATRIX.md first, then both apps.
   NO  → Continue

3. Does this feature capture data on one platform that the other should display?
   YES → Tier 2. Note it in FEATURE_MATRIX.md. Update the capturing app.
         If the other app should display the data, update it too.
   NO  → Continue

4. Is this a visual/interaction difference that doesn't affect shared data?
   YES → Tier 3. Note it in FEATURE_MATRIX.md for awareness. Update one app.
   NO  → You've found a new category. Discuss before implementing.
```

## The workflow

### For Tier 1 changes (shared)
1. Create a branch in `roadtracker-platform`
2. Update the relevant contract (`route.schema.json`, `constants.md`)
3. Update `FEATURE_MATRIX.md`
4. If schema change: write migration SQL in `schema/migrations/`
5. Merge to platform repo
6. Apply migration to Supabase (if any)
7. Update Android app repo (branch → implement → test → merge)
8. Update Web app repo (branch → implement → test → merge)
9. Test cross-platform: verify data created on one app renders correctly on the other

### For Tier 2 changes (platform-native)
1. Update `FEATURE_MATRIX.md` in platform repo (note capture vs display)
2. If new data columns needed: follow Tier 1 schema workflow first
3. Implement on the capturing platform
4. If the other platform should display: implement display there too
5. Test: create data on capturing platform, verify display on the other

### For Tier 3 changes (UX divergence)
1. Note in `FEATURE_MATRIX.md` for awareness
2. Implement on the relevant platform
3. No cross-platform testing needed

## Migration naming convention

```
schema/migrations/
  001_initial_routes.sql
  002_add_weather_column.sql
  003_add_route_tags.sql
```

Each migration file includes:
- A comment with the date and description
- The ALTER/CREATE statements
- A rollback section (commented out, for reference)

---

## Worked examples

### Example 1: Tier 1 — Adding a "miles" display toggle

**Scenario:** Users want to switch between km and miles display.

**Why Tier 1:** The *storage* stays in km (no schema change), but both apps must format the same way so "85 km" on Android doesn't show as "52.8 mi" on web due to different rounding. The formatting rules are shared.

**Step-by-step:**

1. **Platform repo** — update `contracts/constants.md`:
   - Add the miles conversion factors (already there as "future")
   - Define the exact formatting rules:
     - km: "12.4 km" (1 decimal)
     - miles: "7.7 mi" (1 decimal)
     - km/h: "85 km/h" (0 decimals)
     - mph: "53 mph" (0 decimals)
   - Define where the preference is stored: Supabase `profiles` table, column `unit_preference` ('km' | 'miles')

2. **Platform repo** — update `FEATURE_MATRIX.md`:
   - Move "Distance in km" row to "Distance display (km/miles)"
   - Mark both platforms ✅

3. **Platform repo** — if storing preference in DB, write migration:
   ```sql
   -- schema/migrations/002_add_unit_preference.sql
   ALTER TABLE public.profiles ADD COLUMN unit_preference text NOT NULL DEFAULT 'km' CHECK (unit_preference IN ('km', 'miles'));
   ```

4. **Apply migration** to Supabase via SQL Editor

5. **Android app** — update the `UnitFormatter` helper:
   - Read preference from Supabase `profiles` table
   - Format all distances/speeds through the formatter
   - Add a toggle in settings UI

6. **Web app** — same logic:
   - Read preference from Supabase `profiles` table
   - Format all distances/speeds through the same rules
   - Add a toggle in settings UI

7. **Cross-platform test:**
   - Set preference to "miles" on web
   - Open Android app → should show miles too (preference synced via profiles table)
   - Create a route on Android (stored as km in DB)
   - View on web → should display in miles with correct conversion

**What to tell AI Studio:**
```
Add a miles/km toggle. Read the unit_preference from the profiles table.
Use UnitFormatter for all distance and speed display. Follow the formatting
rules in contracts/constants.md: km shows 1 decimal ("12.4 km"), miles
shows 1 decimal ("7.7 mi"), speeds show 0 decimals. Storage stays in km.
```

**What to tell Lovable:**
```
Add a miles/km toggle. Read the unit_preference from the profiles table.
Use a formatDistance(km) and formatSpeed(kmh) utility for all display.
Follow the formatting rules in contracts/constants.md. Storage stays in km.
```

---

### Example 2: Tier 2 — Adding weather data to rides

**Scenario:** During a GPS ride, the Android app captures the weather (temperature, conditions) from an API and stores it with the route. The web app doesn't capture weather but should display it for phone-recorded rides.

**Why Tier 2:** Only Android captures (it knows when/where you're riding in real-time). But both apps display.

**Step-by-step:**

1. **Platform repo** — update `contracts/route.schema.json`:
   - Add two new optional fields:
     ```json
     "weather_temp_c": { "type": "number", "default": null, "description": "Temperature in Celsius at ride start. Captured by Android; null for web routes." },
     "weather_condition": { "type": "string", "default": null, "description": "Weather condition string (e.g. 'Partly Cloudy'). Captured by Android; null for web routes." }
     ```

2. **Platform repo** — update `contracts/constants.md`:
   - Add weather API details (endpoint, key handling)
   - Add temperature formatting: "18°C" (km mode) / "64°F" (miles mode, future)

3. **Platform repo** — write migration:
   ```sql
   -- schema/migrations/002_add_weather.sql
   ALTER TABLE public.routes ADD COLUMN weather_temp_c numeric DEFAULT null;
   ALTER TABLE public.routes ADD COLUMN weather_condition text DEFAULT null;
   ```

4. **Platform repo** — update `FEATURE_MATRIX.md`:
   - Add row: "Weather capture" → Android ✅ CAPTURE, Web ❌
   - Add row: "Weather display" → Android ✅, Web ✅ DISPLAY

5. **Apply migration** to Supabase

6. **Android app** — implement capture:
   - On ride start, call weather API with current GPS coordinates
   - Store result in `weather_temp_c` and `weather_condition`
   - Display on route detail and telemetry dashboard

7. **Web app** — implement display only:
   - Read `weather_temp_c` and `weather_condition` from route data
   - If non-null, show weather badge on route card and detail view
   - If null, don't show anything (manual/web routes won't have it)

8. **Cross-platform test:**
   - Record a GPS ride on Android → verify weather data in Supabase row
   - Open web app → the route should show weather badge
   - Create a manual route on web → no weather fields → Android shows no weather for it

**What to tell AI Studio:**
```
Add weather capture during GPS rides. On ride start, fetch weather from
[API] using current coordinates. Store temperature as weather_temp_c (Celsius)
and condition as weather_condition in the Supabase route row.
Display weather on the telemetry dashboard. These are new nullable columns
in the routes table — they may be null for manual or web-created routes.
```

**What to tell Lovable:**
```
The routes table now has two new nullable columns: weather_temp_c (numeric)
and weather_condition (text). These are set by the Android app during GPS
rides. Display them on route cards and detail views when non-null — show a
weather badge with temperature and condition icon. When null, show nothing.
Do NOT capture weather on web; display only.
```

---

### Example 3: Tier 3 — Redesigning the route list layout on web

**Scenario:** The web app's route list should switch to a table/grid view on wide screens (>1200px) for better bulk management. The Android app keeps the card-based list.

**Why Tier 3:** This is purely a visual/interaction change. The same data is displayed, the same columns are read, no shared contract is affected. The platforms are just using different layouts for the same information.

**Step-by-step:**

1. **Platform repo** — update `FEATURE_MATRIX.md`:
   - In Tier 3 table, add row: "Route list layout" → Android: "Card list", Web: "Cards (mobile) / Table (desktop)"

2. **Web app** — implement:
   - Below 1200px: keep existing card layout
   - Above 1200px: switch to a data table with sortable columns (name, date, distance, mode, duration, max speed)
   - Add column visibility toggle
   - Multi-select rows for batch delete

3. **No changes needed** to Android app, platform contracts, or schema.

**What to tell Lovable:**
```
On screens wider than 1200px, switch the route journal from card layout
to a sortable data table. Columns: name, date, distance, mode, duration,
max speed. Add sortable headers, multi-row select with checkboxes, and
a "Delete selected" batch action. Keep the card layout for mobile/tablet.
Same data, same Supabase queries — just a different view.
```

**What to tell AI Studio:**
Nothing. This doesn't affect the Android app.
