#!/bin/bash

# Colors
BOLD_RED='\033[1;31m'
BOLD_CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo -e "${BOLD_RED}                                                                    ${NC}"
echo -e "${BOLD_RED} ▄▄▄▄    █    ██   ▄████  ▄▄▄▄    ██▓    ▄▄▄      ▒███████▒▓█████   ${NC}"
echo -e "${BOLD_RED}▓█████▄  ██  ▓██▒ ██▒ ▀█▒▓█████▄ ▓██▒   ▒████▄    ▒ ▒ ▒ ▄▀░▓█   ▀   ${NC}"
echo -e "${BOLD_RED}▒██▒ ▄██▓██  ▒██░▒██░▄▄▄░▒██▒ ▄██▒██░   ▒██  ▀█▄  ░ ▒ ▄▀▒░ ▒███     ${NC}"
echo -e "${BOLD_RED}▒██░█▀  ▓▓█  ░██░░▓█  ██▓▒██░█▀  ▒██░   ░██▄▄▄▄██   ▄▀▒   ░▒▓█  ▄   ${NC}"
echo -e "${BOLD_RED}░▓█  ▀█▓▒▒█████▓ ░▒▓███▀▒░▓█  ▀█▓░██████▒▓█   ▓██▒▒███████▒░▒████▒  ${NC}"
echo -e "${BOLD_RED}░▒▓███▀▒░▒▓▒ ▒ ▒  ░▒   ▒ ░▒▓███▀▒░ ▒░▓  ░▒▒   ▓▒█░░▒▒ ▓░▒░▒░░ ▒░ ░  ${NC}"
echo -e "${BOLD_RED}▒░▒   ░ ░░▒░ ░ ░   ░   ░ ▒░▒   ░ ░ ░ ▒  ░ ▒   ▒▒ ░░░▒ ▒ ░ ▒ ░ ░  ░  ${NC}"
echo -e "${BOLD_RED} ░    ░  ░░░ ░ ░ ░ ░   ░  ░    ░   ░ ░    ░   ▒   ░ ░ ░ ░ ░   ░     ${NC}"
echo -e "${BOLD_RED} ░         ░           ░  ░          ░  ░     ░  ░  ░ ░       ░  ░  ${NC}"
echo -e "${BOLD_RED}      ░                        ░                  ░ ${NC}${BOLD_CYAN}made by 0xPugazh          ${NC}"
echo -e "${BOLD_RED}                                                                           ${NC}"

if [ "$#" -eq 0 ]; then
        echo -e " "
        echo -e " "
    echo -e "Usage: ${BOLD_CYAN}./bugblaze.sh domain.com${NC}"
    exit 1
fi

echo " "
echo "------------------------------------------------------------------------------------------------------------------------"

DOMAIN="$1"
RESOLVERS="/root/BugBlaze/resolvers/resolvers.txt"
RESOLVERS_TRUSTED="/root/BugBlaze/resolvers/resolvers-trusted.txt"
WORDLISTS="/root/BugBlaze/wordlists.txt"

mkdir -p /root/BugBlaze/recon/$DOMAIN/

while true; do
# Update resolvers
    echo -e "${BOLD_CYAN}Updating resolvers...${NC}"
    cd /root/BugBlaze/resolvers/
    git pull
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"

    # subdomain enumeration using Subfinder, Amass and Shuffledns
    echo -e "${BOLD_CYAN}Subdomain enumeration at $DOMAIN...${NC}"
    subfinder -d $DOMAIN -all -silent | anew /root/BugBlaze/recon/$DOMAIN/subs.txt
    amass enum -d $DOMAIN -noalts -passive -norecursive | anew /root/BugBlaze/recon/$DOMAIN/subs.txt
    shuffledns -d $DOMAIN -silent -r $RESOLVERS -w $WORDLISTS | anew /root/BugBlaze/recon/$DOMAIN/subs.txt
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------" 
    
    # Delete resolved.txt if it exists
    [ -e /root/BugBlaze/recon/$DOMAIN/resolved.txt ] && rm /root/BugBlaze/recon/$DOMAIN/resolved.txt

    # Delete ports.txt if it exists
    [ -e /root/BugBlaze/recon/$DOMAIN/ports.txt ] && rm /root/BugBlaze/recon/$DOMAIN/ports.txt

    # DNS resolving with PureDNS
    echo -e "${BOLD_CYAN}DNS resolving at $DOMAIN...${NC}"
    puredns resolve  /root/BugBlaze/recon/$DOMAIN/subs.txt --resolvers $RESOLVERS --resolvers-trusted $RESOLVERS_TRUSTED --quiet --write /root/BugBlaze/recon/$DOMAIN/resolved.txt
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"

    # Port scanning with Naabu
    echo -e "${BOLD_CYAN}Portscanning at $DOMAIN...${NC}"
    cat /root/BugBlaze/recon/$DOMAIN/resolved.txt | parallel -j 100 echo {} | naabu -rate 3000 -silent -p 1-65535 -nmap | anew /root/BugBlaze/recon/$DOMAIN/ports.txt
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"

    # Get current time
    current_time=$(date +"%Y%m%d_%H%M%S")

    # Vulnerability scanning with Nuclei
    echo -e "${BOLD_CYAN}Vulnerability scanning at $DOMAIN...${NC}"
    nuclei -silent -l /root/BugBlaze/recon/$DOMAIN/ports.txt \
    -es info,unknown -rl 500 -bs 250 -c 50 \
    -ss template-spray \
    -eid dns-rebinding,CVE-2000-0114,CVE-2017-5487 \
    -ept ssl,tcp -etags creds-stuffing \
    -stats -si 60 -o /root/BugBlaze/recon/$DOMAIN/nuclei-$current_time.txt | notify -silent
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"

    # Countdown before the next scan
    for ((i = 60; i >= 1; i--)); do
        printf "${BOLD_CYAN}%02d minutes left to start the scan...${NC}\n" "$i"
        sleep 60
    done
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"
done
