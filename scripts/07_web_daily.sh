#!/usr/bin/env bash
# Tache 2.3 : fichier quotidien des 4 operateurs -> results/web_daily_isp_<S>.csv
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C
: "${S:?export S=<ton numero> d abord}"
out=results/web_daily_isp_${S}.csv
gawk -F, '
  NR > 1 { k = $3 SUBSEP $1; rec[k]++
           if ($4 == "iOS" || $4 == "Android") mob[k]++
           if ($6 == "bot") bot[k]++ }
  END {
    print "isp,date,records,mobile,bot,busy_flag"
    split("CHINGUITEL MATTEL MAURITEL RIMATEL", isps, " ")
    for (i = 1; i <= 4; i++) {
      isp = isps[i]
      for (d = 1; d <= 31; d++) c[d] = rec[isp, sprintf("2025-10-%02d", d)] + 0
      n = asort(c, s)                       # s = les 31 comptes tries (croissant)
      thr = s[int((9 * n + 9) / 10)]        # rang ceil(0.9 n) = 28 pour n = 31
      printf "%s: seuil P90 = %d\n", isp, thr > "/dev/stderr"
      for (d = 1; d <= 31; d++) {
        k = isp SUBSEP sprintf("2025-10-%02d", d)
        printf "%s,2025-10-%02d,%d,%d,%d,%d\n", isp, d, c[d], mob[k], bot[k], (c[d] >= thr)
      }
    }
  }' data/clean/web_enriched.csv > "$out"
echo "$out : $(( $(wc -l < "$out") - 1 )) lignes"
echo "jours busy par operateur :"; awk -F, 'NR > 1 && $6 == 1 {print $1, $2, $3}' "$out"
