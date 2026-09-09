# Chinook dbt Certification Prep — Project Context

## What this project is
A from-scratch dbt project built to cover every topic on the official dbt
Analytics Engineering Certification exam (dbt Core 1.11), using the Chinook
dataset (digital music store: customers, invoices, invoice_items, tracks,
albums, artists, genres, employees, media_types, playlists, playlist_tracks)
loaded into BigQuery Sandbox.

This is also intended as a portfolio project — repo name on GitHub is
`chinook-analytics-engineering`.

## How I want you to work with me
This is a study project, not just a delivery task. As you run commands,
write models, or fix errors:
- Explain the reasoning behind each step, not just the mechanics — what
  it does AND why it's the right approach.
- Explicitly call out which dbt certification exam topic each piece maps
  to (see the topic coverage map below).
- When something breaks, explain what caused it, not just the fix — I
  want to understand the failure mode, not just move past it.
- I give direct corrective feedback when output doesn't match what I
  asked for — take it as calibration, not criticism, and just fix it.

## Environment setup — read this before running any commands
Always activate the `chinook_dbt` conda environment before running any
`dbt`, `pip`, or Python command in this project:
```
conda activate chinook_dbt
```
`dbt-bigquery` is installed in this env only — running dbt commands
without activating it first will fail with a "command not found" or
missing-adapter error. `gcloud`/`bq` CLI commands are unaffected by the
conda env and will work either way.

## Current status (Session 2 — complete)
- Staging layer built in `chinook_dbt/models/staging/` (flat, not nested
  under a per-source subfolder — deliberate, since this project has only
  one source system; the `stg_chinook__` prefix already disambiguates):
  `stg_chinook__artists`, `stg_chinook__albums`, `stg_chinook__genres`,
  `stg_chinook__media_types` (ephemeral), `stg_chinook__tracks`,
  `stg_chinook__playlists`, `stg_chinook__playlist_tracks`,
  `stg_chinook__customers`, `stg_chinook__employees`,
  `stg_chinook__invoices`, `stg_chinook__invoice_items`
- Model naming convention: `stg_<source>__<object>` (dbt Labs style guide),
  not the bare `stg_<object>` originally sketched — decided this session
  since it's what the exam tests and scales if a second source is added
- `employees.ReportsTo`'s `"---"` null placeholder cleaned via
  `cast(nullif(ReportsTo, '---') as int64)` in `stg_chinook__employees`
- Found the same `"---"` placeholder pattern independently in
  `invoices.BillingState` (not just employees) — cleaned the same way in
  `stg_chinook__invoices`. Worth remembering: this null-placeholder
  convention isn't a one-off, so don't assume it's scoped to one column
- `stg_chinook__media_types` is the deliberately `ephemeral` model — a
  2-column lookup only ever consumed by `stg_chinook__tracks`, so it's
  compiled inline as a CTE rather than persisted as its own view
- `_chinook__sources.yml` renamed from `_chinook_sources.yml`; also fixed
  two dbt 1.12 deprecations pre-existing in that file (unrelated to the
  Session 2 work itself, just discovered while touching it):
  `loaded_at_field` and `freshness` both had to move from top-level table
  properties into a nested `config:` block — recent dbt-core behavior
  change, worth knowing since older exam prep material shows the old
  flat syntax
- `dbt build --select staging` → 10 views created (11 models minus the 1
  ephemeral, which correctly never becomes its own database object),
  0 errors
- `dbt source freshness` re-verified after the config-nesting edit —
  still correctly reports `ERROR STALE` on `invoices` (expected, not a
  regression — see Session 1 notes below on why)
- Not yet committed/pushed — working tree has these changes uncommitted

## Prior status (Session 1 — complete)
- GCP project: `chinook-music-store-analytics` (BigQuery Sandbox, no
  billing account, OAuth auth via `gcloud auth application-default login`
  + `set-quota-project`)
- Raw Chinook CSVs loaded into `chinook_raw` dataset via
  `bigquery_load/load_to_bigquery.sh` (bq load --autodetect)
- dbt project scaffolded in `chinook_dbt/`: `dbt_project.yml`,
  `~/.dbt/profiles.yml` (BigQuery adapter, oauth method),
  `packages.yml` (dbt_utils), `models/staging/_chinook_sources.yml`
  (all 11 sources + freshness config on `invoices`)
- Conda env `chinook_dbt` (Python 3.11) with `dbt-bigquery` installed
- `dbt debug`, `dbt seed` (loaded `seed_country_region.csv`), and
  `dbt source freshness` all run successfully
- Known/intentional data quirks not yet cleaned (deliberately left for
  Session 2 staging exercises):
  - `employees.ReportsTo` uses literal string `"---"` as null placeholder
    for the top-level manager
  - `invoices.InvoiceDate` is cast to TIMESTAMP inline in
    `loaded_at_field` for freshness checks (autodetect loaded it as DATE)
  - Source freshness legitimately reports ERROR STALE, not WARN — this
    is correct given Chinook's historical data vs. our freshness
    thresholds, not a bug. Worth being able to explain why in the exam.
- Git initialized, `.gitignore` in place (excludes target/, dbt_packages/,
  logs/, etc.), ready to push to `chinook-analytics-engineering` on GitHub

## Session plan (see full topic-coverage map in
## dbt_cert_prep_project_overview.md at the repo root)

- **Session 2 — complete** — see "Current status" above.
- **Session 3 (next)** — Intermediate + incremental marts (`fct_invoices`
  incremental/merge, `dim_customers`, `dim_employees` self-referencing
  hierarchy, `dim_tracks`, microbatch variant, BigQuery native
  materialized view, `--empty`/`--sample` flags, Python model via
  Snowflake/Snowpark instead of BigQuery Dataproc)
- **Session 4** — Testing (generic, singular, custom generic, unit tests,
  `where`/`warn_if`/`error_if`, `store_failures`)
- **Session 5** — Snapshots (YAML-based, SCD Type 2 on `customers`) +
  custom macro
- **Session 6** — Governance (contracts, versions, YAML constraints,
  grants)
- **Session 7** — Debugging & resilience (`dbt clone`, `dbt retry`,
  broken ref/yml exercises, global flags)
- **Session 8** — Exposures, `dbt state` (`state:modified+`), docs

## Reference files in this repo
- `dbt_cert_prep_project_overview.md` — full session plan + exam topic
  coverage map
- `README.md` — original Session 1 setup instructions
