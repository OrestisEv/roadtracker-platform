# Supabase Setup

Reference for the RoadTracker backend. This was already set up — this doc exists for onboarding new contributors or recreating the backend.

## Project details

- **Provider:** Supabase (free tier)
- **Region:** Central Europe (Zurich)
- **Project name:** Mototracker

## What's configured

1. **Schema:** `routes` table with 16 columns (see `schema/routes.sql`)
2. **Row Level Security:** 4 policies (select, insert, update, delete) — all filtered by `auth.uid() = user_id`
3. **Realtime:** enabled for `routes` table via `supabase_realtime` publication
4. **Auth provider:** Google OAuth
5. **Redirect URLs:** configured for Lovable web app and Android deep link

## Keys (for contributors)

Contributors do not need Supabase credentials to develop. The app repos contain all the code; Supabase is the live backend. Only the maintainer has write access to the Supabase dashboard.

For testing against the live backend, ask the maintainer for the anon key. The anon key is safe to use in clients (RLS protects the data).

## Google OAuth setup

Configured in Google Cloud Console with two OAuth clients:
- **Web application** (for Supabase + Lovable web app)
- **Android** (for the native app, if using native SDK flow)

The Supabase callback URL is registered as an authorized redirect URI in the Web client.
The Android app uses a deep link redirect (`com.aistudio.roadtracker.kxymqd://login-callback`).
