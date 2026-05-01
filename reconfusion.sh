#!/bin/bash

# Safe exit on error, but allow pipe failures for better grep handling
set -eo pipefail

# ----------------------------
# Configuration & Colors
# ----------------------------
target=${1:-}
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ----------------------------
# Setup & Dependency Check
# ----------------------------
mkdir -p data final

if [ -z "$target" ]; then
    echo -e "${RED}Usage: ./reconfusion.sh <domain>${NC}"
    exit 1
fi

for cmd in subfinder assetfinder sublist3r curl awk column; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}[!] Error: '$cmd' is not installed. Please install it.${NC}"
        exit 1
    fi
done

# ----------------------------
# UI: Spinner Function
# ----------------------------
spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 $pid 2>/dev/null; do
        for i in $(seq 0 9); do
            printf "\r${BLUE}%s${NC} %s" "${spin:$i:1}" "$msg"
            sleep 0.1
        done
    done
    printf "\r${GREEN}✔${NC} %s\n" "$msg"
}

# ----------------------------
# Header
# ----------------------------
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "      ${YELLOW}RECONFUSION ENGINE (ACCURACY MODE)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "[*] Target: ${GREEN}$target${NC}\n"

# ----------------------------
# Subdomain Enumeration
# ----------------------------
(subfinder -d "$target" > data/sub1.txt 2>/dev/null) &
spinner $! "Subfinder scanning"

(assetfinder --subs-only "$target" > data/sub2.txt 2>/dev/null) &
spinner $! "Assetfinder scanning"

(sublist3r -d "$target" -o data/sub3.txt >/dev/null 2>&1) &
spinner $! "Sublist3r scanning"

# ----------------------------
# Merge + Clean (Accuracy Focus)
# ----------------------------
echo -e "${BLUE}[*] Cleaning and preparing subdomains...${NC}"
# tr -d '\r' removes Windows line endings
# sed 's/\.$//' removes trailing dots (common in DNS tools)
cat data/sub*.txt 2>/dev/null | tr -d '\r' | sed 's/\.$//' | sort -u | grep "$target$" > data/all_subs.txt
echo -e "${GREEN}✔${NC} Total unique targets to verify: $(wc -l < data/all_subs.txt)"

# ----------------------------
# Alive Check (The "No-Fail" Version)
# ----------------------------
echo -e "\n${BLUE}[*] Probing live hosts (High-Accuracy Mode)...${NC}"
echo -e "${YELLOW}Note: Checking one-by-one to prevent rate-limiting...${NC}\n"
> data/alive.txt

# Using a standard loop ensures every request is handled carefully
while read -r sub; do
    [ -z "$sub" ] && continue

    agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    
    # Try HTTPS then HTTP
    for proto in https http; do
        # -I: Head request for speed
        # -k: Insecure (ignore SSL errors)
        # -L: Follow redirects
        # --retry 1: If it fails, try one more time
        code=$(curl -I -s -k -L -w "%{http_code}" \
            --retry 1 \
            --connect-timeout 5 \
            --max-time 10 \
            -H "User-Agent: $agent" \
            "$proto://$sub" -o /dev/null || echo "000")

        # Any code from 100-599 means the server is reachable
        if [[ "$code" -ge 100 && "$code" -le 599 ]]; then
            echo -e "${GREEN}$proto://$sub${NC} [${YELLOW}$code${NC}]" | tee -a data/alive.txt
            break
        fi
    done
done < data/all_subs.txt

# Strip ANSI colors from the text file for clean reporting
sed -i 's/\x1b\[[0-9;]*m//g' data/alive.txt

# ----------------------------
# High Value Filtering
# ----------------------------
echo -e "\n${BLUE}[*] Analyzing attack surface...${NC}"
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
cat data/sub*.txt 2>/dev/null | sort | grep "$target$" | uniq -c | sort -nr > final/frequency.txt

# ----------------------------
# Final Report UI
# ----------------------------
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "        ${YELLOW}FINAL REPORT${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${GREEN}✔ Alive Targets:${NC}"
if [ -s data/alive.txt ]; then
    column -t data/alive.txt
else
    echo "No alive targets found"
fi

echo -e "\n${RED}✔ High Value Targets:${NC}"
if [ -s final/high_value.txt ]; then
    column -t final/high_value.txt
else
    echo "No high-value targets found"
fi

echo -e "\n${BLUE}✔ Top Discovered Subdomains:${NC}"
head -10 final/frequency.txt

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${GREEN}SCAN COMPLETE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
