#!/usr/bin/env bash
# Usage: S=<your student number> bash scripts/run_all.sh
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C                      # the same sort order on every machine
: "${S:?export S=<your student number> first}"
mkdir -p logs data/clean results/tables
LOG=logs/run.log
log()   { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" | tee -a "$LOG" >&2; }
stage() { log "START $1"; bash "scripts/$1"; log "DONE $1"; }

stage 00_fetch.sh
stage 01_inventory.sh
stage 02_web_clean.sh
stage 03_matches_clean.sh
stage 04_corpus_clean.sh
stage 05_web_profile.sh
stage 06_web_enrich.sh
stage 07_web_daily.sh
stage 08_league.sh
stage 09_seasons.sh
stage 10_corpus_profile.sh
stage 11_backlog.sh
log "ALL DONE"
