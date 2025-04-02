#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: $0 <URL>"
    exit 1
fi

URL="$1"

# Obtener las cabeceras HTTP
HEADERS=$(curl -s -I -L "$URL")
echo "curl -s -I -L "$URL"";echo

echo "--- Cabeceras de respuesta ---"
echo "$HEADERS"
echo "----------------------------";echo

declare -A REQUIRED_HEADERS=(
    ["content-security-policy"]="CSP"
    ["strict-transport-security"]="HSTS"
    ["cache-control"]="Cache-Control"
    ["pragma"]="Pragma"
    ["x-content-type-options"]="X-Content-Type-Options"
    ["x-xss-protection"]="XSS-Protection"
)

# Comprobar si X-Frame-Options debe revisarse
if ! echo "$HEADERS" | grep -i "content-security-policy" &>/dev/null; then
    REQUIRED_HEADERS["x-frame-options"]="X-Frame-Options"
fi

MISSING=()

for HEADER in "${!REQUIRED_HEADERS[@]}"; do
    if ! echo "$HEADERS" | grep -i "$HEADER" &>/dev/null; then
        MISSING+=("${REQUIRED_HEADERS[$HEADER]}")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo -e "\e[31mFaltan las siguientes cabeceras:\e[0m"
    for H in "${MISSING[@]}"; do
        echo -e "\e[31m  - $H\e[0m"
    done
else
    echo -e "\e[32mTodas las cabeceras están presentes.\e[0m"
fi
