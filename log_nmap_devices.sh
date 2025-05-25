#!/bin/bash

output="/config/nmap_device_log.csv"
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Add header if file doesn't exist
if [ ! -f "$output" ]; then
    echo "timestamp,ip,mac,hostname" > "$output"
fi

# Load MAC -> name mappings from CSV
declare -A mac_names
mapfile -t lines < /config/mac_names.csv
for line in "${lines[@]:1}"; do
    IFS=',' read -r mac name <<< "$line"
    mac_names["$mac"]="$name"
done 

# Run the scan and parse each line
nmap -sn -R 192.168.0.1-254 | while read -r line; do
    # Match IP and hostname
    if [[ "$line" =~ ^Nmap\ scan\ report\ for\ (.*)\ \((.*)\)$ ]]; then
        hostname="${BASH_REMATCH[1]}"
        ip="${BASH_REMATCH[2]}"
    elif [[ "$line" =~ ^Nmap\ scan\ report\ for\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
        ip="${BASH_REMATCH[1]}"
        hostname="UNKNOWN"
    fi
    
    # Match MAC address
    if [[ "$line" =~ ^MAC\ Address:\ ([0-9A-F:]{17})\ \((.*)\)$ ]]; then
        mac="${BASH_REMATCH[1]}"
    
        # Use MAC-to-name mapping if hostname is UNKNOWN
        if [ "$hostname" == "UNKNOWN" ] && [ -n "${mac_names[$mac]}" ]; then
            hostname="${mac_names[$mac]}"
        fi
    
        echo "$timestamp,$ip,$mac,$hostname" >> "$output"
        ip=""
        hostname=""
        mac=""
    fi

done
