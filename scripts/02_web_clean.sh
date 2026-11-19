#!/usr/bin/env bash
# Tache 1.2 : nettoyage de l echantillon web -> data/clean/web_clean.csv
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p data/clean
src=data/raw/web_2025-10.csv
out=data/clean/web_clean.csv
# Garde-fou : le decoupage par cut n est juste que si chaque ligne a 6 champs
# (aucune virgule a l interieur des guillemets). Sinon on s arrete.
awk -F, 'NF != 6 { bad++ } END { exit (bad > 0) }' "$src" \
  || { echo "ERREUR: une ligne n a pas 6 champs dans $src" >&2; exit 1; }
# On coupe la colonne 6 (hash_src_ip) AVANT tout, puis on enleve les guillemets.
cut -d, -f1-5 "$src" | tr -d '"' > "$out"
echo "web_clean.csv: $(wc -l < "$out") lignes (en-tete compris)"
head -n 3 "$out"
