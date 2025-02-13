#!/bin/bash
# make 2x1 version of a paper
# 


if [[ "$#" -lt 1 ]]; then
    echo "Error in $0:  A minimum of one argument expected: <FILE.pdf>";
    exit 1;
fi

CMD="$(basename $0)";

echo "$CMD"

case "$CMD" in
    *.4x1.sh|*.2x2.sh)
    COL=2;
    ROW=2;
    FW=0;
    LND=0; # would have expected it to be 1...
    SUFF="2x2";
    MAR=5;
    ISP=0;
    ;;
   *.2x1.sh)
    COL=2;
    ROW=1;
    FW=0;
    LND=1;
    SUFF="2x1";
    MAR=25;
    ISP=10;
    ;;
   *3x2.sh)
    COL=2;
    ROW=3;
    FW=0;
    LND=1;
    SUFF="3x2";
    MAR=5;
    ISP=0;
    ;;
   *2x3.sh)
    COL=3;
    ROW=2;
    FW=0;
    LND=0;
    SUFF="2x3";
    MAR=5;
    ISP=0;
    ;;
    *)
      echo "Unrecognized command: file not processed"
      ;;
esac

       #echo "SUFF= $SUFF"
       
## assume file is last argument

    
FILE="${@: -1}";
echo "FILE = $FILE"

OPTARGS="${@:1:${#}-1}"
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
# Commented out due to ability to pass arguments
# PAGES=2
#"2-3"
#echo "Pages: $PAGES"
echo "Tmp File: $TMPFILE"
echo "New File: $NEWFILE"

cp -Lf "$FILE" "/tmp/$TMPFILE"  || { echo "Failed to copy $FILE to /tmp/$TMPFILE; Exiting"; exit 1; } # need to use {\  and \ } [note spaces] and not () (which starts a subshell)


# -V: Verbosity
# -fw: Frame weight
# -m: Margins of new document
# -is: interspace between pages
# -nc : no clipping or -c 0
# Had to remove #  -bb 1-$PAGES \
# 2023-03-21: Changed from ~/bin/pdfxup-local to pdfxup
pdfxup \
  -V 2 \
  -fw "$FW" \
  -m "$MAR" \
  -l "$LND" \
  -x "$COL" \
  -y "$ROW" \
  -is "$ISP" \
  -ps "letter" \
  -o pdfxup.pdf $OPTARGS "/tmp/$TMPFILE" || { echo "Failed to run pdfxup on /tmp/$TMPFILE; Exiting"; exit 1; } 
# NOTE: Don't put quotes around $OPTARGS.  That screws things up, I don't kvnow why.
#       Perhaps because it is already a string?
#
#       pdfxup.pdf should be in current dir
# 
#       Because I am using an alias for pdfxup, there's an issue with the exit code from pdfxup not being properly passed.

# This doesn't work
# Shouldn't need it give || statement at end of pdfxup command
#if [ $? -ne 0 ]; then
#	echo "pdfxup command failed. Exiting
#	exit 1
#fi

echo "Removing temporary file /tmp/$TMPFILE"
rm -f "/tmp/$TMPFILE" || { echo "Failed to remove /tmp/$TMPFILE ; Exiting"; exit 1; }
mv "pdfxup.pdf" "$NEWFILE"  || { echo "Failed to copy pdfxup.pdf to $NEWFILE"; exit 1; }

if [[ "$FILE" == "/tmp/"* ]]; then
    echo "Move $NEWFILE to local directory? (y)/n"
    read TMP;
    if [[ $TMP != "n" || $TMP != "N" ]]; then
        echo "Moving $NEWFILE to $PWD";
        mv "$NEWFILE" .;
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
        if [[ "$TARGET" == "" ]]; then
            TARGET="../../References/";
        fi
        copy.target.and.redirect.links.sh "$NEWFILE" "$TARGET" || { echo "Failed to copy.target.and.redirect.links.sh for $NEWFILE and"; exit 1; }
    fi
fi
