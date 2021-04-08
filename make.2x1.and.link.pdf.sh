#!/bin/bash
# make 2x1 version of a paper
# 

## FIrst error check
if [[ "$#" -ne 1 ]]; then
    echo "Error in $0:  One argument expected: <FILE.pdf>";
    exit 1;
fi

FILE="$1";
NEWFILE="${FILE/.pdf/-2x1.pdf}"

cp -L "$FILE" /tmp/.  || { echo "Failed to copy $FILE to /tmp; Exiting"; exit 1; } # need to use {\  and \ } [note spaces] and not () (which starts a subshell)
pdfxup -fw 0 -m 30 -ps 'letter' "/tmp/$FILE" || { echo "Failed to run pdfxup on /tmp/$FILE; Exiting"; exit 1; } #pdfxup.pdf should be in current dir
 # Note, because I am using an alias for pdfxup, there's an issue with the exit code from pdfxup not being properly passed.
rm -f "/tmp/$FILE" || { echo "Failed to remove /tmp/$FILE ; Exiting"; exit 1; }
mv "pdfxup.pdf" "$NEWFILE"  || { echo "Failed to copy pdfxup.pdf to $NEWFILE"; exit 1; }

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
