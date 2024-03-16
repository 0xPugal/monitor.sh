#!/bin/bash

BOLD_RED='\033[1;31m'
BOLD_CYAN='\033[1;36m'
BOLD_GREEN='\033[1;32m'
NC='\033[0m' # No Color

# Check if Golang is installed
if ! command -v go &> /dev/null; then
    echo -e "${BOLD_RED}Golang is not installed.${NC} Please install Golang manually and run the script again."
    exit 1
fi

## Install packages
echo -e "${BOLD_CYAN}Updating...${NC}"
sudo apt update
echo ""
echo -e "${BOLD_CYAN}Installing Parallel...${NC}"
sudo apt install -y parallel
echo ""
echo -e "${BOLD_CYAN}Installing libpcap...${NC}"
sudo apt install -y libpcap-dev
echo ""
## Determine the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

## Install massdns
echo -e "${BOLD_CYAN}MassDNS...${NC}"
git clone https://github.com/blechschmidt/massdns.git "$SCRIPT_DIR/massdns"
cd "$SCRIPT_DIR/massdns"
make
sudo make install
echo ""

## Install tools
echo -e "${BOLD_CYAN}subfinder...${NC}"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
echo ""
echo -e "${BOLD_CYAN}amass...${NC}"
go install -v github.com/owasp-amass/amass/v3/...@master
echo ""
echo -e "${BOLD_CYAN}shuffleDNS...${NC}"
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
echo ""
echo -e "${BOLD_CYAN}pureDNS...${NC}"
go install github.com/d3mondev/puredns/v2@latest
echo ""
echo -e "${BOLD_CYAN}naabu...${NC}"
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
echo ""
echo -e "${BOLD_CYAN}Nuclei...${NC}"
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
echo ""
echo -e "${BOLD_CYAN}anew...${NC}"
go install -v github.com/tomnomnom/anew@latest
echo ""
echo -e "${BOLD_CYAN}notify...${NC}"
go install -v github.com/projectdiscovery/notify/cmd/notify@latest
echo ""

sudo cp ~/go/bin/* /usr/bin/

# Install wordlist and resolvers
echo -e "${BOLD_CYAN}Updating resolvers..."
cd "$SCRIPT_DIR"
git clone https://github.com/trickest/resolvers
echo ""
echo -e "${BOLD_CYAN}Downloading wordlists..."
wget https://raw.githubusercontent.com/n0kovo/n0kovo_subdomains/main/n0kovo_subdomains_huge.txt -O wordlists.txt
echo ""

# check if tools are installed
hash subfinder 2>/dev/null && echo -e "${BOLD_GREEN}subfinder: Installed${NC}" || echo -e "${BOLD_RED}subfinder: Not Installed${NC}"
hash amass 2>/dev/null && echo -e "${BOLD_GREEN}amass: Installed${NC}" || echo -e "${BOLD_RED}amass: Not Installed${NC}"
hash shuffledns 2>/dev/null && echo -e "${BOLD_GREEN}shuffledns: Installed${NC}" || echo -e "${BOLD_RED}shuffledns: Not Installed${NC}"
hash puredns 2>/dev/null && echo -e "${BOLD_GREEN}puredns: Installed${NC}" || echo -e "${BOLD_RED}puredns: Not Installed${NC}"
hash naabu 2>/dev/null && echo -e "${BOLD_GREEN}naabu: Installed${NC}" || echo -e "${BOLD_RED}naabu: Not Installed${NC}"
hash nuclei 2>/dev/null && echo -e "${BOLD_GREEN}nuclei: Installed${NC}" || echo -e "${BOLD_RED}nuclei: Not Installed${NC}"
hash anew 2>/dev/null && echo -e "${BOLD_GREEN}anew: Installed${NC}" || echo -e "${BOLD_RED}anew: Not Installed${NC}"
hash notify 2>/dev/null && echo -e "${BOLD_GREEN}notify: Installed${NC}" || echo -e "${BOLD_RED}notify: Not Installed${NC}"
[ -f "$SCRIPT_DIR/wordlists.txt" ] && echo -e "${BOLD_GREEN}wordlists downloaded${NC}" || echo -e "${BOLD_RED}wordlists.txt not found${NC}" 
[ -f "$SCRIPT_DIR/resolvers/resolvers.txt" ] && echo -e "${BOLD_GREEN}resolvers updated${NC}" || echo -e "${BOLD_RED}resolvers.txt not found${NC}"
echo " "
echo -e "${BOLD_CYAN}Done!!!${NC}"
