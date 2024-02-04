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

# Install wordlist and resolvers
cd ~/sentinel-X/
git clone https://github.com/trickest/resolvers
wget https://raw.githubusercontent.com/n0kovo/n0kovo_subdomains/main/n0kovo_subdomains_huge.txt
mv n0kovo_subdomains_huge.txt wordlists.txt

echo "Done!!!"