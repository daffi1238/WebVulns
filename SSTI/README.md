https://pentestbook.six2dez.com/enumeration/web/ssti

Some of the famous template engines:
- Smarty (PHP)
- Blade (PHP, used with Laravel)
- Pug (formerly Jade, JavaScript)
- Liquid (Ruby, used by Shopify)
- Freemarker (Java)
- Twig (PHP, used with Symfony)
- Mustache (cross-platform)
- Jinja2 (Python)
- Mako(Python)


# Identify Template Injection
```bash
# payload
${{<%[%'"}}%\
```
This may return an error message.

# Context

## Plaintext Context
```bash
https://vulnerablebank.com/?username=Hello{{name}}

>Hello rafay
```
In this context "rafay" may be treated as plain text.

Less severe but it's possible get an XSS from this.

## Code Context
```
{{7 * 7}}
{{48 / 6}}
```

```bash
wfuzz -w diccionario.txt -u "http://example.com/login?user=FUZZ" --matcher regex:"Welcome\s+back"
```