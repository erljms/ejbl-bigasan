-- =============================================================================
-- Migration 002: Enforce caller RLS on Views (PostgreSQL 15+ security_invoker)
-- Status: Proposed migration (run in Supabase SQL Editor after 001)
-- =============================================================================

-- By default, PostgreSQL views execute with the view owner's privileges
-- (SECURITY DEFINER behavior), which can bypass caller RLS on underlying tables.
-- Setting security_invoker = true ensures queries on v_inventory_summary and
-- v_cashbook_entries enforce the signed-in user's exact RLS policies.

ALTER VIEW public.v_inventory_summary SET (security_invoker = true);
ALTER VIEW public.v_cashbook_entries SET (security_invoker = true);
