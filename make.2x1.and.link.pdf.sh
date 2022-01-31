#!/bin/bash
# make 2x1 version of a paper
# 

## No longer needed, allow passing of optional arguments
## FIrst error check
#if [[ "$#" -ne 1 ]]; then
#    echo "Error in $0:  One argument expected: <FILE.pdf>";
#    exit 1;
#fi

if [[ "$0" = *.4x1.sh ]]; then
    COL=2;
    ROW=2;
    FW=1;
    LND=1;
    SUFF="4x1";
    MAR=5;
    ISP=0;
else  ## 2x1
    COL=2;
    ROW=1;
    FW=0;
    LND=1;
    SUFF="2x1";
    MAR=30;
    ISP=0;
fi

    
FILE="$1";
echo "FILE = $FILE"

OPTARGS="${@:2}"
# I thought OPTARGS might have newlines, but it doesn't seem to
#OPTARGS=${OPTARGS/$'\n'/ /}

echo "OPTARGS = $OPTARGS; length = ${#OPTARGS}"

TMPFILE="tmp-$(basename $FILE)"
NEWFILE="${FILE/.pdf/-$SUFF.pdf}"

## Commented out after add $OPTARGS
#PAGES=$(pdfinfo $FILE | grep "^Pages" | awk '{print $2}')
### Truncate if long file
#if [[ $PAGES -ge 20 ]]; then
#    PAGES=20
#fi

#Use page 2 by default
PAGES=2
#"2-3"
echo "Pages: $PAGES"
echo "Tmp File: $TMPFILE"
echo "New File: $NEWFILE"

cp -Lf "$FILE" "/tmp/$TMPFILE"  || { echo "Failed to copy $FILE to /tmp/$TMPFILE; Exiting"; exit 1; } # need to use {\  and \ } [note spaces] and not () (which starts a subshell)


# -V: Verbosity
# -fw: Frame weight
# -m: Margins of new document
# -is: interspace between pages
# Had to remove #  -bb 1-$PAGES \

~/bin/pdfxup-local \
  -V 2 \
  -bb "$PAGES" \
  -fw "$FW" \
  -m "$MAR" \
  -l "$LND" \
  -x "$COL" \
  -y "$ROW" \
  -is "$ISP" \
  -ps "letter" \
  -o pdfxup.pdf $OPTARGS "/tmp/$TMPFILE" || { echo "Failed to run pdfxup on /tmp/$TMPFILE; Exiting"; exit 1; } 
# NOTE: Don't put quotes around $OPTARGS.  That screws things up, I don't know why.
#       Perhaps because it is already a string?
#
#       pdfxup.pdf should be in current dir
# 
#       Because I am using an alias for pdfxup, there's an issue with the exit code from pdfxup not being properly passed.

echo "Removing temporary file /tmp/$TMPFILE"
rm -f "/tmp/$TMPFILE" || { echo "Failed to remove /tmp/$TMPFILE ; Exiting"; exit 1; }
mv "pdfxup.pdf" "$NEWFILE"  || { echo "Failed to copy pdfxup.pdf to $NEWFILE"; exit 1; }

if [[ "$FILE" == "/tmp/"* ]]; then
    echo "Move $NEWFILE to local directory? (y)/n"
    read TMP;
    if [[ $TMP != "n" || $TMP != "N" ]]; then
        echo "Moving $NEWFILE to $PWD";
        mv $NEWFILE .;
    fi
fi

if [[ "$0" = *.and.link.pdf.sh ]]; then 
    mv "$NEWFILE" "$HOME/References/" || { echo "Failed to mv $NEWFILE to ~/References"; exit 1; }
    ln -s "$HOME/References/$NEWFILE" . || { echo "Failed to link ~/References/$NEWFILE to local dir"; exit 1; }

    echo "Use copy.target.and.redirect.links.sh to alter where link points? (useful for working with repos)? [y/n]"
    read TMP;
    if [[ $TMP == "y" || $TMP == "Y" ]]; then
        #    declare -a LINKSCREATED=(); #create an array # this doesn't need to be here
        echo "Enter new location for target. (default \"../../References/\")";
        read TARGET;
        if [[ $TARGET == "" ]]; then
            TARGET="../../References/";
        fi
        copy.target.and.redirect.links.sh "$NEWFILE" "$TARGET" || { echo "Failed to copy.target.and.redirect.links.sh for $NEWFILE and"; exit 1; }
    fi
fi
