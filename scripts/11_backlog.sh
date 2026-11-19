#!/usr/bin/env bash
# Tache 2.5b : file d attente des traductions -> data/clean/hass_backlog.tsv, results/backlog_status.csv
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C
out=data/clean/hass_backlog.tsv
gawk -v FPAT='([^,]*)|("([^"]|"")*")' -v OFS='\t' '
  function clean(s) { gsub(/^[ \t]+|[ \t]+$/, "", s)
    if (s ~ /^".*"$/) { s = substr(s, 2, length(s) - 2); gsub(/""/, "\"", s); gsub(/^[ \t]+|[ \t]+$/, "", s) }
    return s }
  FILENAME ~ /hass_base/      { if (FNR > 1) { split($0, a, "\t"); base[a[1]] = 1 }; next }
  FILENAME ~ /hass_completed/ { if (FNR > 1) { split($0, a, "\t"); ar[a[1]] = a[2]; en[a[1]] = a[3] }; next }
  FNR == 1 { if (!hdr++) print "english", "hassaniya_ar", "hassaniya_en", "status"; next }
  { sub(/\r$/, ""); $0 = $0
    e = clean($1); h1 = clean($2); h2 = clean($3)
    if (e in base) st = "in_base"
    else if (e in ar) { st = "filled"; h1 = ar[e]; h2 = en[e] }
    else if (h1 != "" && h2 != "") st = "prefilled"
    else st = "todo"
    print e, h1, h2, st }
' data/clean/hass_base.tsv data/clean/hass_completed.tsv data/raw/dah_d2.csv data/raw/dah_d3.csv data/raw/dah_d4.csv data/raw/dah_d5.csv > "$out"
{ echo "status,rows"; tail -n +2 "$out" | cut -f4 | sort | uniq -c | awk '{print $2 "," $1}' | sort; } > results/backlog_status.csv
echo "$out : $(( $(wc -l < "$out") - 1 )) lignes"; cat results/backlog_status.csv
