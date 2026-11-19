#!/usr/bin/env bash
# Tache 1.1 : inventaire des fichiers bruts -> results/inventory.tsv
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results
out=results/inventory.tsv
printf 'file\trecords\tfields_header\tlines_other_fields\tcrlf_lines\tfinal_newline\n' > "$out"
for f in data/raw/*.csv; do
  # dernier octet du fichier : si c'est \n, wc -l compte 1, sinon 0
  if [ "$(tail -c 1 "$f" | wc -l)" -eq 1 ]; then nl=yes; else nl=no; fi
  awk -v name="$(basename "$f")" -v nl="$nl" '
    NR == 1 { h = split($0, a, ",") }          # champs de l en-tete
    { if (split($0, a, ",") != h) other++      # decoupage simple sur les virgules
      if ($0 ~ /\r/) crlf++ }                  # ligne qui contient un \r
    END { printf "%s\t%d\t%d\t%d\t%d\t%s\n", name, NR-1, h, other, crlf, nl }
  ' "$f" >> "$out"
done
cat "$out"
