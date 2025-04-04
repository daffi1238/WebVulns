mkdir rapiddns
#!/bin/zsh

INPUT_FILE="ASNs.txt"

while IFS= read -r line; do
    echo "🔍 Processing IP: $line"
    
    # Retrieve the first page
    curl -s "https://rapiddns.io/sameip/$line?full=1#result" > "rapiddns_page_1.out"
    
    # Extract the total number of results
    nTotal=$(grep -oP 'Total.*' rapiddns_page_1.out | awk '{print $2}' FS=";" | grep -oP ">.*?</" | tr -d '<>/')
    
    # Calculate the number of pages
    nPages=$((($nTotal / 100) + 1))
    echo "📄 Total pages: $nPages"
    
    # Iterate over additional pages if they exist
    for ((page=2; page<=nPages; page++)); do
        echo "➡️ Downloading page $page..."
        curl -s "https://rapiddns.io/sameip/$line?page=$page" > "rapiddns_page_${page}.out"
        sleep 1  # Avoid getting blocked due to excessive requests
    done

    # Extract the Autonomous System (AS) number from the IP
    AS=$(echo $line | awk '{print $1}' FS="/")

    # Process and extract relevant data from the downloaded pages
    cat rapiddns* | grep -E "scope|td" | grep -A1 scope | grep td | tr -d "</>" | xargs | tr " " "\n" | sed 's/^td//g' | sed 's/td$//g' | tee $AS
    echo "✅ Processing of $line completed."

    # Remove temporary files
    rm -rf rapiddns*
    sleep 2  # Short pause between IPs to avoid blocking
done < "$INPUT_FILE"