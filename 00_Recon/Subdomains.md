# Recognition

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
sudo docker run -it --rm -v "${PWD}/OutputFolder/":'/reconftw/Recon/' six2dez/reconftw:main -d $tesla -s 
```


## Discovering sub-domains
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


**FavFreak**
```bash
wget -P /home/kali/.local/bin/ https://raw.githubusercontent.com/daffi1238/dotfile/refs/heads/main/tools/get_favicon.py

wget -P /home/kali/.local/bin/ https://raw.githubusercontent.com/daffi1238/dotfile/refs/heads/main/tools/hash_favicon.py

target="https://www.financieratesla.com/"
python3 /home/kali/.local/bin/get_favicon.py $target
python3 /home/kali/.local/bin/hash_favicon.py https://www.financieratesla.com/assets/img/favicon/favicon.ico
shodan count http.favicon.hash:28960636
shodan search http.favicon.hash:28960636
```

Encadenando funcionamiento:
```bash
# obtener hash mm3 y buscar en shodan:
python3 ~/.local/bin/get_favicon.py $target | xargs -I {} python3 ~/.local/bin/hash_favicon.py {} | awk '{print $5}' | xargs -I {} sh -c 'echo {}; shodan count http.favicon.hash:{}'
```




#### Brute Forcing
**Fuzzing**
```
gobuster dns -d tesla.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 15 -i

gobuster dns -d logitravel.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 5 -i
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


