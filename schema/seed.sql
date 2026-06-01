-- RoadTracker seed data for development
-- Replace USER_ID with an actual auth.users id from your Supabase project
-- Run via SQL Editor after creating a test user

-- Example GPS route (with telemetry, simulating a phone ride)
INSERT INTO public.routes (id, user_id, name, date_ms, coordinates, distance_km, mode, duration_seconds, max_speed, avg_speed, max_lean_angle, max_g_force, elevation_gain, telemetry_json)
VALUES (
  'seed_gps_001',
  'USER_ID',
  'Morning ride to Satigny',
  1780263309051,
  '[{"lat":46.199791,"lng":6.077483},{"lat":46.205123,"lng":6.065432},{"lat":46.212456,"lng":6.048765},{"lat":46.216105,"lng":6.004094}]',
  8.5,
  'gps',
  1200,
  95.5,
  48.2,
  28.5,
  1.1,
  120.0,
  '[{"timeSec":0,"speedKmh":0,"leanAngle":0,"gForce":1.0,"altitude":380},{"timeSec":60,"speedKmh":45.2,"leanAngle":12.3,"gForce":1.05,"altitude":385},{"timeSec":120,"speedKmh":72.8,"leanAngle":28.5,"gForce":1.1,"altitude":400}]'
);

-- Example manual route (drawn on web, no telemetry)
INSERT INTO public.routes (id, user_id, name, date_ms, coordinates, distance_km, mode, duration_seconds, max_speed, avg_speed, max_lean_angle, max_g_force, elevation_gain, telemetry_json)
VALUES (
  'seed_manual_001',
  'USER_ID',
  'Route des Alpes sketch',
  1780263293214,
  '[{"lat":46.216105,"lng":6.004094},{"lat":46.225000,"lng":5.985000},{"lat":46.240000,"lng":5.970000}]',
  5.2,
  'manual',
  0,
  0,
  0,
  0,
  0,
  0,
  ''
);
