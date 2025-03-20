# From a Corportation to ASN listing
1. Identify a web of the corporation and get its IP address
```bash
ping -c 1 tesla.com | gripo | sort -u

curl https://api.hackertarget.com/aslookup/?q=2.18.53.207
curl https://api.hackertarget.com/aslookup/?q=2.18.53.207 | awk '{print $4}' FS="," | tr -d '"'
```
With the name of the AS use amass to identify the IP range used
```bash
amass intel -org "AKAMAI-AMS"
  ASN: 43639 - AKAMAI-AMS2
          2.16.55.0/24
          2a02:26f0:80::/48
  ASN: 33905 - AS33905 - Akamai International B.V.
          2.18.48.0/21
          23.1.35.0/24
          23.1.99.0/24
          23.1.106.0/24
          23.7.244.0/24
          23.40.100.0/24

```

With the ASN's its easy get the range but we have it already with amass anyway, 
https://bgp.he.net/
```
# Obtener los rangos de IP's de un AS
whois -h whois.radb.net -- '-i origin AS33905' | grep -Eo "([0-9.]+){4}/[0-9]+"
```

# From a scope to identify infrastructure
1. Get IP's for each domain identified
2. clean duplicates
```bash
cat ips.txt | xargs -I {} zsh -c 'sleep 1; curl -s "https://api.bgpview.io/ip/{}" | jq | tee bgpview.out'
```
