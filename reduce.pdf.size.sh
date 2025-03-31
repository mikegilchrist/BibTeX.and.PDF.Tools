#!/bin/bash
#
# Script to reduce the size of a PDF file.
# Supports predefined quality levels or custom numeric resolution.
#
# Expects 1 or 2 arguments:
#   ./script.sh <FILE> [screen/ebook/printer or resolution]
#
# Author: Mike Gilchrist with ChatGPT engine Bishop Bash
# Version: 1.4
# Date: 2025-02-27

# Validate the number of arguments
if [ "$#" -lt 1 ]; then
    echo "Error in $0: Only use one or two arguments: <FILE> [screen/ebook/printer or resolution]";
    exit 1;
fi

if [ "$#" -gt 2 ]; then
    echo "Error in $0: Only use one or two arguments: <FILE> [screen/ebook/printer or resolution] (you may need to put the argument in quotes).";
    exit 1;
fi

# Set input file and output file name
INFILE="$1"
OUTFILE="${INFILE/.pdf/-reduced.pdf}"

# Validate that the input file exists
if [ ! -f "$INFILE" ]; then
    echo "Error: Input file '$INFILE' not found."
    exit 1
fi

# Set default to /ebook if no second argument is provided
QUALITY_OPTION="-dPDFSETTINGS=/ebook"
RESOLUTION=150  # Default resolution (used only if number is provided)

# Check if a second argument is provided
if [ "$#" -eq 2 ]; then
    RESOLUTIONLEVEL="$2"

    # Check for predefined quality levels
    if [[ "$RESOLUTIONLEVEL" == "screen" || "$RESOLUTIONLEVEL" == "ebook" || "$RESOLUTIONLEVEL" == "printer" ]]; then
        # Use predefined PDF settings
        QUALITY_OPTION="-dPDFSETTINGS=/$RESOLUTIONLEVEL"
        echo "Using predefined quality level: $RESOLUTIONLEVEL"
    elif [[ "$RESOLUTIONLEVEL" =~ ^[0-9]+$ ]]; then
        # Use custom numeric resolution
        RESOLUTION="$RESOLUTIONLEVEL"
        QUALITY_OPTION="-dDownsampleColorImages=true -dDownsampleGrayImages=true -dDownsampleMonoImages=true \
                        -dColorImageResolution=$RESOLUTION -dGrayImageResolution=$RESOLUTION -dMonoImageResolution=$RESOLUTION"
        echo "Using custom resolution: $RESOLUTION DPI"
    else
        echo "Error: Invalid quality level or resolution provided."
        echo "Valid options: screen, ebook, printer, or a numeric resolution (e.g., 100, 200, 300)."
        exit 1
    fi
else
    echo "No resolution specified. Using default: ebook"
fi

echo "Reducing size of $INFILE, outputting as $OUTFILE"

# Run Ghostscript with appropriate settings
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 $QUALITY_OPTION \
    -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$OUTFILE" "$INFILE"

# Check if the output file was created successfully
if [ -f "$OUTFILE" ]; then
    echo "PDF size reduced successfully! Output saved as: $OUTFILE"
else
    echo "Error: Failed to create output file."
    exit 1
fi
