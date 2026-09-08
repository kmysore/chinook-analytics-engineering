# Chinook dbt Certification Prep — Session 1 Setup

## What's in this package

```
bigquery_load/
  chinook_raw_csv/        11 Chinook CSVs, cleaned + renamed to snake_case
  load_to_bigquery.sh     bq CLI script to load CSVs into BigQuery Sandbox

chinook_dbt/
  dbt_project.yml
  profiles.yml.example    copy to ~/.dbt/profiles.yml and edit
  packages.yml            dbt_utils
  models/staging/_chinook_sources.yml   sources.yml with freshness config
  seeds/seed_country_region.csv         seed exercise (country -> region/currency)
  models/intermediate/    (empty — Session 3)
  models/marts/           (empty — Session 3)
  macros/                 (empty — Session 5)
  snapshots/              (empty — Session 5)
  tests/                  (empty — Session 4)
```

## Setup steps

### 1. Google Cloud / BigQuery Sandbox

If you don't already have a GCP project:
1. Go to console.cloud.google.com, create a new project (no billing account needed for Sandbox).
2. Note the **Project ID** (not the project name — the ID, e.g. `chinook-cert-prep-123456`).
3. Install the `gcloud` CLI if you don't have it, then run:
   ```
   gcloud auth login
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```

### 2. Load Chinook into BigQuery

```
cd bigquery_load
# Edit load_to_bigquery.sh — set PROJECT_ID to your actual project ID
bash load_to_bigquery.sh
```

This creates a `chinook_raw` dataset with 11 tables: `customers`, `invoices`, `invoice_items`, `tracks`, `albums`, `artists`, `genres`, `employees`, `playlists`, `media_types`, `playlist_tracks`.

Verify in the BigQuery console or with:
```
bq ls YOUR_PROJECT_ID:chinook_raw
```

### 3. Configure dbt

```
pip install dbt-bigquery --break-system-packages   # or in a virtualenv
```

Copy the profile:
```
mkdir -p ~/.dbt
cp chinook_dbt/profiles.yml.example ~/.dbt/profiles.yml
# Edit project ID inside ~/.dbt/profiles.yml
```

Also edit the `database:` field in `chinook_dbt/models/staging/_chinook_sources.yml` to your project ID.

### 4. Verify + run Session 1 commands

```
cd chinook_dbt
dbt deps          # installs dbt_utils from packages.yml
dbt debug         # confirms connection to BigQuery
dbt seed          # loads seed_country_region.csv into your dev dataset
dbt source freshness   # checks the freshness config on invoices
```

`dbt debug` should report all checks passing. `dbt seed` should create a `seed_country_region` table in your `chinook_dev` dataset. `dbt source freshness` should report a freshness status for the `invoices` source (likely a WARN, since Chinook's invoice dates are historical/static — that's expected and worth understanding *why* for the exam).

## Known data quirks (intentional — used in later sessions)

- `employees.ReportsTo` uses the literal string `"---"` as a null placeholder for the top-level manager. This gets cleaned in `stg_employees` (Session 2).
- `customers` contains non-ASCII characters (e.g. accented names) — good for confirming your BigQuery load handled UTF-8 correctly.
- No `loaded_at` column exists natively; `InvoiceDate` is used as a stand-in for source freshness checks, which is why freshness will show stale/WARN — the data is genuinely static, not lagging.

## Next: Session 2

Staging models for all 11 sources, with one deliberately set to `ephemeral`.
