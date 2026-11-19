#!/usr/bin/env bash
# Tache 2.5a : profil du corpus -> results/hass_profile.txt
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C
in=data/clean/hass_base.tsv
out=results/hass_profile.txt
awk -F'\t' 'NR > 1 { n++; c[$1]++
    s = tolower($1); w += gsub(/[a-z]+/, "&", s) }       # gsub renvoie le nombre de mots
  END { for (k in c) { d++; if (c[k] > 1) { rep++; extra += c[k] - 1 } }
    printf "sentence_pairs: %d\n", n
    printf "distinct_english_sentences: %d\n", d
    printf "sentences_appearing_more_than_once: %d\n", rep
    printf "extra_rows: %d\n", extra
    printf "avg_words_per_english_sentence: %.2f (%d words / %d sentences)\n", w/n, w, n }' "$in" > "$out"
echo "top10_english_words (count, word; stoplist removed):" >> "$out"
tail -n +2 "$in" | cut -f1 | tr 'A-Z' 'a-z' | grep -oE '[a-z]+' \
  | grep -vxE 'a|an|the|to|of|is|i|you|he|she|it|and|in|my' \
  | sort | uniq -c | sort -k1,1nr -k2 | awk 'NR <= 10' >> "$out"
tail -n +2 "$in" | cut -f3 | tr 'A-Z' 'a-z' | grep -oE '[a-z0-9]+' > data/clean/hass_en_tokens.txt
echo "hassaniya_en_tokens_with_digit: $(grep -c '[0-9]' data/clean/hass_en_tokens.txt) of $(wc -l < data/clean/hass_en_tokens.txt) tokens" >> "$out"
echo "top10_hassaniya_en_tokens (count, token; allowed chars a-z 0-9):" >> "$out"
sort data/clean/hass_en_tokens.txt | uniq -c | sort -k1,1nr -k2 | awk 'NR <= 10' >> "$out"
cat "$out"
