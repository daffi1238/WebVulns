https://medium.com/@qaafqasim/exploring-wordpress-juicy-endpoints-a-guide-for-bug-bounty-hunters-6a09437fb621



```
echo "/wp-admin.php
/wp-config.php
/wp-content/uploads
/wp-load
/wp-signup.php
/wp-json
/wp-includes [directory]
/index.php
/wp-login.php
/wp-links-opml.php
/wp-activate.php
/wp-blog-header.php
/wp-cron.php
/wp-links.php
/wp-mail.php
/xmlrpc.php
/wp-settings.php
/wp-trackback.php
/wp-signup.php
/wp-json/wp/v2/users
/wp-json/wp/v2/plugins
/wp-json/wp/v2/themes
/wp-json/wp/v2/comments" > wordpress_bb.txt

wget https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Discovery/Web-Content/CMS/wordpress.fuzz.txt
wget https://github.com/danielmiessler/SecLists/blob/master/Discovery/Web-Content/CMS/wp-plugins.fuzz.txt
wget https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Discovery/Web-Content/CMS/wp-themes.fuzz.txt

cat *.txt | sort -u > wordpress.txt
```

```
/wp-admin.php
/wp-config.php
/wp-content/uploads
/wp-load
/wp-signup.php
/wp-json
/wp-includes [directory]
/index.php
/wp-login.php
/wp-links-opml.php
/wp-activate.php
/wp-blog-header.php
/wp-cron.php
/wp-links.php
/wp-mail.php
/xmlrpc.php
/wp-settings.php
/wp-trackback.php
/wp-signup.php
/wp-json/wp/v2/users
/wp-json/wp/v2/plugins
/wp-json/wp/v2/themes
/wp-json/wp/v2/comments
```