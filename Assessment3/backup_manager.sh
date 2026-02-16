#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 \"<source_directory>\" \"<backup_directory>\" \"<file_extension>\""
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"

# Validate source directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi



if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create backup directory."
        exit 1
    fi
fi



shopt -s nullglob   # Prevent literal glob if no match

FILES=("$SOURCE_DIR"/*"$EXTENSION")

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No files with extension $EXTENSION found in $SOURCE_DIR."
    exit 0
fi



export BACKUP_COUNT=0
TOTAL_SIZE=0
TOTAL_PROCESSED=0

echo "Files to be backed up:"
echo "-----------------------"

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file")
        echo "File: $(basename "$file") | Size: $size bytes"
        ((TOTAL_PROCESSED++))
    fi
done

echo ""


for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        destination="$BACKUP_DIR/$filename"

        if [ -f "$destination" ]; then
            if [ "$file" -nt "$destination" ]; then
                cp "$file" "$destination"
                size=$(stat -c%s "$file")
                ((TOTAL_SIZE+=size))
                ((BACKUP_COUNT++))
            fi
        else
            cp "$file" "$destination"
            size=$(stat -c%s "$file")
            ((TOTAL_SIZE+=size))
            ((BACKUP_COUNT++))
        fi
    fi
done

# -------- 6. Output Report --------

REPORT_FILE="$BACKUP_DIR/backup_report.log"

{
echo "========== Backup Summary =========="
echo "Date: $(date)"
echo "Source Directory: $SOURCE_DIR"
echo "Backup Directory: $BACKUP_DIR"
echo "File Extension Filter: $EXTENSION"
echo ""
echo "Total Files Processed: $TOTAL_PROCESSED"
echo "Total Files Backed Up: $BACKUP_COUNT"
echo "Total Size Backed Up: $TOTAL_SIZE bytes"
echo "===================================="
} > "$REPORT_FILE"

echo "Backup completed."
echo "Summary report saved at: $REPORT_FILE"
