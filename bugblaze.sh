#!/bin/bash

# Determine the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
BUGBLAZE_DIR="$SCRIPT_DIR"

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
RESOLVERS="$BUGBLAZE_DIR/resolvers/resolvers.txt"
RESOLVERS_TRUSTED="$BUGBLAZE_DIR/resolvers/resolvers-trusted.txt"
WORDLISTS="$BUGBLAZE_DIR/wordlists.txt"

mkdir -p "$BUGBLAZE_DIR/output/$DOMAIN/"

while true; do
    # Update resolvers
    echo -e "${BOLD_CYAN}Updating resolvers...${NC}"
    cd "$BUGBLAZE_DIR/resolvers/"
    git pull
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"

    # subdomain enumeration using Subfinder, Amass, and Shuffledns
    echo -e "${BOLD_CYAN}Subdomain enumeration at $DOMAIN...${NC}"
    subfinder -d "$DOMAIN" -all -silent | anew "$BUGBLAZE_DIR/output/$DOMAIN/subs.txt"
    amass enum -d "$DOMAIN" -noalts -passive -norecursive | anew "$BUGBLAZE_DIR/output/$DOMAIN/subs.txt"
    shuffledns -d "$DOMAIN" -silent -r "$RESOLVERS" -w "$WORDLISTS" | anew "$BUGBLAZE_DIR/output/$DOMAIN/subs.txt"
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"

    # Delete resolved.txt if it exists
    [ -e "$BUGBLAZE_DIR/output/$DOMAIN/resolved.txt" ] && rm "$BUGBLAZE_DIR/output/$DOMAIN/resolved.txt"

    # Delete ports.txt if it exists
    [ -e "$BUGBLAZE_DIR/output/$DOMAIN/ports.txt" ] && rm "$BUGBLAZE_DIR/output/$DOMAIN/ports.txt"

    # DNS resolving with PureDNS
    echo -e "${BOLD_CYAN}DNS resolving at $DOMAIN...${NC}"
    puredns resolve "$BUGBLAZE_DIR/output/$DOMAIN/subs.txt" --resolvers "$RESOLVERS" --resolvers-trusted "$RESOLVERS_TRUSTED" --quiet --write "$BUGBLAZE_DIR/output/$DOMAIN/resolved.txt"
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"

    # Port scanning with Naabu
    echo -e "${BOLD_CYAN}Port scanning at $DOMAIN...${NC}"
    cat "$BUGBLAZE_DIR/output/$DOMAIN/resolved.txt" | parallel -j 100 echo {} | naabu -rate 3000 -silent -p 1-65535 -nmap | anew "$BUGBLAZE_DIR/output/$DOMAIN/ports.txt"
    echo " "
    echo "------------------------------------------------------------------------------------------------------------------------"

    # Get the current time
    current_time=$(date +"%Y%m%d_%H%M%S")

    # Vulnerability scanning with Nuclei
    echo -e "${BOLD_CYAN}Vulnerability scanning at $DOMAIN...${NC}"
    nuclei -silent -l "$BUGBLAZE_DIR/output/$DOMAIN/ports.txt" \
        -es info,unknown -rl 500 -bs 250 -c 50 \
        -ss template-spray \
        -eid dns-rebinding,CVE-2000-0114,CVE-2017-5487 \
        -ept ssl,tcp -etags creds-stuffing \
        -stats -si 60 -o "$BUGBLAZE_DIR/output/$DOMAIN/nuclei-$current_time.txt" | notify -silent
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
