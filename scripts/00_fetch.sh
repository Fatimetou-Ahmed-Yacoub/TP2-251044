#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
RIM=https://raw.githubusercontent.com/binorassocies/rimdata/e8666952ed3c52bbdff47411f7110b7fdc0dc297/data
DAH=https://raw.githubusercontent.com/Hassan-IA/DAH/fc3e9a318fce778244056d2cb393448991e4f5d0
mkdir -p data/raw
get() { [ -s "data/raw/$1" ] || curl -fsS -L -o "data/raw/$1" "$2"; }
get web_2025-10.csv   "$RIM/web_traffic/sample_web_traffic_logs_2025-10.csv"
get matches.csv       "$RIM/rim_championnat_results_2007-2025.csv"
get dah_d1.csv        "$DAH/data/base/d1.csv"
get dah_d2.csv        "$DAH/data/contributions/d2.csv"
get dah_d3.csv        "$DAH/data/contributions/d3.csv"
get dah_d4.csv        "$DAH/data/contributions/d4.csv"
get dah_d5.csv        "$DAH/data/contributions/d5.csv"
get dah_completed.csv "$DAH/hassania%20-%20hassaniya_dataset.csv"
(cd data/raw && sha256sum -c ../SHA256SUMS)
