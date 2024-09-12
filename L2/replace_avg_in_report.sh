#!/bin/bash
set -x
# Define file paths
avg_file="avg.csv"
report_file="L2_CI_Consolidate_report.txt"
temp_file="L2_CI_Consolidate_temp_report.txt"
sed -i 's/\.0$//' avg.csv
sed -i 's/DT_INFRA/INFRA/' avg.csv
sed -i 's/EMS/NEMS/' avg.csv
declare -A avg_values

# Read average values from avg.csv into an associative array
while IFS=, read -r key value; do
    key=$(echo "$key" | xargs)  # Remove any leading/trailing spaces
    value=$(echo "$value" | xargs)  # Remove any leading/trailing spaces
    avg_values["$key"]=$value
done < "$avg_file"

# Process the report file and insert the value at the 5th position if key is found in avg_values
while IFS=, read -r key val1 val2 val3 val4 rest; do
    key=$(echo "$key" | xargs)  # Remove any leading/trailing spaces
    if [[ -n ${avg_values["$key"]} ]]; then
        val5=${avg_values["$key"]}
    else
        val5=""
    fi
    # Use echo with IFS to properly format the output
    if [[ -z "$rest" ]]; then
        echo "$key, $val1, $val2, $val3, $val4, $val5" >> "$temp_file"
    else
        echo "$key, $val1, $val2, $val3, $val4, $val5, $rest" >> "$temp_file"
    fi
done < "$report_file"

# Replace the old report file with the updated one
mv "$temp_file" "$report_file"

echo "Values updated successfully in $report_file"

