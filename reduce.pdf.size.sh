#!/bin/bash
#
# Script to help organize repositories.
# Copies a file to a (presumably) broken target of the symlink given
#
# Expects 2 argument

if [ "$#" -ne 1 ];
then
    echo "Error in $0:  Need 1 argument: <FILE>";
    exit 1;
fi

# Set resolution could be (lowest) /screen, /ebook, /printer (highest resolution)
RESOLUTIONLEVEL="/screen"

INFILE="$1";
OUTFILE="${INFILE/.pdf/-reduced.pdf}"

echo "Reducing size of $INFILE, outputing as $OUTFILE"

gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS="$RESOLUTIONLEVEL" -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$OUTFILE" "$INFILE"
