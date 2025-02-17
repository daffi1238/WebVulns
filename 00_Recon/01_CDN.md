# Real IP behing Reverse Proxy?
https://medium.com/@R00tendo/get-real-ip-behind-a-reverse-proxy-3da75329f3b4

- Technique 1. Subdomains
    - DNSdumpster 
    - Censys Search (https://search.censys.io/)
    - Sublist3r
- Technique 2. SSL Certificates
    - https://search.censys.io/
- Technique 3. DNS History
    - SecurityTrails (https://securitytrails.com)
    - Complete DNS (https://completedns.com/dns-history/)
    - More sites here:https://woorkup.com/view-dns-history-free/


## Metodología
1. Resuelve todos los subdominios obtenidos y obtenemos su IP
2. Revisamos cuales de las IP's se encuentran en un CDN y cuales no
3. Revisamos las IP's que no están protegidas por CDN's y revisamos sus AS's
4. Revisamos los rangos de IP's e intentamos resolver cada IP con los distintos hosts de los equipos tras CDN's
```bash
curl -k https://1.2.3.4 -H "Host: target.com"
```

#### Get AS
- [ ] Check which AS belong the IP (or IPs)
```bash
curl -s https://api.hackertarget.com/aslookup/?q=1.2.3.4
```
    - [ ] CDP?
    - [ ] AS of the corp?
    - [ ] Cloud service?
