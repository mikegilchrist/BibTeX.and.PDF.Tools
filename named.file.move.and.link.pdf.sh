#!/bin/bash
# Script to move already properly named .pdf file to ~/References
# and make a symbolic link in the current directory
#
# 
# usage: $FILENAME (including path)

# Get command invoked
command="$0";

if [ "$#" -ne 1 ]; then
    echo "Error in $0:  One argument expected: <dir/filename>"
    exit 1
fi

#strip off leading information
command=${command##*/}


#echo "command argument: $command"

INFILE="$1"
OUTFILE="$HOME/References${1##[^/]+/}" # remove everything up to file name

mv "$INFILE" "$OUTFILE"
ln -s "$OUTFILE" .

exit 0
