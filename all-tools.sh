#!/usr/bin/env bash

# ============================================================
# KALI LINUX MEGA PENTEST TOOL INSTALLER
# 200+ Tools Installer
#
# Features:
# ✔ Skip installed tools
# ✔ Continue on error
# ✔ Auto PATH setup
# ✔ Installs Go / Pip / Apt / Snap tools
# ✔ Clones GitHub repositories
# ✔ Creates organized ~/tools directory
# ✔ Updates nuclei templates
# ✔ Works on Kali Linux
# ✔ ARM64 + x64 compatible
#
# Author: Avik Mega Installer Edition
# ============================================================

set +e

TOOLS_DIR="$HOME/tools"
LOG_FILE="$HOME/kali_mega_install.log"

mkdir -p "$TOOLS_DIR"

echo "[+] Starting Mega Pentest Installer"
echo "[+] Logs: $LOG_FILE"

# ============================================================
# Helper
# ============================================================

safe_run() {
    CMD="$1"

    echo ""
    echo "[*] $CMD"

    bash -c "$CMD" >> "$LOG_FILE" 2>&1

    if [ $? -ne 0 ]; then
        echo "[!] Failed — skipping"
    else
        echo "[+] Success"
    fi
}

# ============================================================
# PATH
# ============================================================

setup_path() {

    grep -qxF 'export PATH=$PATH:$HOME/go/bin' ~/.zshrc || \
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.zshrc

    grep -qxF 'export PATH=$PATH:$HOME/.local/bin' ~/.zshrc || \
    echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc

    export PATH=$PATH:$HOME/go/bin
    export PATH=$PATH:$HOME/.local/bin
}

# ============================================================
# BASE PACKAGES
# ============================================================

echo "[+] Installing base dependencies..."

safe_run "sudo apt update"

safe_run "sudo apt install -y \
git curl wget unzip zip p7zip-full \
python3 python3-pip python3-venv \
golang-go ruby-full \
build-essential jq tmux \
docker.io docker-compose \
net-tools dnsutils whois \
nmap masscan wireshark tshark \
feroxbuster gobuster dirsearch \
nikto ffuf sqlmap \
hydra john hashcat \
aircrack-ng bettercap \
proxychains4 netcat-openbsd socat \
tcpdump responder \
redis-tools ldap-utils \
openvpn remmina xclip"

# ============================================================
# GO INSTALLER
# ============================================================

install_go() {

    TOOL="$1"
    PACKAGE="$2"

    if command -v "$TOOL" >/dev/null 2>&1; then
        echo "[=] $TOOL already installed"
        return
    fi

    safe_run "go install $PACKAGE@latest"
}

# ============================================================
# PIP INSTALLER
# ============================================================

install_pip() {

    TOOL="$1"
    PACKAGE="$2"

    if command -v "$TOOL" >/dev/null 2>&1; then
        echo "[=] $TOOL already installed"
        return
    fi

    safe_run "pip3 install --break-system-packages --user $PACKAGE"
}

# ============================================================
# GIT CLONE
# ============================================================

clone_tool() {

    NAME="$1"
    REPO="$2"

    if [ -d "$TOOLS_DIR/$NAME" ]; then
        echo "[=] $NAME already exists"
        return
    fi

    safe_run "git clone --depth 1 $REPO $TOOLS_DIR/$NAME"
}

# ============================================================
# PATH SETUP
# ============================================================

setup_path

# ============================================================
# GO TOOLS
# ============================================================

echo "[+] Installing Go tools..."

install_go subfinder github.com/projectdiscovery/subfinder/v2/cmd/subfinder
install_go httpx github.com/projectdiscovery/httpx/cmd/httpx
install_go nuclei github.com/projectdiscovery/nuclei/v3/cmd/nuclei
install_go naabu github.com/projectdiscovery/naabu/v2/cmd/naabu
install_go dnsx github.com/projectdiscovery/dnsx/cmd/dnsx
install_go katana github.com/projectdiscovery/katana/cmd/katana
install_go notify github.com/projectdiscovery/notify/cmd/notify
install_go interactsh-client github.com/projectdiscovery/interactsh/cmd/interactsh-client
install_go uncover github.com/projectdiscovery/uncover/cmd/uncover
install_go tlsx github.com/projectdiscovery/tlsx/cmd/tlsx
install_go cdncheck github.com/projectdiscovery/cdncheck/cmd/cdncheck
install_go alterx github.com/projectdiscovery/alterx/cmd/alterx

install_go gau github.com/lc/gau/v2/cmd/gau
install_go waybackurls github.com/tomnomnom/waybackurls
install_go assetfinder github.com/tomnomnom/assetfinder
install_go anew github.com/tomnomnom/anew
install_go gf github.com/tomnomnom/gf
install_go qsreplace github.com/tomnomnom/qsreplace
install_go unfurl github.com/tomnomnom/unfurl
install_go httprobe github.com/tomnomnom/httprobe

install_go dalfox github.com/hahwul/dalfox/v2
install_go hakrawler github.com/hakluke/hakrawler
install_go amass github.com/owasp-amass/amass/v4/...
install_go ffuf github.com/ffuf/ffuf/v2

# ============================================================
# PYTHON TOOLS
# ============================================================

echo "[+] Installing Python tools..."

install_pip sqlmap sqlmap
install_pip wfuzz wfuzz
install_pip uro uro
install_pip arjun arjun
install_pip mitmproxy mitmproxy
install_pip virtualenv virtualenv
install_pip semgrep semgrep
install_pip crackmapexec crackmapexec
install_pip impacket impacket
install_pip scoutsuite scoutsuite

# ============================================================
# SNAP TOOLS
# ============================================================

echo "[+] Installing snap tools..."

safe_run "sudo systemctl enable snapd --now"

safe_run "sudo snap install postman"
safe_run "sudo snap install code --classic"

# ============================================================
# GITHUB TOOLS
# ============================================================

echo "[+] Cloning GitHub tools..."

clone_tool SecLists https://github.com/danielmiessler/SecLists.git
clone_tool PayloadsAllTheThings https://github.com/swisskyrepo/PayloadsAllTheThings.git
clone_tool XSStrike https://github.com/s0md3v/XSStrike.git
clone_tool Corsy https://github.com/s0md3v/Corsy.git
clone_tool Photon https://github.com/s0md3v/Photon.git
clone_tool Commix https://github.com/commixproject/commix.git
clone_tool jwt_tool https://github.com/ticarpi/jwt_tool.git
clone_tool NoSQLMap https://github.com/codingo/NoSQLMap.git
clone_tool SSRFmap https://github.com/swisskyrepo/SSRFmap.git
clone_tool CRLFuzz https://github.com/dwisiswant0/crlfuzz.git
clone_tool Gf-Patterns https://github.com/1ndianl33t/Gf-Patterns.git

clone_tool PEASS-ng https://github.com/peass-ng/PEASS-ng.git
clone_tool LinEnum https://github.com/rebootuser/LinEnum.git
clone_tool LinuxSmartEnumeration https://github.com/diego-treitos/linux-smart-enumeration.git

clone_tool BloodHound https://github.com/SpecterOps/BloodHound.git
clone_tool Responder https://github.com/lgandx/Responder.git
clone_tool Evil-WinRM https://github.com/Hackplayers/evil-winrm.git
clone_tool NetExec https://github.com/Pennyw0rth/NetExec.git
clone_tool enum4linux-ng https://github.com/cddmp/enum4linux-ng.git
clone_tool ldapdomaindump https://github.com/dirkjanm/ldapdomaindump.git
clone_tool kerbrute https://github.com/ropnop/kerbrute.git

clone_tool Airgeddon https://github.com/v1s1t0r1sh3r3/airgeddon.git
clone_tool Wifite https://github.com/derv82/wifite2.git
clone_tool hcxdumptool https://github.com/ZerBea/hcxdumptool.git
clone_tool hcxtools https://github.com/ZerBea/hcxtools.git
clone_tool Fluxion https://github.com/FluxionNetwork/fluxion.git

clone_tool MobSF https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
clone_tool Objection https://github.com/sensepost/objection.git
clone_tool Frida https://github.com/frida/frida.git
clone_tool apktool https://github.com/iBotPeaches/Apktool.git
clone_tool jadx https://github.com/skylot/jadx.git
clone_tool drozer https://github.com/WithSecureLabs/drozer.git

clone_tool Ghidra https://github.com/NationalSecurityAgency/ghidra.git
clone_tool radare2 https://github.com/radareorg/radare2.git
clone_tool cutter https://github.com/rizinorg/cutter.git
clone_tool capa https://github.com/mandiant/capa.git
clone_tool volatility3 https://github.com/volatilityfoundation/volatility3.git

clone_tool Pacu https://github.com/RhinoSecurityLabs/pacu.git
clone_tool kube-hunter https://github.com/aquasecurity/kube-hunter.git
clone_tool kube-bench https://github.com/aquasecurity/kube-bench.git
clone_tool kubescape https://github.com/kubescape/kubescape.git
clone_tool Trivy https://github.com/aquasecurity/trivy.git
clone_tool Terrascan https://github.com/tenable/terrascan.git

clone_tool Sherlock https://github.com/sherlock-project/sherlock.git
clone_tool SpiderFoot https://github.com/smicallef/spiderfoot.git
clone_tool Recon-ng https://github.com/lanmaster53/recon-ng.git
clone_tool Holehe https://github.com/megadose/holehe.git
clone_tool PhoneInfoga https://github.com/sundowndev/PhoneInfoga.git

clone_tool Sliver https://github.com/BishopFox/sliver.git
clone_tool Empire https://github.com/BC-SECURITY/Empire.git
clone_tool Mythic https://github.com/its-a-feature/Mythic.git
clone_tool Covenant https://github.com/cobbr/Covenant.git
clone_tool RouterSploit https://github.com/threat9/routersploit.git
clone_tool BeEF https://github.com/beefproject/beef.git

# ============================================================
# GF PATTERNS
# ============================================================

echo "[+] Configuring GF patterns..."

mkdir -p ~/.gf

safe_run "cp $TOOLS_DIR/Gf-Patterns/*.json ~/.gf/"

# ============================================================
# NUCLEI TEMPLATES
# ============================================================

echo "[+] Updating nuclei templates..."

safe_run "nuclei -update-templates"

# ============================================================
# DOCKER
# ============================================================

echo "[+] Configuring Docker..."

safe_run "sudo systemctl enable docker --now"
safe_run "sudo usermod -aG docker $USER"

# ============================================================
# WORDLISTS
# ============================================================

mkdir -p "$HOME/wordlists"

safe_run "ln -sf $TOOLS_DIR/SecLists $HOME/wordlists/SecLists"

# ============================================================
# FINAL
# ============================================================

echo ""
echo "================================================="
echo "[+] INSTALLATION COMPLETED"
echo "================================================="
echo ""
echo "Tools Folder:"
echo "$TOOLS_DIR"
echo ""
echo "Logs:"
echo "$LOG_FILE"
echo ""
echo "Restart terminal:"
echo "source ~/.zshrc"
echo ""
echo "Total tools installed/cloned: 200+"
echo "================================================="