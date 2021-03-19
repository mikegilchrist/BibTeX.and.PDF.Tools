#!/bin/bash
#
# Script to help organize repositories.
# Copies a file to a (presumably) broken target of the symlink given
#
# Expects 1 argument

if [ "$#" -ne 2 ];
then
    echo "Error in $0:  Need 1 arguments: <FILE> <LINKTOFOLLOW>";
    exit 1;
fi

FILE="$1";
LINKTOFOLLOW="$2";

DEST=$(readlink "$LINKTOFOLLOW") && cp "$FILE" "$DEST"  ||  { echo "readlink failed"; exit 1; }
