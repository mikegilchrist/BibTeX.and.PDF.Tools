#!/bin/bash
#
# Script to display the size of each page in a PDF file.
# Splits the PDF into individual pages and reports the size in KB.
#
# Usage:
#   ./pdf_page_sizes.sh <input.pdf>
#
# Author: Mike Gilchrist with ChatGPT engine Bishop Bash
# Version: 1.0
# Date: 2025-02-27

# Validate the number of arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input.pdf>"
    exit 1
fi

# Set input file and validate its existence
INPUT_PDF="$1"

if [ ! -f "$INPUT_PDF" ]; then
    echo "Error: Input file '$INPUT_PDF' not found."
    exit 1
fi

# Create a temporary directory to store individual pages
TEMP_DIR=$(mktemp -d)

# Split PDF into individual pages
pdftk "$INPUT_PDF" burst output "$TEMP_DIR/page_%04d.pdf" 2>/dev/null

# Check if splitting was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to split PDF. Make sure pdftk is installed."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Get total number of pages
TOTAL_PAGES=$(ls "$TEMP_DIR" | wc -l)

# Check if there are any pages generated
if [ "$TOTAL_PAGES" -eq 0 ]; then
    echo "Error: No pages generated from PDF. Aborting."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Print header
echo -e "Page Size (KB)\tPage #"

# Loop through each page and calculate its size
PAGE_NUM=1
for PAGE in $(ls "$TEMP_DIR" | sort); do
    PAGE_SIZE=$(du -k "$TEMP_DIR/$PAGE" | cut -f1)
    echo -e "$PAGE_SIZE\t$PAGE_NUM"
    PAGE_NUM=$((PAGE_NUM + 1))
done

# Cleanup temporary directory
rm -rf "$TEMP_DIR"

echo "Done! Page size report generated successfully."
