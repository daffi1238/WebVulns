# Entrar al entorno virtual
source ~/enum_venv/bin/activate

# Crear estructura de carpetas
mkdir -p ASN/{results,scripts,tmp}
cd ASN

ASN_name="ECI-AS"
main_web="elcorteingles.es"
main_ip=$(dig +short $main_web)


# BGPView búsqueda inicial
curl -s "https://api.bgpview.io/search?query_term=$ASN_name" | jq | tee -a results/bgpview.out

# Suponiendo IP obtenida como ejemplo: 162.159.141.96
curl -s "https://api.bgpview.io/ip/$main_ip" | jq | tee -a results/bgpview.out


cat results/bgpview.out | jq | grep -E '"asn"|"name"' | awk -F: '{gsub(/[",]/, "", $2); print $2}' | paste - - | sort -u | tee ASN.txt



# Paso 2: Obtener rangos de IP con amass (modificar nombre de organización si cambia)
cat ASN.txt | xargs -I {} amass intel -org "$ASN_name" | tee -a results/amass_org.out
cat ASN.txt | awk '{print $1}' | xargs -I {} nmap --script targets-asn --script-args targets-asn.asn={} | tee -a results/nmap_asn.out
cat ASN.txt | xargs -I {} zsh -c 'whois -h whois.radb.net -- '-i origin AS{}' | grep -Eo "([0-9.]+){4}/[0-9]+"' | tee -a results/whois.radb.out

# Obtener rangos de IP con whois para un ASN específico
awk '{print $1}' ASN.txt | while read asn; do
    whois -h whois.radb.net -- "-i origin AS$asn" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+'
done | tee -a results/whois.radb.out



# Extraer rangos por fichero:
grep -HoP '\d{1,3}(\.\d{1,3}){3}/\d{1,2}|.*::.*' results/*.out | sed 's/[[:blank:]]//g' | sort -u | tee results/IPs_range.txt

# Extraer rangos IPv4 de la salida
cat results/*.out | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}' | sed 's/[[:blank:]]//g' | sort -u | tee results/IPsv4_range.txt
cat results/*.out | grep -oP '.*::.*' | sed 's/[[:blank:]]//g' | sort -u | tee results/IPsv6_range.txt

```python
python3 -c "                    
import ipaddress

def collapse(file):
    with open(file) as f:
        nets = [ipaddress.ip_network(line.strip(), strict=False) for line in f if line.strip()]
        return sorted(ipaddress.collapse_addresses(nets), key=lambda n: int(n.network_address))

ip4 = collapse('results/IPsv4_range.txt')
ip6 = collapse('results/IPsv6_range.txt')

for net in ip4 + ip6:
    print(net)
" > results/IPs_range_merged.txt
```


# Escaneo de top 10 puertos en IPs
nmap -sT -Pn -sV -T2 -n --top-ports=10 -iL results/IPs_range_merged.txt -oN results/Nmap_top10_ASN.nmap --open



# Paso 3: Reverse IP lookup usando script personalizado
wget -P scripts https://raw.githubusercontent.com/daffi1238/WebVulns/refs/heads/main/00_Recon/rapiddns.sh
bash scripts/rapiddns.sh results/IPs_range_merged.txt



--> Por aqui voy

# Paso 4: Manual reverse DNS lookup con dnsvalidator
git clone https://github.com/vortexau/dnsvalidator
cd dnsvalidator
pip install setuptools
python3 setup.py install
cd ..

dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o tmp/resolvers.txt

# Obtener IPs desde rangos de ASNs
cat tmp/IPs_whois.txt | xargs -I {} prips {} >> tmp/ips_asn.txt

# Paso 5: Extraer dominios con dig manual
while read ip; do dig -x $ip +short; done < tmp/ips_asn.txt >> results/reverse_manual_domains.txt

# Consolidar dominios
cat results/reverse_domains.txt results/reverse_manual_domains.txt | sort -u > results/all_domains.txt

# Obtener IPs de cada dominio
cat results/all_domains.txt | xargs -I {} dig +short {} | grep -Eo "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)" | sort -u > results/all_ips.txt

# Obtener info de ASN de cada IP
cat results/all_ips.txt | xargs -I {} zsh -c 'sleep 1; curl -s "https://api.bgpview.io/ip/{}" | jq | tee -a results/bgpview_full.out'

# Obtener nombres de ASN únicos
cat results/bgpview_full.out | grep -A1 "asn" | grep name | sort -u > results/asn_names.txt

# Aplicar amass a cada ASN name descubierto
cat results/asn_names.txt | awk -F':' '{print $2}' | tr -d '",' | sed 's/^/amass intel -org /g' > tmp/amass_by_asn.sh
bash tmp/amass_by_asn.sh | tee -a results/amass_expanded.out

# Paso 6: Fuzzing masivo (modificar rango si se desea limitar)
for ipa in 98.13{6..9}.{0..255}.{0..255}; do
    wget -t 1 -T 5 http://${ipa}/phpinfo.php;
done &

# RESULTADOS FINALES
# - Todos los dominios identificados: results/all_domains.txt
# - Todas las IPs activas: results/all_ips.txt
