#!/bin/bash
#
# Script to move a file to a new location and then create a link to it in current directory.
# Example usage:  find *.pdf -maxdepth 1 -type f  -exec move.and.link.sh "{}" "../../References" \;
#     Moves all pdf files to ../../References and creates a link to them.

# Note I used to have a script with a similar name, move.and.link.pdf, that is in my bib tools
# and now called std.rename.move.and.link.sh

# Expects 1 or 2 arguments

if [ "$#" -ne 1 -a "$#" -ne 2 ]; then
    echo "Error in $0:  One or two arguments expected: <dir/filename> <optional target dir>"
    exit 1
fi

FILE="$1";


if [ "$#" -eq 1 ]; then
    OUTDIR="../../References"; # default
else
    OUTDIR="$2"; 	
fi

TARGET="$OUTDIR/$(basename $FILE)";

if [[ "$command" =~ move.*.sh ]]; then
    mv "$FILE" "$TARGET";
else
    cp -L "$FILE" "$TARGET";
    if [ $? -eq 0 ]; then
	rm "$TARGET"
    else
	echo "Problem copying $TARGET";
	exit 1
    fi
fi

ln -sr "$TARGET" .
if [ $? -eq 0 ]; then
    exit 0
else
    echo "Problem linking to $TARGET";
    exit 1
fi

