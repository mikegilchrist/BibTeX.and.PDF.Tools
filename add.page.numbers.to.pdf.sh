#!/bin/bash
# Add page numbers to a file
# 

## FIrst error check
if [[ "$#" -ne 1 ]]; then
    echo "Error in $0:  One argument expected: <FILE.pdf>";
    exit 1;
fi

FILE="$1";
TMPFILE="tmp-$(basename $FILE)"
NEWFILE="${FILE/.pdf/-numbered.pdf}"

## Taken from https://anaraven.bitbucket.io/blog/2018/numbering-pages-of-a-pdf.html and comment at bottom

### get page count ############################################
pageCount=`pdftk $1 dump_data | grep -i "numberofpages" | cut -d' ' -f2`
### THE MAGIC #################################################
# enscript -L1 -b'||Page $% of $=' # top of page and ugly
# relies on file ~/.enscript/fancy.hdr existing
# Based on simple2.hdr file at: https://askubuntu.com/a/544620/241361
# Replacing  --footer '||$%' with  --footer '|$%|' gets the number centered
enscript -F Times-Roman10 --fancy-header=fancy -L1 -b '||' --footer '|$%|' -o- < <(for i in $(seq 1 $pageCount); do echo; done) | ps2pdf - | pdftk $1 multistamp - output $NEWFILE

