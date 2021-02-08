#!/bin/bash
# Script to rename and move files based on listings in /tmp/tmp.bib generated by prepend.bib.sh and a savedrecs.txt file from Web of Science
# Default ordering of file listing assumes pdf files were downloaded in opposite order of listing in marked list from Web of Science 
#
# most recently downloaded .pdf file in /tmp to ~/References
# and make a symbolic link in the current directory
#
# 
# usage: authors (smith.et.al) year (2012) title ("dna replication and stuff") journal ("A Really Good Journal")
#
# Log:  Added copy.target.and.redirect.link.sh option
echo "starting script..."

# set IFS to deal with spaces in names
OLDIFS=$IFS;
IFS=$'\n';

# Get array of Destination names of articles from tmp.bib 
# using eval seems to mess things up if there are parentheses in the file name
# However, removing it seems to result in other problems
# So I'm restoring it again
eval DESTINATIONS=("$(grep -o "/home/mikeg/References/.*.pdf" /tmp/tmp.bib | tac)");
# Try the line below if the file name has parentheses
# DESTINATIONS=("$(grep -o "/home/mikeg/References/.*.pdf" /tmp/tmp.bib | tac)");

NDEST=${#DESTINATIONS[@]}

echo "destinations: ${DESTINATIONS[@]}\n NDEST $NDEST"


#Create a command, use using $INDEXDEST
INDEXDEST='echo "File List"; 
      for i in "${!DESTINATIONS[@]}"; do
	FILE="${DESTINATIONS[$i]}";
	FILE="${FILE/\/home\/mikeg\/References\//}";
	echo "$(($i+1))) $FILE";
       done'


#get list of pdfs in /tmp
# Next line works with redefined IFS
SOURCE=($(ls -trh /tmp/*.{pdf,PDF} | tail -$NDEST));
# A non-IFS approach that doesn't work yet...
# readarray -t SOURCE < <($(ls -trh /tmp/*.pdf | tail -$NDEST));


#print files
#echo ${SOURCE[@]}

for INFILE in "${SOURCE[@]}"; do
    printf "\n\nFirst few lines of PDF file: $INFILE\n";
    less "$INFILE" | head -13;
    echo "move to... (0 to skip)?"
    eval $INDEXDEST;
    read  IPLUSONE;
    if [[ "$IPLUSONE" -gt "0" ]]; then
	OUTFILE=${DESTINATIONS[$(($IPLUSONE-1))]};
	LINKSCREATED+=($OUTFILE); #add element to array; need parentheses
	DESTINATIONS[$(($IPLUSONE-1))]="(ALREADY MOVED)";
	echo "moving $INFILE to $OUTFILE";
	cp -a $INFILE $OUTFILE;
	ln -sr $OUTFILE .;
	echo "remove $INFILE (n)?"
	read TMP;
	if [[ $TMP == "y" || $TMP == "Y" ]]; then
	    echo "Removing $INFILE";
	    rm $INFILE
	fi
	# TODO: ask to remove entry from tmp.bib file
    else
	echo "Skipping $INFILE";
	
    fi


done

echo "Use copy.target.and.redirect.links.sh to alter where link points? (useful for working with repos)? [y/n]"
read TMP;
if [[ $TMP == "y" || $TMP == "Y" ]]; then
    declare -a LINKSCREATED=(); #create an array
    echo "Enter new location for target. (default \"../../References/\"";
    read TARGET;
    if [[ $TARGET == "" ]]; then TARGET="../../References/"; fi
    #    echo "Confirm new target directory (y/n): $TARGET"
    #    read TMP;
    #    if [[ $TMP == "y" || $TMP == "Y" ]]; then
    for INFILE in "${LINKSCREATED[@]}"; do
	copy.target.and.redirect.links.sh "$INFILE" "$TARGET";
	# TODO: ask to remove entry from tmp.bib file
    done
fi

echo "Okay, we're all done here.";


IFS=$OLDIFS;  # probably not necessary
