export S=251044
export LOG=tp2_${S}_log.txt
run() { { echo "### $(date -u +%FT%TZ) $*"; "$@" 2>&1; echo; } | tee -a "$LOG"; }
