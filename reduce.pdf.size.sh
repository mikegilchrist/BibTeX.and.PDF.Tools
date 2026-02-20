#!/bin/bash
#
# Script to reduce the size of a PDF file.
# Supports quality levels: screen, ebook, printer OR numeric resolution (DPI).
# Flags:
#   -f  → Force rasterization (converts vector content to images)
#   -s  → Silent mode (suppress all normal output)
#
# Author: Mike Gilchrist with ChatGPT engine Bishop Bash
# Version: 1.7
# Date: 2025-02-27

FORCE_RASTER=false
SILENT=false

# Parse flags
while getopts ":fs" opt; do
  case $opt in
    f) FORCE_RASTER=true ;;
    s) SILENT=true ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# Validate remaining arguments
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 [-f] [-s] <input.pdf> [screen|ebook|printer|resolution]"
    exit 1
fi

INFILE="$1"
OUTFILE="${INFILE/.pdf/-reduced.pdf}"

# Function to print only when not in silent mode
vprint() {
    $SILENT || echo "$@"
}

# Validate input file
if [ ! -f "$INFILE" ]; then
    echo "Error: Input file '$INFILE' not found."
    exit 1
fi

# Default quality/resolution
QUALITY_OPTION="-dPDFSETTINGS=/ebook"
RESOLUTION=150

# If second argument is provided
if [ "$#" -eq 2 ]; then
    SETTING="$2"
    if [[ "$SETTING" == "screen" || "$SETTING" == "ebook" || "$SETTING" == "printer" ]]; then
        QUALITY_OPTION="-dPDFSETTINGS=/$SETTING"
        vprint "Using predefined quality level: $SETTING"
    elif [[ "$SETTING" =~ ^[0-9]+$ ]]; then
        RESOLUTION="$SETTING"
        QUALITY_OPTION="-dDownsampleColorImages=true -dColorImageDownsampleType=/Average -dColorImageResolution=$RESOLUTION \
                        -dDownsampleGrayImages=true -dGrayImageDownsampleType=/Average -dGrayImageResolution=$RESOLUTION \
                        -dDownsampleMonoImages=true -dMonoImageDownsampleType=/Subsample -dMonoImageResolution=$RESOLUTION"
        vprint "Using custom resolution: $RESOLUTION DPI"
    else
        echo "Error: Second argument must be one of: screen, ebook, printer, or a numeric resolution."
        exit 1
    fi
else
    vprint "No resolution specified. Using default: ebook"
fi

vprint "Input file: $INFILE"
vprint "Output will be saved to: $OUTFILE"
$FORCE_RASTER && vprint "⚠️  Force rasterization enabled — pages will be rendered as low-res images."

# Get original file size in KB (with commas, no decimals)
original_size_kb=$(du -k "$INFILE" | cut -f1 | awk '{printf "%'\''d", $1}')

# Run Ghostscript
if [ "$FORCE_RASTER" = true ]; then
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        -r$RESOLUTION \
        -dFILTERVECTOR=true \
        -dDetectDuplicateImages=true \
        -dColorImageDownsampleType=/Average -dColorImageResolution=$RESOLUTION \
        -dGrayImageDownsampleType=/Average -dGrayImageResolution=$RESOLUTION \
        -dMonoImageDownsampleType=/Subsample -dMonoImageResolution=$RESOLUTION \
        -dDownsampleColorImages=true -dDownsampleGrayImages=true -dDownsampleMonoImages=true \
        -dNOPAUSE -dQUIET -dBATCH \
        -sOutputFile="$OUTFILE" "$INFILE"
else
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        $QUALITY_OPTION \
        -dNOPAUSE -dQUIET -dBATCH \
        -sOutputFile="$OUTFILE" "$INFILE"
fi

# Check success
if [ -f "$OUTFILE" ]; then
    reduced_size_kb=$(du -k "$OUTFILE" | cut -f1 | awk '{printf "%'\''d", $1}')
    vprint "✅ PDF compression complete!"
    vprint "📄 Original size: $original_size_kb KB"
    vprint "📉 Reduced size : $reduced_size_kb KB"
    vprint "📁 Output saved as: $OUTFILE"
else
    echo "❌ Failed to create output file."
    exit 1
fi
