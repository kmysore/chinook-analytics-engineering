#!/bin/bash
# Loads Chinook CSV files into a BigQuery dataset called chinook_raw.
# Requires: gcloud CLI installed + authenticated (gcloud auth login),
# and the bq CLI (ships with gcloud).
#
# Usage:
#   1. Edit PROJECT_ID below to your GCP project.
#   2. cd into this folder.
#   3. Run: bash load_to_bigquery.sh

set -e

PROJECT_ID="chinook-music-store-analytics"   # <-- EDIT THIS
DATASET="chinook_raw"
LOCATION="US"                       # BigQuery Sandbox default region; change if needed

echo "Creating dataset ${PROJECT_ID}:${DATASET} (if it doesn't already exist)..."
bq --location="${LOCATION}" mk --dataset --description "Chinook raw source data for dbt cert prep" \
  "${PROJECT_ID}:${DATASET}" || echo "Dataset already exists, continuing..."

echo "Loading tables..."

declare -a TABLES=("albums" "artists" "customers" "employees" "genres" "invoice_items" "invoices" "media_types" "playlist_tracks" "playlists" "tracks")

for TABLE in "${TABLES[@]}"; do
  echo "Loading ${TABLE}..."
  bq load \
    --autodetect \
    --skip_leading_rows=1 \
    --source_format=CSV \
    --replace \
    "${PROJECT_ID}:${DATASET}.${TABLE}" \
    "chinook_raw_csv/${TABLE}.csv"
done

echo "Done. Tables loaded into ${PROJECT_ID}.${DATASET}:"
bq ls "${PROJECT_ID}:${DATASET}"
