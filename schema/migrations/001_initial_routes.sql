-- Migration 001: Initial routes table
-- Date: 2026-05-31
-- Description: Creates the routes table with RLS and realtime

-- This is the initial schema. See ../routes.sql for the full canonical version.
-- This file exists for migration tracking — it was already applied to production.

-- ROLLBACK (if needed):
-- DROP TRIGGER IF EXISTS routes_touch_updated ON public.routes;
-- DROP FUNCTION IF EXISTS public.touch_updated_at();
-- DROP TABLE IF EXISTS public.routes;
