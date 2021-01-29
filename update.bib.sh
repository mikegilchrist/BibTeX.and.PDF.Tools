#!/bin/bash
# pipeline script to use the latest N .ris files in /tmp to update
#  - Convert ris files to a /tmp/savedrecs.txt file
#  - Run prepend.bib.sh
# 

## FIrst error check
if [[ "$#" -ne 1 ]]; then
    echo "Error in $0:  One argument expected: N - the number of .ris files to process.";
    exit 1;
fi

ISIFILE="/tmp/savedrecs.txt";
OUTFILES=($ISIFILE);


# Get command invoked
command="$0";

#strip off leading information
command=${command##*/};
VERBOSE=1;
N="$1"  # of ris files to process

## Get an array of ris files, newest first, ignoring already processed files
RISFILES=( $(ls -t /tmp/*.ris --ignore "-used.ris") );
NRISFILES=${#RISFILES[@]};

if [ $VERBOSE ]; then
    echo "All matching .ris files in /tmp";
    echo "File list: ${RISFILES[@]}";
    echo "List length: ${#RISFILES[@]}";
fi

## check array is >= $N
if [ ${#RISFILES[@]} -lt "$N" ];then 
    echo "Error in $0:  The number of .ris files to process is greater than the number in /tmp/ directory.";
    exit 1;
fi 


## Check for pre-existing files
## Could offer to append rather than remove
for FILE in ${OUTFILES[@]}; do 
if [ -f "$FILE" ]; then
    echo "$FILE already exists.";
    echo "Remove file and continue (n)";
    read TMP;
    if [[ $TMP == "y" || $TMP == "Y" ]]; then
	echo "Removing $FILE and continuing";
	rm "$FILE";
    else
	echo "Leaving $FILE untouched\nExiting...";
	exit 1;
    fi
fi
done


echo "RIS indices: ${!RISFILES[@]}";
## Get the first N entries
## DOn't understand bash arrays.
## Can't simply replace entire array with a new one.
## Need to unset first

TMP=${RISFILES[@]:0:N};
unset RISFILES;
RISFILES=$TMP;

if [ verbose ]; then
    echo "TMP indices: ${!TMP[@]}";
    echo "RIS indices: ${!RISFILES[@]}";
fi

if [ $VERBOSE ]; then
    echo "First $N matching .ris files in /tmp";
    echo "File list: ${RISFILES[@]}";
    echo "List length: ${#RISFILES[@]}";
fi


## Create ISIFILE
for FILE in ${RISFILES[@]}; do
    echo $FILE;
    ris2xml "$FILE" | xml2isi -nb >> "$ISIFILE";
done


echo "Now running prepend.bib.pl script";

~/bin/prepend.bib.pl ;

exit
