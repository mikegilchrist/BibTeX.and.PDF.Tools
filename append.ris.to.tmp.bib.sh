#!/bin/bash
# Script to convert a .ris bib file with a **single** entry to bibtex format
# The bibtex entry uses the Author and Year arguments for the entry's key
# The output is appended it to a temporary file /tmp/tmp.bib.
# This file can be added to a master bib file later.
# 
# usage: authors (smith.et.al) year (2012)

if [[ "$#" -ne 2 && "$#" -ne 3 ]]; then
    echo "Error in $0:  Two or three arguments expected: <author info> <year> [file.ris]";
    exit 1
fi


if [ "$#" -eq 2 ]; then
    RISFILE="$(ls -tr /tmp/*.ris|tail -1)";    
    echo "No .ris file specified.  Using latest in /tmp/ : $RISFILE";
else
    RISFILE="$3";
fi

# Get command invoked
command="$0";

#strip off leading information
command=${command##*/}


#echo "command argument: $command"



TMPOUTFILE="/tmp/tmp.bib";
BIBFILE="$HOME/BiBTeX/bibliography.full.bib";
BKUPBIBFILE="$BIBFILE-bkup";


AUTHORINFO=${1/\.et\.al/EtAl};
AUTHORINFO=${AUTHORINFO/\.and\./AND};

#remove and replace suffix
TMPINFILE="${RISFILE%\.ris}";
TMPINFILE="$TMPINFILE.bib"

if [ $TMPINFILE = $RISFILE ]; then
    echo "RISFILE and TMPINFILE are the same (they shouldn't be). Exiting";
    exit 1
fi


/usr/share/cb2bib/c2btools/ris2bib $RISFILE $TMPINFILE;
sed -i -E "s/@article\{.*/@article{$AUTHORINFO$2,/i" $TMPINFILE;

printf "First few lines of RIS file: $RISFILE\n";
less "$RISFILE" | head -5;

printf "First few lines of BIB file: $TMPINFILE\n";
less "$TMPINFILE" | head -5;

if [ "$#" -eq 2 ]; then
    echo -n "Append '-used' to $RISFILE? (n)        : ";
    read  RENAME;
    if [[ $RENAME == "y" || $RENAME == "Y" ]]; then
	echo "Renaming file $RISFILE to $RISFILE-used";
	mv $RISFILE "$RISFILE-used";
    else
	echo "Leaving file $RISFILE unchanged.";
    fi
fi

case $command in
    "append.ris.to.tmp.bib.sh")
	#printf "Prepending $TMPINFILE\nto\n\t$BIBFILE and linking\n";
    #mv "$INFILE" ~/References/$OUTFILE; ln -s ~/References/$OUTFILE .;
	cat $TMPINFILE >> $TMPOUTFILE;
	;;
   *)
    echo "$0 does not match an expected category. Exiting";
    exit 1         # unknown option
    ;;
esac
    
