#!/bin/bash
#
# Script to help organize repositories.
# Copies a file to a (presumably) broken target of the symlink given
#
# Expects 2 argument

if [ "$#" -lt 1 ];
then
    echo "Error in $0:  Only use one or two arguments: <FILE> <screen/ebook/printer-opt>";
    exit 1;
fi

if [ "$#" -gt 2 ];
then
    echo "Error in $0:  Only use one or two arguments: <FILE> <screen/ebook/printer-opt>";
    exit 1;
fi

if [ "$#" -eq 2 ];
then
   RESOLUTIONLEVEL="/$2"
else
    # Set resolution could be (lowest) /screen, /ebook, /printer (highest resolution)
    RESOLUTIONLEVEL="/screen"
fi


echo $RESOLUTIONLEVEL

INFILE="$1";
OUTFILE="${INFILE/.pdf/-reduced.pdf}"

echo "Reducing size of $INFILE, outputing as $OUTFILE"

gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS="$RESOLUTIONLEVEL" -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$OUTFILE" "$INFILE"
