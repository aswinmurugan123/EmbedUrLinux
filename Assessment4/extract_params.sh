#!/bin/bash

# Check argument count
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="output.txt"

# Clear output file before writing
> "$OUTPUT_FILE"

# Read file line by line
while IFS= read -r line
do
    if echo "$line" | grep -q '"frame.time":'; then
        echo "$line" | sed 's/^[[:space:]]*//' >> "$OUTPUT_FILE"
    elif echo "$line" | grep -q '"wlan.fc.type":'; then
        echo "$line" | sed 's/^[[:space:]]*//' >> "$OUTPUT_FILE"
    elif echo "$line" | grep -q '"wlan.fc.subtype":'; then
        echo "$line" | sed 's/^[[:space:]]*//' >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"

echo "Extraction complete. Output written to $OUTPUT_FILE"
