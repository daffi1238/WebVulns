https://github.com/six2dez/pentest-book/tree/master/recon/subdomain-enum

# Recognition
To start this process is neccesary a files with the domains and subdomains identified previously in the ASN chapter.

For this is foundamental limit the scope to the domains and avoid subdomains. If the corporation have several subsidiaries maybe each one may have 3 or 2 main domains.


## Getting ready
```bash
python3 -m venv ~/enum_venv
source ~/enum_venv/bin/activate

#install pip  if not installed
(enum_venv)$ python -m ensurepip --upgrade

(enum_venv)$ pip install requests beautifulsoup4 mmh3 lxml
```

- [ ] Find subdomains of a specific domain!


## Reverse WHOIS
Cada página web tiene información del registro de la misma. Para tirar del hilo podemos utilizar dos tipos de datos esencialmente:
- Nombre de la organización
- E-mails obtenidos

https://www.whoxy.com/twitch.tv



#### Whois Databases
https://who.is/
https://www.whois.com/whois/
https://whois.domaintools.com/
https://mxtoolbox.com/Whois.aspx


## Reconftw
```bash
target=tesla.com
sudo docker run -it --rm -v "${PWD}/OutputFolder/":'/reconftw/Recon/' six2dez/reconftw:main -d $target -s 
```


## Discovering sub-domains
**Reverse IP Lookup to IP Range**
```bash
mkdir rapiddns
curl -s "https://rapiddns.io/sameip/64.4.250.0/24?full=1#result" > rapiddns.out
curl -s "https://rapiddns.io/sameip/64.4.250.0/24?page=2" > rapiddns2.out


nTotal=$(cat rapiddns.out| grep -oP 'Total.*' | awk '{print $2}' FS=";" | grep -oP ">.*?</" | tr -d '<>/')

# page to repeat request to rapiddns
echo "$((($nTotal / 100) + 1))"

for file in rapiddns*; do
  awk '/<table/,/<\/table>/' "$file" > "./${file%.out}_table.html"
done

firefox /tmp/*_table.html

# get all domains
cat rapiddns2_table.html | grep -E "scope|td" | grep -A1 scope | grep td | tr -d "</>" | xargs | tr " " "\n"
```

**Subfinder**
```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

target="tesla.com"
subfinder -d $target -v | grep $target > subfinder.out
```

**crt.sh**
```bash
wget -P /home/kali/.local/bin/ https://raw.githubusercontent.com/daffi1238/dotfile/refs/heads/main/tools/crt.py

target="tesla.com"
python3 /home/kali/.local/bin/crt.py $target --unique | grep $target > crtpy.out
```

**DNSRecon**
```bash
dnsrecon -d apple.com -n 1.1.1.1 | tee dnsrecon.out
```


**Github**
```bash
github-subdomains.py
github-subdomains.py -y "API_TOKEN" -d twitch.es
```

**Shodan** -> Shodan API KEY
shobsubgo -> Best output for subdomains
```bash
https://github.com/incogbyte/shosubgo/releases/tag/v3.1

wget -P /home/kali/.local/bin/ https://github.com/incogbyte/shosubgo/releases/download/v3.1/shobsubgo-build-linux-amd64

YourAPIKEY=""
chmod +x -P /home/kali/.local/bin/shobsubgo-build-linux-amd64

target="tesla.com"
-P /home/kali/.local/bin/shobsubgo-build-linux-amd64 -d $target -s $YourAPIKEY | tee shobsubgo.out

# or original command
shodan init $YourAPIKEY
shodan domain tesla.com
```



**amass**
```bash
target="tesla.com"
amass enum -passive -d $target | tee amass.out
```

**assetfinder**
```bash
export PATH=$PATH:$HOME/go/bin 
go install github.com/tomnomnom/assetfinder@latest
assetfinder -subs-only elcorteingles.es
cat subfinder.out  
```

**dnsX**
```bash
sudo apt install dnsx
cat subfinder.out | dnsx -silent -a -resp
```




#### HTTP Services
- Obtener todas las IP's y todos los dominios y subdominios de los comandos anteriores
- Escanear puertos
- Aplicar httpx a cada ip-puerto identificado
```bash
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
export PATH=$PATH:$HOME/go/bin
cat subdomains.txt | httpx -follow-redirects -random-agent -status-code -silent -retries 2 -title -web-server -tech-detect -location -no-color -o websites.txt

#cat output.txt | grep tcp | awk ' {print $4,":",$3}' | tr -d ' ' | httpx -title -sc -cl
```


#### Brute Forcing
https://github.com/danielmiessler/SecLists/tree/master/Discovery/DNS
**Fuzzing**
```
gobuster dns -d tesla.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 15 -i

gobuster dns -d logitravel.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 5 -i



┌──(kali㉿kali)-[/usr/share/seclists/Discovery/DNS]
└─$ ls                                              
bitquark-subdomains-top100000.txt
bug-bounty-program-subdomains-trickest-inventory.txt
combined_subdomains.txt
deepmagic.com-prefixes-top50000.txt
deepmagic.com-prefixes-top500.txt
dns-Jhaddix.txt
fierce-hostlist.txt
italian-subdomains.txt
n0kovo_subdomains.txt
namelist.txt
README.md
services-names.txt
shubs-stackoverflow.txt
shubs-subdomains.txt
sortedcombined-knock-dnsrecon-fierce-reconng.txt
subdomains-spanish.txt
subdomains-top1million-110000.txt
subdomains-top1million-20000.txt
subdomains-top1million-5000.txt
tlds.txt
```

#### DNSValidator
Validación de DNS de confianza para evitar restricción por tráfico o por geografía:
```
source ~/enum_venv/bin/activate
pip install setuptools

git clone https://github.com/vortexau/dnsvalidator
cd dnsvalidator

python3 setup.py install

dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 20 -o resolvers.txt
```


### ShuffleDNS
```bash
# https://github.com/projectdiscovery/shuffledns
export PATH=$PATH:$HOME/go/bin
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest

shuffledns -d example.com -list example-subdomains.txt -r resolvers.txt -mode resolve
subfinder -d example.com | shuffledns -d example.com -r resolvers.txt -mode resolve

```

#### Subdomain Enumeration Subdomains From Content Security Policy
```bash
curl -I -s https://api-s.sandbox.paypal.com | grep -iE 'content-security-policy|CSP' |tr " " "\n" | grep "\." | tr -d ";" | sed 's/\*\.//g' | sort -u
```

#### Subdomain Enumeration Using Favicon Hashes
**FavFreak**
```bash
source ~/enum_venv/bin/activate

wget -P /home/kali/.local/bin/ https://raw.githubusercontent.com/daffi1238/dotfile/refs/heads/main/tools/get_favicon.py

wget -P /home/kali/.local/bin/ https://raw.githubusercontent.com/daffi1238/dotfile/refs/heads/main/tools/hash_favicon.py

target="https://www.tesla.com/"
python3 /home/kali/.local/bin/get_favicon.py $target
python3 /home/kali/.local/bin/hash_favicon.py https://www.tesla.com/assets/img/favicon/favicon.ico
shodan count http.favicon.hash:-38960636
shodan search http.favicon.hash:48960636
```

Encadenando funcionamiento:
```bash
# obtener hash mm3 y buscar en shodan:
source ~/enum_venv/bin/activate
shodan init $APIKEY

target="https://www.paypalobjects.com"
# check
python3 ~/.local/bin/get_favicon.py $target
python3 ~/.local/bin/get_favicon.py $target | xargs -I {} python3 ~/.local/bin/hash_favicon.py {} | awk '{print $5}' | xargs -I {} sh -c 'echo {}; shodan search http.favicon.hash:{} --fields hostnames'

# manual alternative
curl -s https://www.paypalobjects.com/favicon.ico | base64 | python3 -c 'import mmh3, sys;print(mmh3.hash(sys.stdin.buffer.read()))' | xargs -I{} shodan search http.favicon.hash:{} --fields hostnames | tr ";" "\n"
```


#### Search-Engine Subdomain Enumeration
**Sublit3r**
```bash
sudo apt install sublist3r
sublist3r -d axesinmotion.com

```

**GooFuzz**
```bash
git clone https://github.com/m3n0sd0n4ld/GooFuzz
cd GooFuzz

GooFuzz -t site.com -s -p 10 -d 5 -o GooFuzz-subdomains.txt
```

#### Web Archive for Subdomains enumeration
Con gau obtenemos dominios de los archives y con unfurl extrae los dominios
```bash
export PATH=$PATH:$HOME/go/bin 
go install github.com/tomnomnom/unfurl@latest

docker run --rm sxcurity/gau:latest --help
docker run gau tesla.com | tee -a gau.out

# subdomains scraping
docker run --rm sxcurity/gau:latest elcorteingles.es | unfurl -u domains | sort -u


```

#### Exclude Dead Subdomains
```
cat paypal-subdomain.txt | httpx -sc -cl --title -o paypalalive-subdomain.txt
```


**GoWitness**
Actualizar con el framework de la database!








# Conclusions
From here process we should have a file with all the subdomains identified. We would expand the first subdomain scope. 