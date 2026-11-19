#!/usr/bin/env bash
# Tache 1.3 : nettoyage des resultats de matchs -> data/clean/matches_clean.csv
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p data/clean
src=data/raw/matches.csv
out=data/clean/matches_clean.csv
tr -d '\r' < "$src" | awk -F, -v OFS=, '
  NR == 1 { print "season,date,date_status,home_team,away_team,home_goals,away_goals,result"; next }
  {
    split($2, d, ".")                    # "02.08.2008" -> d[1]=02 d[2]=08 d[3]=2008
    if (d[3] != "") { year = d[3]; status = "full" }
    else {                               # "30.05." : pas d annee -> regle de travail
      n = split($1, w, " ")              # dernier mot du label : "2024/2025"
      if (split(w[n], y, "/") != 2) { print "ERREUR ligne " NR ": pas d annee et saison sur un an" > "/dev/stderr"; exit 1 }
      year = (d[2] + 0 >= 8) ? y[1] : y[2]
      status = "inferred"
    }
    if ($5 + 0 > $6 + 0) res = "home_win"; else if ($5 + 0 < $6 + 0) res = "away_win"; else res = "draw"
    print $1, year "-" d[2] "-" d[1], status, $3, $4, $5, $6, res
  }' > "$out"
echo "matches_clean.csv: $(( $(wc -l < "$out") - 1 )) matchs"
echo "date_status :"; tail -n +2 "$out" | cut -d, -f3 | sort | uniq -c

# Test de la regle de travail sur les dates completes des saisons sur deux ans
echo "Test de la regle (dates completes, saisons AAAA/AAAA) :"
tr -d '\r' < "$src" | awk -F, '
  NR > 1 && $2 ~ /\.[0-9][0-9][0-9][0-9]$/ && $1 ~ /[0-9][0-9][0-9][0-9]\/[0-9][0-9][0-9][0-9]$/ {
    split($2, d, "."); n = split($1, w, " "); split(w[n], y, "/")
    guess = (d[2] + 0 >= 8) ? y[1] : y[2]
    tested++
    if (guess != d[3]) { wrong++; where[$1 " mois " d[2] " (source " d[3] ", regle " guess ")"]++ }
  }
  END {
    printf "lignes testees=%d  annee differente=%d\n", tested, wrong
    for (k in where) printf "  %d x %s\n", where[k], k
  }' | sort
