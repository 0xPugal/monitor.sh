# BugBlaze
***Continuous Reconnaissance and Vulnerability Scanning for Bug Bounties***
-----------
![BugBlaze](https://github.com/0xPugazh/BugBlaze/assets/75373225/4d1cb0df-375d-412f-ab31-f128c8e3a497)


### Requirements
+ Install golang from [https://go.dev/doc/install](https://go.dev/doc/install)

### Installation
```
git clone https://github.com/0xPugazh/BugBlaze
cd BugBlaze
chmod +x setup.sh bugblaze.sh
./setup.sh
```

### Usage
``` 
./bugblaze.sh domain.com
```

### Tools included
+ Subdomain enumeration (Subfinder, Amass, Shuffledns)
+ DNS resolving ( PureDNS)
+ Port scanning (Naabu)
+ Vulnerability Scanning (Nuclei)
+ Resolvers (trickest)
+ Wordlists (n0kovo_subdomains)

### Note
+ Configure you api tokens in ``subfinder`` and ``amass`` config file for more subdomains
+ Add your telergam/discord/slack token in ``notify`` config file for notifications 
+ If you want to use custom wordlists and resovers, change variable path in bugblaze.sh (line ``36``,``37``,``38``)

### Get 200$ credits on DO
[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=87789189e3ea&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)
