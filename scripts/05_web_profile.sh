#!/usr/bin/env bash
# Tache 2.1 : profil du web -> results/web_profile.txt, results/daily_os_counts.csv
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C
in=data/clean/web_clean.csv
awk -F, 'NR > 1 {
    n++; os[$4]++; if ($2 == "") nocity++
    if ($4 != "") known++
  }
  END {
    for (o in os) d++
    printf "records: %d\n", n
    printf "distinct_os_name (empty counts as a value): %d\n", d
    printf "no_city_name: %d (%.2f%% of %d records)\n", nocity, 100*nocity/n, n
    printf "iOS: %.2f%% of %d records | %.2f%% of %d records with known OS\n", 100*os["iOS"]/n, n, 100*os["iOS"]/known, known
    printf "Android: %.2f%% of %d records | %.2f%% of %d records with known OS\n", 100*os["Android"]/n, n, 100*os["Android"]/known, known
    m = os["iOS"] + os["Android"]
    printf "mobile (iOS+Android): %.2f%% of %d records | %.2f%% of %d records with known OS\n", 100*m/n, n, 100*m/known, known
  }' "$in" > results/web_profile.txt
echo "top5_web_client (count, client):" >> results/web_profile.txt
tail -n +2 "$in" | cut -d, -f5 | sort | uniq -c | sort -k1,1nr -k2 | awk 'NR <= 5' >> results/web_profile.txt
cat results/web_profile.txt
{ echo "date,os_name,count"
  tail -n +2 "$in" | cut -d, -f1,4 | sort | uniq -c | awk '{c=$1; sub(/^ *[0-9]+ /, ""); print $0 "," c}' \
    | sort -t, -k3,3nr -k1,1 -k2,2
} > results/daily_os_counts.csv
head -n 4 results/daily_os_counts.csv
