#!/bin/bash
# Script to move or copy already properly named .pdf file to another directory (~/Reference by default)
# and make a symbolic link in the current directory
#
# 
# usage: $FILENAME (including path)

# Get command invoked
command="$0";


if [ "$#" -ne 1 -a "$#" -ne 2 ]; then
    echo "Error in $0:  One or two arguments expected: <dir/filename> <optional target dir>"
    exit 1
fi

#strip off leading information
command=${command##*/}


#echo "command argument: $command"

INFILE="$1";

if [ "$#" -eq 1 ]; then
    OUTDIR="$HOME/References"; # default
else
    OUTDIR="$2"; 	
fi

OUTDIR=$(realpath $OUTDIR); ## Remove any trailing slash

OUTFILE="$OUTDIR/$(basename $1)" # remove everything up to file name

if [[ "$command" =~ move.*.sh ]]; then
  mv "$INFILE" "$OUTFILE";
else
  cp -a "$INFILE" "$OUTFILE";
fi
 
ln -sr "$OUTFILE" .

exit 0
