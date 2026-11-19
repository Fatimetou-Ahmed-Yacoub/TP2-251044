#!/usr/bin/env bash
# Tache 1.4 : corpus hassaniya CSV -> TSV (data/clean/hass_base.tsv, hass_completed.tsv)
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p data/clean

# csv2tsv FICHIER : lit un CSV avec guillemets, ecrit 3 champs separes par des tabulations
csv2tsv() {
  tr -d '\r' < "$1" | gawk -v FPAT='([^,]*)|("([^"]|"")*")' -v OFS='\t' '
    function clean(s) {
      gsub(/^[ \t]+|[ \t]+$/, "", s)                 # espaces/tabs aux deux bouts
      if (s ~ /^".*"$/) {                            # champ entre guillemets
        s = substr(s, 2, length(s) - 2)              # on enleve les guillemets
        gsub(/""/, "\"", s)                          # "" a l interieur -> "
        gsub(/^[ \t]+|[ \t]+$/, "", s)
      }
      return s
    }
    { print clean($1), clean($2), clean($3) }        # 4e colonne vide ignoree
  '
}
csv2tsv data/raw/dah_d1.csv        > data/clean/hass_base.tsv
csv2tsv data/raw/dah_completed.csv > data/clean/hass_completed.tsv

# Verification demandee : meme nombre de champs sur chaque ligne (d1 et d3)
for f in data/raw/dah_d1.csv data/raw/dah_d3.csv; do
  echo "$f : nombre de champs par ligne (methode FPAT) -> nombre de lignes"
  tr -d '\r' < "$f" | gawk -v FPAT='([^,]*)|("([^"]|"")*")' '{ print NF }' | sort | uniq -c
done
for f in data/clean/hass_base.tsv data/clean/hass_completed.tsv; do
  echo "$f : $(awk -F'\t' '{print NF}' "$f" | sort -u | tr '\n' ' ')champ(s), $(( $(wc -l < "$f") - 1 )) paires"
done
