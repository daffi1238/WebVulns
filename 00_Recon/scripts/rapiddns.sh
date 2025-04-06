#!/bin/zsh

# Comprobar que se pasa un argumento
if [[ $# -ne 1 ]]; then
    echo "❌ Uso: $0 <archivo_de_entrada>"
    exit 1
fi

INPUT_FILE="$1"

# Verificar si el archivo existe
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ El archivo '$INPUT_FILE' no existe."
    exit 2
fi

mkdir -p rapiddns

while IFS= read -r line; do
    echo "🔍 Processing IP: $line"
    
    # Obtener la primera página
    curl -s "https://rapiddns.io/sameip/$line" > "rapiddns/rapiddns_page_1.out"
    
    # Extraer el número total de resultados
    nTotal=$(grep -oP 'Total.*' rapiddns/rapiddns_page_1.out | awk -F";" '{print $2}' | grep -oP ">.*?</" | tr -d '<>/')
    
    # Calcular la cantidad de páginas
    nPages=$(( (nTotal / 100) + 1 ))
    echo "📄 Total pages: $nPages"
    
    # Descargar páginas adicionales si existen
    for ((page=2; page<=nPages; page++)); do
        echo "➡️ Downloading page $page..."
        curl -s "https://rapiddns.io/sameip/$line?page=$page" > "rapiddns/rapiddns_page_${page}.out"
        sleep 1  # Pausa para evitar bloqueo
    done

    # Extraer el número AS para nombrar el archivo
    IPRange=$(echo $line | awk -F "/" '{print $1 ".txt"}')
    
    # Procesar los resultados y extraer los datos relevantes
    cat rapiddns/rapiddns* | grep -E "scope|td" | grep -A1 scope | grep td | tr -d "</>" | \
        xargs | tr " " "\n" | sed 's/^td//g' | sed 's/td$//g' | tee "$IPRange"
    
    echo "✅ Processing of $line completed."

    # Limpiar archivos temporales
    rm -rf rapiddns/rapiddns*
    sleep 2  # Pausa entre IPs para evitar bloqueo
done < "$INPUT_FILE"
