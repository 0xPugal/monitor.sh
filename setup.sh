#!/bin/bash

## Install packages
sudo apt install -y parallel
sudo apt install -y libpcap-dev

## Determine the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

## Install massdns
git clone https://github.com/blechschmidt/massdns.git "$SCRIPT_DIR/massdns"
cd "$SCRIPT_DIR/massdns"
make
sudo make install

## Install tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/owasp-amass/amass/v3/...@master
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
go install github.com/d3mondev/puredns/v2@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/tomnomnom/anew@latest
go install -v github.com/projectdiscovery/notify/cmd/notify@latest

sudo cp ~/go/bin/* /usr/bin/

# Install wordlist and resolvers
cd "$SCRIPT_DIR"
git clone https://github.com/trickest/resolvers
wget https://raw.githubusercontent.com/n0kovo/n0kovo_subdomains/main/n0kovo_subdomains_huge.txt -O wordlists.txt

# check if tools are installed
hash subfinder 2>/dev/null && echo "subfinder: Installed" || echo "subfinder: Not Installed"
hash amass 2>/dev/null && echo "amass: Installed" || echo "amass: Not Installed"
hash shuffledns 2>/dev/null && echo "shuffledns: Installed" || echo "shuffledns: Not Installed"
hash puredns 2>/dev/null && echo "puredns: Installed" || echo "puredns: Not Installed"
hash naabu 2>/dev/null && echo "naabu: Installed" || echo "naabu: Not Installed"
hash nuclei 2>/dev/null && echo "nuclei: Installed" || echo "nuclei: Not Installed"
hash anew 2>/dev/null && echo "anew: Installed" || echo "anew: Not Installed"
hash notify 2>/dev/null && echo "notify: Installed" || echo "notify: Not Installed"
[ -f "$SCRIPT_DIR/wordlists.txt" ] && echo "wordlists.txt found" || echo "wordlists.txt not found" 
[ -f "$SCRIPT_DIR/resolvers/resolvers.txt" ] && echo "resolvers.txt found" || echo "resolvers.txt not found"
echo " "
echo "Done!!!"
