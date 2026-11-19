#!/usr/bin/env bash
# Tache 2.4 (suite) : results/season_summary.csv et results/result_distribution.csv
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C
in=data/clean/matches_clean.csv
{ echo "season,teams,matches,expected_matches,complete"
  awk -F, 'NR > 1 { m[$1]++; t[$1 SUBSEP $4] = 1; t[$1 SUBSEP $5] = 1 }
    END { for (k in t) { split(k, x, SUBSEP); n[x[1]]++ }
          for (s in m) { e = n[s] * (n[s] - 1)
                         printf "%s,%d,%d,%d,%s\n", s, n[s], m[s], e, (m[s] == e ? "yes" : "no") } }' "$in" | sort
} > results/season_summary.csv
{ echo "result,matches"
  tail -n +2 "$in" | cut -d, -f8 | sort | uniq -c | sort -k1,1nr -k2 | awk '{print $2 "," $1}'
} > results/result_distribution.csv
cat results/season_summary.csv results/result_distribution.csv
