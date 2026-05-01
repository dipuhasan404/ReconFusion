#!/bin/bash

set -euo pipefail

target=$1

# ----------------------------
# Setup
# ----------------------------
mkdir -p data final

if [ -z "$target" ]; then
    echo "Usage: ./reconfusion.sh <domain>"
    exit 1
fi

# ----------------------------
# UI: Spinner Function
# ----------------------------
spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    while kill -0 $pid 2>/dev/null; do
        for i in $(seq 0 9); do
            printf "\r%s %s" "${spin:$i:1}" "$msg"
            sleep 0.1
        done
    done
    printf "\r✔ %s\n" "$msg"
}

# ----------------------------
# Header
# ----------------------------
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "      RECONFUSION ENGINE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[*] Target: $target"
echo ""

# ----------------------------
# Subdomain Enumeration (Silent)
# ----------------------------

(subfinder -d "$target" > data/sub1.txt 2>/dev/null &
spinner $! "Subfinder scanning")

(assetfinder --subs-only "$target" > data/sub2.txt 2>/dev/null &
spinner $! "Assetfinder scanning")

(sublist3r -d "$target" -o data/sub3.txt >/dev/null 2>&1 &
spinner $! "Sublist3r scanning")

# ----------------------------
# Merge + Clean
# ----------------------------
echo "[*] Merging results..."
cat data/sub*.txt 2>/dev/null | sort -u | grep -Eo '([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}' > data/all_subs.txt
echo "✔ Subdomains collected: $(wc -l < data/all_subs.txt)"

# ----------------------------
# Alive Check (FIXED VERSION)
# ----------------------------
echo ""
echo "[*] Probing live hosts..."

> data/alive.txt

(
while read sub; do
    for proto in http https; do
        code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$proto://$sub")

        if [[ "$code" == "200" || "$code" == "301" || "$code" == "302" ]]; then
            echo "$proto://$sub [$code]" >> data/alive.txt
            break
        fi
    done
done < data/all_subs.txt
) &

spinner $! "Probing live hosts"
wait
# ----------------------------
# High Value Filtering
# ----------------------------
echo ""
echo "[*] Analyzing attack surface..."

awk '
/admin|login|portal|dashboard|api|graphql|dev|test|staging/ {
    print "[HIGH] " $0
}
/cpanel|webmail|ftp|ssh/ {
    print "[INFRA] " $0
}
' data/alive.txt > final/high_value.txt

# ----------------------------
# Frequency Analysis
# ----------------------------
cat data/sub*.txt 2>/dev/null | sort | uniq -c | sort -nr > final/frequency.txt

# ----------------------------
# Final Report UI
# ----------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        FINAL REPORT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "✔ Alive Targets:"
if [ -s data/alive.txt ]; then
    column -t data/alive.txt
else
    echo "No alive targets found"
fi

echo ""
echo "✔ High Value Targets:"
if [ -s final/high_value.txt ]; then
    column -t final/high_value.txt
else
    echo "No high-value targets found"
fi

echo ""
echo "✔ Top Discovered Subdomains:"
head -10 final/frequency.txt

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   SCAN COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
