# ReconFusion Engine 🚀

ReconFusion is a lightweight Bash-based reconnaissance tool designed to automate subdomain enumeration and attack surface analysis. It integrates multiple industry-standard tools and provides a clean, visual CLI experience.

## 📺 Demo
<!-- Replace the link below with your asciinema link once you record it! -->

[![asciicast](https://asciinema.org/a/6zduEy01RCRi9p4E.svg)](https://asciinema.org/a/6zduEy01RCRi9p4E)

## 🌟 Key Features
*   **Multi-Source Discovery**: Combines results from Subfinder, Assetfinder, and Sublist3r.
*   **Intelligent Filtering**: Automatically identifies high-value targets (Admin panels, APIs, Dev environments).
*   **Live Host Probing**: Built-in HTTP status code checker (200, 301, 302).
*   **Visual UX**: Real-time progress spinners and formatted reporting using `column`.

## 🛠️ Prerequisites
Before running the script, ensure you have the following installed:
*   [Subfinder](https://github.com/projectdiscovery/subfinder)
*   [Assetfinder](https://github.com/tomnomnom/assetfinder)
*   [Sublist3r](https://github.com/aboul3la/Sublist3r)
*   `curl`, `awk`, `column`

## 🚀 Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/dipuhasan404/ReconFusion.git
   cd ReconFusion
Give execution permissions:

Bash
   chmod +x reconfusion.sh
Run the engine:

Bash
./reconfusion.sh example.com


## 📂 Output Structure
*   `data/`: Raw subdomain lists and alive host logs.
*   `final/`: High-value targets and frequency analysis.
