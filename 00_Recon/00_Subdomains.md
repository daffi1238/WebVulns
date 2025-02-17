# Recognition

## venv
```bash
python3 -m venv ~/enum_venv
source ~/enum_venv/bin/activate
pip install requests beautifulsoup4 mmh3 lxml
```

## Fluxe of action
- [ ] We have one or several domains to check, example.com


#### Reverse WHOIS
Cada página web tiene información del registro de la misma. Para tirar del hilo podemos utilizar dos tipos de datos esencialmente:
- Nombre de la organización
- E-mails obtenidos

https://www.whoxy.com/twitch.tv

#### Whois Databases
https://who.is/
https://www.whois.com/whois/
https://whois.domaintools.com/
https://mxtoolbox.com/Whois.aspx

#### AS
https://bgp.he.net/

```bash
# Obtener los rangos de IP's de un AS
whois -h whois.radb.net -- '-i origin AS57481' | grep -Eo "([0-9.]+){4}/[0-9]+"
```


#### Discovering sub-domains
**crt.sh**
https://github.com/daffi1238/dotfile/blob/main/tools/crt.py
```bash
python3 /home/kali/.local/bin/crt.py elcorteingles.es --unique
```

**DNSenum**
```bash
dnsenum --dnsserver 8.8.8.8 apple.com | tee dnsenum.out
# dominios
cat dnsenum.out | awk '{print $5}' | sort -u
# ips
cat dnsenum.out | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}'
```

**DNSRecon**
```bash
dnsrecon -d apple.com -n 8.8.8.8 | tee dnsrecon.out
```


**Subfinder**
```bash
subfinder -d twitch.tv -v
```

**Github**
```bash
github-subdomains.py
github-subdomains.py -y "API_TOKEN" -d twitch.es
```

**Subdomain Scraping - shosubgo** -> Shodan API KEY
```bash
https://github.com/incogbyte/shosubgo/releases/tag/v3.1
wget https://github.com/incogbyte/shosubgo/releases/download/v3.1/shobsubgo-build-linux-amd64

chmod +x -/shobsubgo-build-linux-amd64
./shobsubgo-build-linux-amd64 -d target.com -s YourAPIKEY
```


**fierce**  -> No funciona, revisar en algún momento
```bash
https://github.com/mschwager/fierce
fierce --domain google.com --subdomains accounts admin ads
```

**amass**
```
amass enum -d twitch.tv  -src
amass enum -passive -d logitravel.com
```

**Fuzzing**
```
gobuster dns -d elcorteingles.es -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 15 -i

gobuster dns -d logitravel.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 5 -i
```

**FavFreak**
https://github.com/devanshbatham/FavFreak -> No lo uso pero es una famosa referencia
https://github.com/daffi1238/dotfile/blob/main/tools/get_favicon.py
https://github.com/daffi1238/dotfile/blob/main/tools/hash_favicon.py

```bash
python3 get_favicon.py https://target.com
python3 hash_favicon.py 
shodan count http.favicon.hash:196057623
shodan search http.favicon.hash:196057623
```

Encadenando funcionamiento:
```bash
# obtener hash mm3 y buscar en shodan:
python3 ~/.local/bin/get_favicon.py https://target.com | xargs -I {} python3 ~/.local/bin/hash_favicon.py {} | awk '{print $5}' | xargs -I {} sh -c 'echo {}; shodan count http.favicon.hash:{}'
```

**Recon-ng** - Pendiente de desarrollar y sacar los API Token necesarios!!
```bash
recon-ng
marketplace search
#marketplace install all
marketplace install hackertarget
marketplace refresh

modules load hackertarget
options set SOURCE tesla.com

[recon-ng][default][hackertarget] > info
[recon-ng][default][hackertarget] > input
[recon-ng][default][hackertarget] > run
```


**GoWitness**
Actualizar con el framework de la database!




#### Get AS
- [ ] Check which AS belong the IP (or IPs)
```bash
curl -s https://api.hackertarget.com/aslookup/?q=1.2.3.4
```
    - [ ] CDP?
    - [ ] AS of the corp?
    - [ ] Cloud service?


