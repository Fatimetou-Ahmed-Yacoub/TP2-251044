#!/usr/bin/env bash
# Tache 2.2 : jointure web_client -> classe ; results/isp_client_class.csv
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C
awk -F, -v OFS=, '
  NR == FNR { if (FNR > 1) cls[$1] = $2; next }       # 1er fichier : la table
  FNR == 1  { print $0, "client_class"; next }        # en-tete du 2e fichier
  { print $0, (($5 in cls) ? cls[$5] : "unmapped") }  # aucune ligne perdue
' data/ref/client_class.csv data/clean/web_clean.csv > data/clean/web_enriched.csv
{ echo "isp,client_class,records"
  tail -n +2 data/clean/web_enriched.csv | cut -d, -f3,6 | sort | uniq -c \
    | awk '{c=$1; sub(/^ *[0-9]+ /, ""); print $0 "," c}' | sort -t, -k1,1 -k2,2
} > results/isp_client_class.csv
echo "lignes: web_clean=$(wc -l < data/clean/web_clean.csv) web_enriched=$(wc -l < data/clean/web_enriched.csv)"
echo "classes :"; tail -n +2 data/clean/web_enriched.csv | cut -d, -f6 | sort | uniq -c
echo "clients unmapped (records, client) :"
awk -F, 'NR > 1 && $6 == "unmapped" {print $5}' data/clean/web_enriched.csv | sort | uniq -c | sort -k1,1nr -k2
