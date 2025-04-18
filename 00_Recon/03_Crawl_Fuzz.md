https://github.com/six2dez/pentest-book/blob/master/enumeration/web/crawl-fuzz.md


Pendiente de analizar:
https://github.com/ffuf/ffuf/wiki/Scraper


TODO:

- Uso de scrapers
https://github.com/ffuf/ffuf/wiki/Scraper
    -Extraer títulos
    - extraer url's
    - grepear por "token|pass|key|api"


# Waybackurls
```bash
# https://github.com/tomnomnom/waybackurls
# go install github.com/tomnomnom/waybackurls@latest

mkdir wayback;cd wayback

target="https://www.logitravel.com/"
name=$(echo $target | sed 's|/||g' | awk '{print $2}' FS=":")
echo $name
waybackurls $target | tee $name

# domains and subdomains
cat $name | grep -oP "https?://.*?/" | sort -u # use httpx to check status

cat $name | grep -oP "https?://.*?/" | sort -u | sed 's|https://||g;s|http://||g' | sort -u | awk '{print $1}' FS="/" | awk '{print $1}' FS="&" | grep -Ev "google|youtube" | sort -u > domains.txt

## name resolution
cat domains.txt | xargs -I {} zsh -c 'echo ;echo {}; dig +short {} @1.1.1.1; echo' | tee dig.out

cat dig.out | grep -P -B1 '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | grep -Pv '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | tr -d "\-\-" | sed 's/\.$//g' | sed '/^$/d' | sort -u | tee valid_domains.txt

grep -Ff valid_domains.txt $name | tee $name

## check http response
cat $name | httpx -follow-redirects -random-agent -status-code -silent -retries 2 -title -web-server -tech-detect -location -no-color -o websites.txt

## check parameter
#https://github.com/tomnomnom/qsreplace -> go install github.com/tomnomnom/qsreplace@latest
cat $name | grep -E "&|?" | qsreplace -a newval

# Check
#- ssti
#- sqli / nosqli
#- xss
#- ssrf






# js
mkdir -p js; cd js
cat $name | grep ".js" > js.txt # check sensitive data here
cat js.txt | xargs -P 10 -I {} wget {}

.
.
.


cd ..

# metadata
cat $name | grep -E ".pdf|.png|.jpeg|.jpg|.ico|fav" | check metadata


cat $name | grep "?" # check params
```

# Wordlists
```bash
# web fuzz
mkdir -p ~/wordlists
cd ~/wordlists
cp /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt ~/wordlists
cp /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-words.txt ~/wordlists
cp /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt ~/wordlists

cat raft* | sort -u > raft.txt
rm raft-*

## params
wget https://raw.githubusercontent.com/OWASP/AppSec-Browser-Bundle/refs/heads/master/utilities/wfuzz/wordlist/fuzzdb/attack-payloads/http-protocol/http-protocol-methods.txt -O ~/wordlists/http-protocol-methods.txt
```

# Fuzzing endpoint

### ffuf
Varios targets
```bash
# Several targets
ffuf -w hosts.txt:HOST -w paths.txt:PATH -u http://HOST/PATH -mc 200

# HTTP verbs
wget https://raw.githubusercontent.com/OWASP/AppSec-Browser-Bundle/refs/heads/master/utilities/wfuzz/wordlist/fuzzdb/attack-payloads/http-protocol/http-protocol-methods.txt -O ~/wordlists/http-protocol-methods.txt

echo "METHOD /FUZZ HTTP/1.1
Host: target.com
User-Agent: ffuf
Connection: close" > request.txt

ffuf -request request.txt -w ~/wordlists/http-protocol-methods.txt:METHOD -w paths.txt:FUZZ -input-cmd "sed s/METHOD/{METHOD}/" -mc 200

```

# Fuzzing parameters
```bash
wfuzz -c -t 20 -X POST --hc 404 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-small-words.txt -d "FUZZ=http://127.0.0.1" "http://10.10.110.17:8080/view_image"
wfuzz -c -t 20 --hw 67 -X GET --hc 404 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-small-words.txt "http://10.10.110.17:8080/view_image?FUZZ=http://127.0.0.1"
```


# Endpoint with WebArchive
```
domain=paypal.com
curl -s "https://web.archive.org/cdx/search/cdx?url=$domain/*" | tee results/$domain.archive.out

echo paypal.com | gau --threads 10 --o gau.txt | results/$domain.gau.out
```


# Extracting from HTML and JavaScript Files
- [ ] Need to have valids urls domains and subdomains for a target
## Subdomains
```bash
curl -s https://www.paypalobjects.com/pa/mi/paypal/latmconf.js | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u | grep paypal.com 
    api-m.paypal.com
    https://ddbm2.paypal.com
    safetyhub.paypal.com
    sandbox.paypal.com
    www.paypal.com
    www.sandbox.paypal.com
```
## Endpoints
```bash
curl -s https://www.paypalobjects.com/pa/mi/paypal/latmconf.js | grep -oh "\"\/[a-zA-Z0-9_/?=&]*\"" | sed -e 's/^"//' -e 's/"$//' | sort -u
```

## Automatic Analyzing JavaScript
#### 1. Collecting JavaScript Files
```bash
target="https://www.paypalobjects.com"
curl -s $target -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" | grep "\.js" | sort -u | httpx -silent -mc 200 -o paypal-js.txt

# mirror application with a deep of 1
wget -m $target -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -l 1

# get .js files
grep -iRoP '(?i)<script[^>]+src=["'\'']([^"'\'' >]+)' 

# get endpoints
grep -iRoh "\"\/[a-zA-Z0-9_/?=&]*\"" | sed -e 's/^"//' -e 's/"$//' | sort -u

# get several other resources
grep -iRoP '(?i)(href|src|action)\s*=\s*["'\'']([^"'\'' >]+)' | sort -u
```



# Uso de src_web custom script
```sh
sudo apt install nodejs npm -y
sudo npm install -g puppeteer
sudo npm install -g fs

target="https://www.tesla.com"

NODE_PATH=/usr/local/lib/node_modules node /home/kali/repos/WebVulns/00_Recon/scripts/src_web.js "$target"
```