#!/bin/bash

# ------------------------------
# file_analyzer.sh
# ------------------------------

ERROR_LOG="errors.log"

# ------------------------------
# Function: log_error
# Logs error to file and displays on terminal
# ------------------------------
log_error() {
    echo "[ERROR] $1" | tee -a "$ERROR_LOG" >&2
}

# ------------------------------
# Help Menu (Here Document)
# ------------------------------
show_help() {
cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -k <keyword>     Keyword to search
  -f <file>        File to search directly
  --help           Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO

Special Parameters Used:
  Script Name: $0
EOF
}

# ------------------------------
# Recursive Function
# Searches directory and subdirectories
# ------------------------------
search_directory_recursive() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            search_directory_recursive "$item" "$keyword"
        elif [ -f "$item" ]; then
            if grep -q "$keyword" "$item"; then
                echo "Match found in: $item"
            fi
        fi
    done
}

# ------------------------------
# Regex Validation
# ------------------------------
validate_keyword() {
    if [[ -z "$1" ]]; then
        log_error "Keyword cannot be empty."
        exit 1
    fi

    # Allow alphanumeric + underscore only
    if [[ ! "$1" =~ ^[a-zA-Z0-9_]+$ ]]; then
        log_error "Invalid keyword format. Only alphanumeric and underscore allowed."
        exit 1
    fi
}

validate_file() {
    if [[ ! -f "$1" ]]; then
        log_error "File '$1' does not exist."
        exit 1
    fi
}

validate_directory() {
    if [[ ! -d "$1" ]]; then
        log_error "Directory '$1' does not exist."
        exit 1
    fi
}

# ------------------------------
# Argument Parsing using getopts
# ------------------------------
if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

while getopts ":d:k:f:" opt; do
    case $opt in
        d) DIRECTORY="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        \?) 
            log_error "Invalid option: -$OPTARG"
            show_help
            exit 1
            ;;
        :)
            log_error "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

# ------------------------------
# Special Parameter Usage
# ------------------------------
if [[ $# -eq 0 ]]; then
    log_error "No arguments provided."
    show_help
    exit 1
fi

echo "Script Name: $0"
echo "Total Arguments: $#"
echo "All Arguments: $@"

# ------------------------------
# Execution Logic
# ------------------------------
validate_keyword "$KEYWORD"

if [[ -n "$DIRECTORY" ]]; then
    validate_directory "$DIRECTORY"
    echo "Searching recursively in directory: $DIRECTORY"
    search_directory_recursive "$DIRECTORY" "$KEYWORD"
    echo "Exit Status: $?"
elif [[ -n "$FILE" ]]; then
    validate_file "$FILE"
    echo "Searching in file: $FILE"

    # Here String usage
    while IFS= read -r line; do
        if grep -q "$KEYWORD" <<< "$line"; then
            echo "Match: $line"
        fi
    done < "$FILE"

    echo "Exit Status: $?"
else
    log_error "Either -d <directory> or -f <file> must be provided."
    show_help
    exit 1
fi

