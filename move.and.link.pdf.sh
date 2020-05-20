#!/bin/bash
# Script to rename and move most recently downloaded .pdf file in /tmp to ~/References
# and make a symbolic link in the current directory
#
# 
# usage: authors (smith.et.al) year (2012) title ("dna replication and stuff") journal ("A Really Good Journal")

if [ "$#" -ne 4 ]; then
    echo "Error in $0:  Four arguments expected: <author info> <year> <article title> <journal name>"
    exit 1
fi

# Get command invoked
command="$0";

#strip off leading information
command=${command##*/}


#echo "command argument: $command"

INFILE="$(ls -tr /tmp/*.{pdf,PDF}|tail -1)"
OUTFILE="$1_$2_$3_$4.pdf"

#remove line feeds
OUTFILE=${OUTFILE//[$'\t\r\n']/ }

#remove any commas.
OUTFILE="${OUTFILE//,/ }"
OUTFILE="${OUTFILE//:/ }"
#replace any spaces with a period.
#Note bash seems to remove multiple spaces from strings by default.
# This behavior is fine, but unexpected.
OUTFILE="${OUTFILE// /.}"
#replace any double periods with a single period
OUTFILE="${OUTFILE//../.}"

printf "First few lines of file: $INFILE\n";
less "$INFILE" | head -13;

echo -n "Move and link/rename $INFILE? (n)        : ";
read  RENAME;
if [[ $RENAME == "y" || $RENAME == "Y" ]]; then
    echo "Renaming file $INFILE to $OUTFILE";
else
    echo "Leaving file $INFILE unchanged.";
    exit 1
fi

case $command in
    "move.and.link.pdf.sh")
	printf "Moving file\n\t$INFILE\nto\n\t$OUTFILE and linking\n";
	mv "$INFILE" ~/References/$OUTFILE; ln -s ~/References/$OUTFILE .;
	;;
    "move.and.rename.pdf.sh")
    	printf "Moving file\n\t$INFILE\nto\n\t./$OUTFILE\n";
	mv "$INFILE" ./$OUTFILE;
	;;
   *)
    echo "$0 does not match an expected category. Exiting"
    exit 1         # unknown option
    ;;
esac
    
