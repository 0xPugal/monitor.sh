#!/bin/bash

## Install packages
sudo apt install -y parallel
sudo apt install -y libpcap-dev

## Install massdns
git clone https://github.com/blechschmidt/massdns.git
cd massdns
make
sudo make install

## Install tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/owasp-amass/amass/v3/...@master
go install github.com/d3mondev/puredns/v2@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/tomnomnom/anew@latest
go install -v github.com/projectdiscovery/notify/cmd/notify@latest

sudo /root/go/bin/subfinder /usr/bin/
sudo /root/go/bin/amass /usr/bin/
sudo /root/go/bin/puredns /usr/bin/
sudo /root/go/bin/naabu /usr/bin/
sudo /root/go/bin/nuclei /usr/bin/
sudo /root/go/bin/anew /usr/bin/
sudo /root/go/bin/notify /usr/bin/

# Install wordlist and resolvers
cd ~/BugBlaze/
git clone https://github.com/trickest/resolvers
wget https://raw.githubusercontent.com/n0kovo/n0kovo_subdomains/main/n0kovo_subdomains_huge.txt
mv n0kovo_subdomains_huge.txt wordlists.txt

# check if tools are installed
hash subfinder 2>/dev/null && echo "subfinder: Installed" || echo "subfinder: Not Installed"
hash amass 2>/dev/null && echo "amass: Installed" || echo "amass: Not Installed"
hash puredns 2>/dev/null && echo "puredns: Installed" || echo "puredns: Not Installed"
hash naabu 2>/dev/null && echo "naabu: Installed" || echo "naabu: Not Installed"
hash nuclei 2>/dev/null && echo "nuclei: Installed" || echo "nuclei: Not Installed"
hash anew 2>/dev/null && echo "anew: Installed" || echo "anew: Not Installed"
hash notify 2>/dev/null && echo "notify: Installed" || echo "notify: Not Installed"
[ -f /root/BugBlaze/wordlists.txt ] && echo "wordlists.txt found" || echo "wordlists.txt not found" 
[ -f /root/BugBlaze/resolvers/resolvers.txt ] && echo "resolvers.txt found" || echo "resolvers.txt not found"

echo "Done!!!"
