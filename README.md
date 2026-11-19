# TP2 SID31 DataOps: open data pack (Bash, awk, Git)

- Student number (S): 251044
- Focus ISP: CHINGUITEL (last digit 4)
- Focus season: Ligue 1 2018/2019 (second-to-last digit 4)

## Sources

| Data | Repository | Pinned commit | Licence as published | Read on |
|---|---|---|---|---|
| web_2025-10.csv, matches.csv | https://github.com/binorassocies/rimdata | e8666952ed3c52bbdff47411f7110b7fdc0dc297 | GNU GPL v3 (LICENSE file of the repository) | 2026-11-19 |
| dah_d1.csv to dah_d5.csv, dah_completed.csv | https://github.com/Hassan-IA/DAH | fc3e9a318fce778244056d2cb393448991e4f5d0 | CC-BY-4.0 (stated in the repository README) | 2026-11-19 |

The eight files are downloaded by `scripts/00_fetch.sh` and checked against `data/SHA256SUMS`.
The column `hash_src_ip` is dropped in the first cleaning stage and appears in no committed file.

## How to rebuild

~~~bash
export S=251044
rm -rf data/clean results logs && S=$S bash scripts/run_all.sh
S=$S bash tp2.2026.check.sh m1   # also m2, m3, m4
~~~

`run_all.sh` downloads the raw files if they are missing, stops if a checksum fails,
and writes a START and a DONE line with a UTC time for each stage in `logs/run.log`.

## Findings

1. Format problems and their repair
   - **Claim**: matches.csv has a carriage return on all 2745 lines, dah_d1.csv has 323 of 3003 lines whose plain comma split differs from the header, and 5 of 8 files have no final newline.
   - **Evidence**: `results/inventory.tsv` (`bash scripts/01_inventory.sh`); repair in `scripts/03_matches_clean.sh` (`tr -d '\r'`) and `scripts/04_corpus_clean.sh` (gawk FPAT keeps quoted commas in one field: 3 fields on all lines).
   - **Limit**: the inventory counts lines and bytes; it does not show empty values, extra spaces or wrong translations.

2. Unmapped clients
   - **Claim**: 2430 of 45260 web records (5.37%) have a client that is not in the lookup table; 2361 of them are "Other".
   - **Evidence**: `results/isp_client_class.csv` (`awk -F, '$2=="unmapped"{s+=$3} END{print s}' results/isp_client_class.csv`), built by `scripts/06_web_enrich.sh`.
   - **Limit**: "Other" hides the real client, so bots or browsers inside it are not counted in any class.

3. Bot share of CHINGUITEL
   - **Claim**: 287 of 3956 CHINGUITEL records (7.25%) have the class bot (all FacebookBot).
   - **Evidence**: `results/isp_client_class.csv` (`grep '^CHINGUITEL,' results/isp_client_class.csv`).
   - **Limit**: the class bot is a working class based only on the client name; it is not a measurement of automation.

4. Busy days of CHINGUITEL
   - **Claim**: with a P90 threshold of 196 records/day (nearest rank 28 of 31 days), CHINGUITEL has 4 busy days of 31: 2025-10-01 (472), 2025-10-02 (283), 2025-10-03 (204) and 2025-10-08 (196).
   - **Evidence**: `results/web_daily_isp_251044.csv` (`awk -F, '$1=="CHINGUITEL" && $6==1' results/web_daily_isp_251044.csv`), built by `scripts/07_web_daily.sh`.
   - **Limit**: the file is a sample; it does not show why these days are busy, and the high first days may come from how the sample was drawn.

5. Top three teams of Ligue 1 2018/2019 and incomplete seasons
   - **Claim**: Nouadhibou (59 pts), ASAC Concorde (47) and Kedia (44) lead Ligue 1 2018/2019 (14 teams, 182 of 182 matches); 2 of 18 seasons fail the completeness test: Championnat D1 2007/2008 (130 of 132) and Ligue 1 2020/2021 (32 of 56).
   - **Evidence**: `results/tables/Ligue_1_2018_2019.csv` (`head -n 4`) and `results/season_summary.csv` (`grep ',no$'`), built by `scripts/08_league.sh` and `scripts/09_seasons.sh`.
   - **Limit**: points come only from results; penalties, forfeits or deductions are not in the file, and the test does not say whether missing matches were never played or are missing from the source.

6. Translation backlog by status
   - **Claim**: of 400 contribution rows, 295 are todo (73.75%), 99 filled, 3 prefilled and 3 in_base.
   - **Evidence**: `results/backlog_status.csv` (`cat results/backlog_status.csv`), built by `scripts/11_backlog.sh`.
   - **Limit**: the status shows whether a translation exists, not whether it is correct.

7. Mobile share of the web sample
   - **Claim**: iOS + Android are 85.51% of 45260 records, or 86.67% of the 44655 records with a known OS.
   - **Evidence**: `results/web_profile.txt` (`grep mobile results/web_profile.txt`), built by `scripts/05_web_profile.sh`.
   - **Limit**: records are log lines, not people or devices.

### Tokens of hassaniya-en

A hassaniya-en token is a maximal run of `a-z` and `0-9` after lowercase. Digits are allowed
because the Latin spelling of Hassaniya (Arabizi) uses them for Arabic sounds (3, 7, 2, 4, 5),
for example `3le` or `4e`: 5062 of 12329 tokens contain a digit (`results/hass_profile.txt`).
English words are runs of `a-z` only, so "don't" gives "don" and "t".

## Declared help

- Claude (Anthropic AI assistant): explained the tasks and commands in French, proposed and tested the
  scripts 01 to 11, run_all.sh, the log notes and this README. I ran every command myself in the
  sid31-env container, checked the outputs with tp2.2026.check.sh, and I can explain every command.
