#!/usr/bin/env bash
# Tache 2.4 : classements par saison, resume des saisons, distribution des resultats
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C
in=data/clean/matches_clean.csv
mkdir -p results/tables
rm -f results/tables/*.csv
# 1) une ligne par (saison, equipe) : fichier<TAB>team,played,gf,ga,diff,points
awk -F, 'NR > 1 {
    h = $1 SUBSEP $4; a = $1 SUBSEP $5
    p[h]++; p[a]++; gf[h] += $6; ga[h] += $7; gf[a] += $7; ga[a] += $6
    if ($8 == "home_win") pts[h] += 3; else if ($8 == "away_win") pts[a] += 3; else { pts[h]++; pts[a]++ }
  }
  END { for (k in p) { split(k, x, SUBSEP); f = x[1]; gsub(/[ \/]/, "_", f)
        printf "%s\t%s,%d,%d,%d,%d,%d\n", f, x[2], p[k], gf[k], ga[k], gf[k]-ga[k], pts[k] } }
' "$in" > data/clean/league_rows.tsv
# 2) un fichier par saison, trie : points, diff, goals_for (du plus grand), puis team (A-Z)
for f in $(cut -f1 data/clean/league_rows.tsv | sort -u); do
  { echo "team,played,goals_for,goals_against,diff,points"
    awk -F'\t' -v f="$f" '$1 == f {print $2}' data/clean/league_rows.tsv \
      | sort -t, -k6,6nr -k5,5nr -k3,3nr -k1,1
  } > "results/tables/$f.csv"
done
ls results/tables
