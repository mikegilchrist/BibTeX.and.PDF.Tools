#!/bin/bash
# Script to get information on most recently downloaded .pdf file in /tmp 
# to help with using move.and.link.pdf.sh
#
# TODO: integrate with move.and.link.pdf.sh by adding line numbers to current output and then query user which line numbers correspond to AUTHOR, TITLE, YEAR, and JOURNAL
# usage: lines

if [ "$#" -gt 1 ]; then
    echo "Error in $0:  One optional argument expected"
    exit 1
fi

# Get command invoked
command="$0";

#strip off leading information
command=${command##*/}


#echo "command argument: $command"

INFILE="$(ls -tr /tmp/*.{pdf,PDF}|tail -1)"
printf "Processing file: $INFILE\n";

PDFTITLE="$(pdfinfo $INFILE | grep \"Title:\")";
if [ ${#PDFTITLE} -eq 0 ];  then PDFTITLE="Title Not Given"; 
fi
PDFYEAR="$(pdfinfo $INFILE | grep CreationDate: | grep -ow [1-2][0-9][0-9][0-9])";
if [ ${#PDFYEAR} -eq 0 ];  then PDFYEAR="CreationDate: Not Given"; 
fi

# sed command replaces multiple empty lines with just one.
less "$INFILE" | sed '/^$/N;/^\n$/D' | head -20 ;

printf "Information from pdfinfo\n $PDFYEAR $PDFTITLE\n";


