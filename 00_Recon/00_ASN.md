# Annalysis
```
source ~/enum_venv/bin/activate
```

## From a Corportation to ASN listing
1. Identify a web of the corporation and get its IP address
```bash
# get IP
dig +short paypal.com

curl -s https://api.bgpview.io/search?query_term=paypal | jq | tee -a bgpview.out

curl -s "https://api.bgpview.io/ip/162.159.141.96" | jq | tee -a bgpview.out
```

With the name of the AS use amass to identify the IP range used
```bash
# amass
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

# nmap
nmap --script targets-asn --script-args targets-asn.asn=26444

# scan de ip ranges
nmap -sT -Pn -T2 -n --top-ports=10 -iL IPs_v4.txt -oA IPs_v4_topports10.txt -v --open
```

With the ASN's its easy get the range but we have it already with amass anyway, 
https://bgp.he.net/
```
# Obtener los rangos de IP's de un AS
whois -h whois.radb.net -- '-i origin AS33905' | grep -Eo "([0-9.]+){4}/[0-9]+"
```

2. Reverse IP lookup using rapiddns!
Check the custom script here: [rapiddns.sh](./scripts/rapiddns.sh)


With this are identified several domains and subdomains!

3. Manual Reverse IP lookup
```bash
git clone https://github.com/vortexau/dnsvalidator
cd dnsvalidator
pip install setuptools
python3 setup.py install

dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o resolvers.txt

# Now with the dns servers identified:
cat ASNs.txt| xargs -I {} prips {} >> ips_asn.txt

dig +short
```

El resultado de este proceso deberá ser un fichero con todos los dominios identificados y otro con todas las IP's identificadas como up.


## From a scope to identify infrastructure
To identify others ASN that may be interesting.
1. Get IP's for each domain identified
2. clean duplicates
```bash
cat ips.txt | xargs -I {} zsh -c 'sleep 1; curl -s "https://api.bgpview.io/ip/{}" | jq | tee -a bgpview.out'

# get ASN's
cat bgpview.out | grep -A1 "asn" | grep name | sort -u
```


Apply masscan to each ASN name discovered
```bash
cat bgpview.out | grep -A1 "asn" | grep name | sort -u | awk '{print $2}' FS=":" | tr -d ',' | sed 's/^/amass intel -org /g'
```




# Massive scan
**Fuzz**
```bash
for ipa in 98.13{6..9}.{0..255}.{0..255}; do
        wget -t 1 -T 5 http://${ipa}/phpinfo.php;
done &
```



# Diving Deeper
One a good scope is defined let's annalyze the subdomains to expand it even more!
