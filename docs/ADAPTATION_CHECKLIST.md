# What depends on others & how to adapt

I did NOT have Jumanah's schema or Diyam's EER in the upload, so `00_ASEEL_LOCAL_STANDIN_schema.sql`
is my own assumption (same entities as the plan). It is for local testing only – do not commit to main.

When Jumanah's `01_create_tables.sql` is ready:
1. Compare table names (Users/Projects/Sources/Claims/Evidence/Reviews/Versions/ActivityLogs).
2. Compare column names + ENUM values (e.g. status values, stance, verdict, role).
3. Check if she has extra NOT NULL columns or Evidence is a junction table (claim_id + source_id).
4. Find/replace names in `02_seed_data.sql` and `03_queries.sql`, rerun both.
5. Check her ON DELETE rules – Q19 assumes a claim with no children can be deleted (works with RESTRICT or CASCADE).
6. Seed must run BEFORE Bayader's trigger file (otherwise ActivityLogs gets seed rows).

Independent now (no waiting): seed data, queries, docs, demo script.
Needs others later: running on the real schema (Jumanah), final screenshots, PR to main (Jumanah merges).
