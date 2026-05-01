# 🚀 Reconfusion Engine 

**Reconfusion** is a high-accuracy subdomain reconnaissance and alive-probing engine designed for penetration testers and bug hunters. Unlike standard scanners that often miss targets due to WAF blocking or strict status-code filtering, Reconfusion is engineered for **100% detection accuracy** in hardened enterprise environments.

---

## 🛠️ Key Features

*   **Multi-Source Enumeration:** Combines results from `Subfinder`, `Assetfinder`, and `Sublist3r` for maximum coverage.
*   **High-Accuracy Probing:** Specifically handles trailing DNS dots, Windows carriage returns, and self-signed SSL certificates.
*   **WAF/IPS Evasion:** Utilizes randomized browser User-Agents and refined request timing to prevent IP rate-limiting.
*   **Smart Filtering:** Detects "High-Value" targets (Admin panels, APIs, Dev environments) and infrastructure (VPNs, Webmail).
*   **Clean Reporting:** Generates sorted frequency analysis and interactive terminal reports.

---

## 📺 Demo

[![asciicast](https://asciinema.org/a/6zduEy01RCRi9p4E.svg)](https://asciinema.org/a/6zduEy01RCRi9p4E)

---

## 🚀 Getting Started

### Prerequisites
Ensure you have the following tools installed on your Kali Linux/Debian system:
```bash
sudo apt update && sudo apt install subfinder assetfinder sublist3r curl awk -y
Installation
Clone the repository:

Bash
git clone [https://github.com/dipuhasan404/reconfusion.git](https://github.com/dipuhasan404/reconfusion.git)
cd reconfusion

2. Give execution permissions:
   ```bash
   chmod +x reconfusion.sh
Usage
Run the engine against any target domain:

Bash
./reconfusion.sh megacorpone.com
📊 Logic & Methodology
Reconfusion was built to solve the "Silent Drop" problem. Many automated tools mark a site as "Down" if they receive a 403 Forbidden or 500 Error.

Our Approach:

Normalization: We strip hidden characters and fix malformed URLs before probing.

Full Handshake: We use a 10-second maximum timeout with a 1-time retry logic to account for network jitter.

Universal Acceptance: Every response code from 100 to 599 is recorded. If the server says "Forbidden," it’s still an active attack surface.

📂 Output Structure
data/all_subs.txt: Unique, cleaned list of all discovered subdomains.

data/alive.txt: Verified live web targets with status codes.

final/high_value.txt: Targeted list of sensitive endpoints.

final/frequency.txt: Subdomain occurrence data for pattern analysis.

🛡️ Disclaimer
This tool is intended for legal, authorized security testing only. The author is not responsible for any misuse or damage caused by this tool.
