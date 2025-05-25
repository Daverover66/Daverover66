# Not executable as python_script in HA — used for shell_command or automation
import csv
import json
from collections import OrderedDict

log_path = "/config/nmap_device_log.csv"
output_path = "/config/www/nmap_data.json"

entries = {}

with open(log_path, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        ip = row["ip"]
        if ip:  # Use only valid entries
            entries[ip] = row

# Sort by IP numerically
sorted_entries = OrderedDict(sorted(entries.items(), key=lambda x: list(map(int, x[0].split(".")))))

# Output as JSON
with open(output_path, "w") as jsonfile:
    json.dump(list(sorted_entries.values()), jsonfile, indent=2)
