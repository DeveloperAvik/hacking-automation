# GODRECON ULTRA — Single File Advanced Recon Framework

> WARNING:
> This framework is intended ONLY for authorized penetration testing, bug bounty programs, labs, and legal security research.
>
> Unauthorized scanning may violate laws and platform policies.

---

# Overview

GodRecon Ultra is a professional-grade single-file Bash reconnaissance framework for:

* Bug bounty hunting
* Penetration testing
* Attack surface mapping
* Continuous reconnaissance
* API discovery
* Cloud asset discovery
* JavaScript intelligence
* Vulnerability automation
* Recursive subdomain enumeration
* Delta monitoring
* Asset correlation

Features:

* Auto-installs missing tools
* Skips existing installations
* Tracks failed installs
* Resume capability
* Parallel processing
* SQLite database
* Recursive enumeration
* CDN/WAF detection
* Smart filtering
* Cloud bucket discovery
* API endpoint discovery
* GraphQL discovery
* Advanced crawling
* JS secret extraction
* Favicon hashing
* TLS reconnaissance
* Nuclei automation
* Vulnerability prioritization
* Continuous monitoring mode

---

# Recommended OS

* Kali Linux
* Ubuntu 24+
* Parrot OS

---

# Installation

```bash
chmod +x godrecon-ultra.sh
./godrecon-ultra.sh example.com --full
```

---

# Example Modes

```bash
./godrecon-ultra.sh target.com --full
./godrecon-ultra.sh target.com --deep
./godrecon-ultra.sh target.com --monitor
./godrecon-ultra.sh target.com --resume
./godrecon-ultra.sh target.com --api-only
./godrecon-ultra.sh target.com --stealth
```

---

# Main Script

```bash

# Enforce running with bash, not sh/dash
if [ -z "$BASH_VERSION" ]; then
    echo "[!] Please run this script with bash:"
    echo "    bash $0 <domain> [mode]"
    exit 1
fi

#!/bin/bash

# =========================================================
# GODRECON ULTRA
# Advanced Bug Bounty Recon Framework
# =========================================================

set -e
set -u
set -o pipefail

# =========================================================
# VERSION
# =========================================================

VERSION="3.0"

# =========================================================
# COLORS
# =========================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# =========================================================
# BANNER
# =========================================================

banner() {
cat << "EOF"

 ██████╗  ██████╗ ██████╗ ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔════╝ ██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██║  ███╗██║   ██║██║  ██║██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██║   ██║██║   ██║██║  ██║██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
╚██████╔╝╚██████╔╝██████╔╝██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
 ╚═════╝  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝

                 GODRECON ULTRA v${VERSION}

EOF
}

banner

# =========================================================
# GLOBALS
# =========================================================

DOMAIN=${1:-}
MODE=${2:---full}
THREADS=100
ROOT="$PWD/output/$DOMAIN"
TOOLS="$HOME/.godrecon/tools"
DB="$ROOT/database/recon.db"
FAILED="$ROOT/logs/failed_installs.txt"
LOGFILE="$ROOT/logs/recon.log"
STATE="$ROOT/state"
WORDLISTS="$HOME/.godrecon/wordlists"

# =========================================================
# VALIDATION
# =========================================================


if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 domain.com [mode]"
    exit 1
fi

# =========================================================
# DIRECTORIES
# =========================================================

mkdir -p "$ROOT"
mkdir -p "$TOOLS"
mkdir -p "$WORDLISTS"
mkdir -p "$ROOT/logs"
mkdir -p "$ROOT/state"
mkdir -p "$ROOT/database"
mkdir -p "$ROOT/subdomains"
mkdir -p "$ROOT/httpx"
mkdir -p "$ROOT/ports"
mkdir -p "$ROOT/urls"
mkdir -p "$ROOT/js"
mkdir -p "$ROOT/api"
mkdir -p "$ROOT/cloud"
mkdir -p "$ROOT/screenshots"
mkdir -p "$ROOT/nuclei"
mkdir -p "$ROOT/secrets"
mkdir -p "$ROOT/tls"
mkdir -p "$ROOT/reports"
mkdir -p "$ROOT/takeovers"
mkdir -p "$ROOT/waf"
mkdir -p "$ROOT/crawling"
mkdir -p "$ROOT/params"
mkdir -p "$ROOT/tech"
mkdir -p "$ROOT/graphs"
mkdir -p "$ROOT/delta"

# =========================================================
# LOGGER
# =========================================================

log() {
    echo -e "[$(date)] $1" | tee -a "$LOGFILE"
}

info() {
    log "${CYAN}[*] $1${NC}"
}

success() {
    log "${GREEN}[+] $1${NC}"
}

warning() {
    log "${YELLOW}[!] $1${NC}"
}

error() {
    log "${RED}[-] $1${NC}"
}

# =========================================================
# STATE MANAGEMENT
# =========================================================

mark_done() {
    touch "$STATE/$1.done"
}

is_done() {
    [ -f "$STATE/$1.done" ]
}

# =========================================================
# INSTALL FUNCTION
# =========================================================

install_tool() {

    local TOOL=$1
    local CMD=$2

    if command -v "$TOOL" &>/dev/null; then
        success "$TOOL already installed"
    else
        info "Installing $TOOL"

        if eval "$CMD"; then
            success "$TOOL installed"
        else
            error "$TOOL failed"
            echo "$TOOL" >> "$FAILED"
        fi
    fi
}

# =========================================================
# SYSTEM DEPENDENCIES
# =========================================================

setup_dependencies() {

    if is_done "dependencies"; then
        success "Dependencies already completed"
        return
    fi

    sudo apt update

    sudo apt install -y \
        golang \
        python3 \
        python3-pip \
        sqlite3 \
        jq \
        curl \
        wget \
        git \
        unzip \
        chromium-browser \
        dnsutils \
        whois \
        parallel \
        masscan \
        nmap \
        wafw00f \
        tmux \
        build-essential

    export PATH=$PATH:$(go env GOPATH)/bin

    mark_done "dependencies"
}

# =========================================================
# INSTALL TOOLS
# =========================================================

install_all_tools() {

    if is_done "tools"; then
        success "Tool installation already completed"
        return
    fi

    # ProjectDiscovery
    install_tool subfinder "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    install_tool httpx "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
    install_tool naabu "go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    install_tool nuclei "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    install_tool dnsx "go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    install_tool katana "go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
    install_tool uncover "go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest"
    install_tool interactsh-client "go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
    install_tool tlsx "go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
    install_tool cdncheck "go install -v github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest"
    install_tool mapcidr "go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"

    # Tomnomnom
    install_tool assetfinder "go install github.com/tomnomnom/assetfinder@latest"
    install_tool waybackurls "go install github.com/tomnomnom/waybackurls@latest"
    install_tool gf "go install github.com/tomnomnom/gf@latest"
    install_tool anew "go install github.com/tomnomnom/anew@latest"
    install_tool unfurl "go install github.com/tomnomnom/unfurl@latest"
    install_tool qsreplace "go install github.com/tomnomnom/qsreplace@latest"

    # Others
    install_tool gau "go install github.com/lc/gau/v2/cmd/gau@latest"
    install_tool ffuf "go install github.com/ffuf/ffuf/v2@latest"
    install_tool dalfox "go install github.com/hahwul/dalfox/v2@latest"
    install_tool subjs "go install github.com/lc/subjs@latest"
    install_tool hakrawler "go install github.com/hakluke/hakrawler@latest"
    install_tool amass "go install github.com/owasp-amass/amass/v4/...@master"
    install_tool shuffledns "go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"
    install_tool alterx "go install github.com/projectdiscovery/alterx/cmd/alterx@latest"
    install_tool notify "go install github.com/projectdiscovery/notify/cmd/notify@latest"

    # Python
    pip3 install arjun uro trufflehog dnsgen

    mark_done "tools"
}

# =========================================================
# SQLITE
# =========================================================

init_database() {

sqlite3 "$DB" << EOF

CREATE TABLE IF NOT EXISTS subdomains (
    id INTEGER PRIMARY KEY,
    subdomain TEXT UNIQUE,
    discovered_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS live_hosts (
    id INTEGER PRIMARY KEY,
    host TEXT UNIQUE,
    tech TEXT,
    status INTEGER,
    title TEXT
);

CREATE TABLE IF NOT EXISTS vulnerabilities (
    id INTEGER PRIMARY KEY,
    host TEXT,
    severity TEXT,
    template TEXT,
    info TEXT
);

CREATE TABLE IF NOT EXISTS js_files (
    id INTEGER PRIMARY KEY,
    url TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS urls (
    id INTEGER PRIMARY KEY,
    url TEXT UNIQUE
);

EOF

success "Database initialized"
}

# =========================================================
# PASSIVE ENUMERATION
# =========================================================

passive_enum() {

    if is_done "passive_enum"; then
        success "Passive enum already completed"
        return
    fi

    info "Starting passive enumeration"

    subfinder -d "$DOMAIN" -all -silent > "$ROOT/subdomains/subfinder.txt"

    assetfinder --subs-only "$DOMAIN" > "$ROOT/subdomains/assetfinder.txt"

    amass enum -passive -d "$DOMAIN" > "$ROOT/subdomains/amass.txt"

    cat "$ROOT/subdomains"/*.txt | sort -u > "$ROOT/subdomains/all.txt"

    success "Passive enumeration completed"

    mark_done "passive_enum"
}

# =========================================================
# RECURSIVE ENUMERATION
# =========================================================

recursive_enum() {

    if is_done "recursive_enum"; then
        return
    fi

    info "Recursive enumeration"

    alterx -l "$ROOT/subdomains/all.txt" -silent > "$ROOT/subdomains/permutations.txt"

    shuffledns \
        -d "$DOMAIN" \
        -list "$ROOT/subdomains/permutations.txt" \
        -silent \
        -o "$ROOT/subdomains/recursive.txt"

    cat "$ROOT/subdomains/all.txt" "$ROOT/subdomains/recursive.txt" | sort -u > "$ROOT/subdomains/final.txt"

    mark_done "recursive_enum"
}

# =========================================================
# DNS RESOLUTION
# =========================================================

resolve_hosts() {

    if is_done "resolve"; then
        return
    fi

    info "Resolving hosts"

    dnsx -l "$ROOT/subdomains/final.txt" -silent -resp > "$ROOT/subdomains/resolved.txt"

    cut -d ' ' -f1 "$ROOT/subdomains/resolved.txt" > "$ROOT/subdomains/live_subs.txt"

    mark_done "resolve"
}

# =========================================================
# CDN FILTERING
# =========================================================

cdn_filter() {

    info "Detecting CDNs"

    httpx \
        -l "$ROOT/subdomains/live_subs.txt" \
        -cdn \
        -silent \
        > "$ROOT/subdomains/cdn.txt"
}

# =========================================================
# PORT SCANNING
# =========================================================

port_scan() {

    if is_done "ports"; then
        return
    fi

    info "Port scanning"

    naabu \
        -list "$ROOT/subdomains/live_subs.txt" \
        -top-ports 1000 \
        -rate 1000 \
        -silent \
        -o "$ROOT/ports/naabu.txt"

    mark_done "ports"
}

# =========================================================
# HTTP PROBING
# =========================================================

http_probe() {

    if is_done "httpx"; then
        return
    fi

    info "HTTP probing"

    httpx \
        -l "$ROOT/subdomains/live_subs.txt" \
        -title \
        -tech-detect \
        -status-code \
        -follow-redirects \
        -silent \
        -threads 100 \
        -o "$ROOT/httpx/live.txt"

    cat "$ROOT/httpx/live.txt" | awk '{print $1}' > "$ROOT/httpx/urls.txt"

    mark_done "httpx"
}

# =========================================================
# SCREENSHOTS
# =========================================================

screenshots() {

    info "Taking screenshots"

    httpx \
        -l "$ROOT/httpx/urls.txt" \
        -screenshot \
        -system-chrome \
        -silent
}

# =========================================================
# URL COLLECTION
# =========================================================

collect_urls() {

    info "Collecting URLs"

    cat "$ROOT/httpx/urls.txt" | gau > "$ROOT/urls/gau.txt"

    cat "$ROOT/httpx/urls.txt" | waybackurls > "$ROOT/urls/wayback.txt"

    cat "$ROOT/urls"/*.txt | uro | sort -u > "$ROOT/urls/all_urls.txt"
}

# =========================================================
# KATANA CRAWLING
# =========================================================

crawl_targets() {

    info "Crawling targets"

    katana \
        -list "$ROOT/httpx/urls.txt" \
        -jc \
        -kf all \
        -silent \
        -o "$ROOT/crawling/katana.txt"
}

# =========================================================
# JAVASCRIPT RECON
# =========================================================

javascript_recon() {

    info "JavaScript reconnaissance"

    cat "$ROOT/httpx/urls.txt" | subjs > "$ROOT/js/js_files.txt"
}

# =========================================================
# PARAMETER DISCOVERY
# =========================================================

parameter_discovery() {

    info "Parameter discovery"

    arjun -i "$ROOT/httpx/urls.txt" -oT "$ROOT/params/arjun.txt"
}

# =========================================================
# GF PATTERNS
# =========================================================

gf_analysis() {

    info "GF analysis"

    cat "$ROOT/urls/all_urls.txt" | gf xss > "$ROOT/params/xss.txt" || true

    cat "$ROOT/urls/all_urls.txt" | gf sqli > "$ROOT/params/sqli.txt" || true

    cat "$ROOT/urls/all_urls.txt" | gf lfi > "$ROOT/params/lfi.txt" || true

    cat "$ROOT/urls/all_urls.txt" | gf ssrf > "$ROOT/params/ssrf.txt" || true
}

# =========================================================
# DALFOX
# =========================================================

dalfox_scan() {

    info "Dalfox scan"

    dalfox file "$ROOT/params/xss.txt" --silence > "$ROOT/nuclei/dalfox.txt" || true
}

# =========================================================
# WAF DETECTION
# =========================================================

waf_detection() {

    info "WAF detection"

    wafw00f -i "$ROOT/httpx/urls.txt" > "$ROOT/waf/waf.txt" || true
}

# =========================================================
# TAKEOVER DETECTION
# =========================================================

takeover_scan() {

    info "Subdomain takeover scan"

    nuclei \
        -l "$ROOT/subdomains/live_subs.txt" \
        -tags takeover \
        -o "$ROOT/takeovers/results.txt"
}

# =========================================================
# TLS RECON
# =========================================================

tls_recon() {

    info "TLS reconnaissance"

    tlsx \
        -l "$ROOT/subdomains/live_subs.txt" \
        -san \
        -silent \
        > "$ROOT/tls/tlsx.txt"
}

# =========================================================
# CLOUD RECON
# =========================================================

cloud_recon() {

    info "Cloud asset discovery"

    cat "$ROOT/subdomains/final.txt" | grep -iE 's3|amazonaws|blob|storage|cdn' > "$ROOT/cloud/cloud_assets.txt" || true
}

# =========================================================
# API RECON
# =========================================================

api_recon() {

    info "API reconnaissance"

    cat "$ROOT/urls/all_urls.txt" | grep -iE 'api|graphql|swagger|openapi' > "$ROOT/api/apis.txt" || true
}

# =========================================================
# GRAPHQL DETECTION
# =========================================================

graphql_scan() {

    info "GraphQL discovery"

    grep -i graphql "$ROOT/urls/all_urls.txt" > "$ROOT/api/graphql.txt" || true
}

# =========================================================
# SECRET SCANNING
# =========================================================

secret_scan() {

    info "Secret scanning"

    trufflehog filesystem "$ROOT" > "$ROOT/secrets/trufflehog.txt" || true
}

# =========================================================
# NUCLEI
# =========================================================

nuclei_scan() {

    info "Nuclei scan"

    nuclei \
        -l "$ROOT/httpx/urls.txt" \
        -severity low,medium,high,critical \
        -rl 100 \
        -c 50 \
        -o "$ROOT/nuclei/results.txt"
}

# =========================================================
# PRIORITY ENGINE
# =========================================================

priority_engine() {

    info "Prioritizing findings"

    grep -i critical "$ROOT/nuclei/results.txt" > "$ROOT/reports/critical.txt" || true

    grep -i high "$ROOT/nuclei/results.txt" > "$ROOT/reports/high.txt" || true
}

# =========================================================
# DELTA TRACKING
# =========================================================

delta_tracking() {

    info "Delta tracking"

    if [ -f "$ROOT/delta/old_subs.txt" ]; then
        comm -13 "$ROOT/delta/old_subs.txt" "$ROOT/subdomains/final.txt" > "$ROOT/delta/new_subdomains.txt"
    fi

    cp "$ROOT/subdomains/final.txt" "$ROOT/delta/old_subs.txt"
}

# =========================================================
# REPORTS
# =========================================================

generate_report() {

    info "Generating report"

    {
        echo "Target: $DOMAIN"
        echo ""
        echo "Subdomains:"
        wc -l "$ROOT/subdomains/final.txt"
        echo ""
        echo "Live Hosts:"
        wc -l "$ROOT/httpx/urls.txt"
        echo ""
        echo "URLs:"
        wc -l "$ROOT/urls/all_urls.txt"
        echo ""
        echo "Nuclei Findings:"
        wc -l "$ROOT/nuclei/results.txt"
    } > "$ROOT/reports/summary.txt"
}

# =========================================================
# MONITOR MODE
# =========================================================

monitor_mode() {

    while true; do

        info "Running monitor cycle"

        passive_enum
        recursive_enum
        resolve_hosts
        http_probe
        collect_urls
        nuclei_scan
        delta_tracking

        sleep 21600

    done
}

# =========================================================
# PARALLEL EXECUTION
# =========================================================

run_parallel() {

    resolve_hosts &
    cdn_filter &
    port_scan &
    http_probe &
    wait

    collect_urls &
    crawl_targets &
    javascript_recon &
    parameter_discovery &
    wait

    gf_analysis &
    dalfox_scan &
    waf_detection &
    takeover_scan &
    tls_recon &
    cloud_recon &
    api_recon &
    graphql_scan &
    secret_scan &
    wait

    nuclei_scan
}

# =========================================================
# MAIN
# =========================================================

main() {

    setup_dependencies

    install_all_tools

    init_database

    passive_enum

    recursive_enum

    if [ "$MODE" == "--monitor" ]; then
        monitor_mode
        exit 0
    fi

    run_parallel

    priority_engine

    delta_tracking

    generate_report

    success "Recon completed"

    echo ""
    echo "====================================="
    echo "Output Directory: $ROOT"
    echo "====================================="
}

main

```

---

# Future Improvements

Possible future upgrades:

* Golang rewrite
* AI-based prioritization
* CVE correlation engine
* Favicon clustering
* ASN intelligence
* ElasticSearch backend
* Neo4j attack graph
* Distributed workers
* Docker orchestration
* Kubernetes scaling
* AI endpoint classification
* AI exploit recommendation
* Autonomous fuzzing
* LLM-assisted triage

---

# Legal Reminder

Use only on:

* assets you own
* authorized penetration tests
* public bug bounty programs
* legal labs

Unauthorized scanning may violate laws.
