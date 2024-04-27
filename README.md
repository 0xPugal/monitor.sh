# Monitor.sh
***Continuous Reconnaissance and Vulnerability Scanning for Bug Bounties***
-----------

### Requirements
+ Install golang from [https://go.dev/doc/install](https://go.dev/doc/install)

### Installation
```
git clone https://github.com/0xPugal/monitor.sh
cd monitor.sh
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
