https://github.com/six2dez/pentest-book/blob/master/enumeration/web/crawl-fuzz.md


Pendiente de analizar:
https://github.com/ffuf/ffuf/wiki/Scraper


TODO:

- Uso de scrapers
https://github.com/ffuf/ffuf/wiki/Scraper
    -Extraer títulos
    - extraer url's
    - grepear por "token|pass|key|api"

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

# ffuf
Varios targets
```
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