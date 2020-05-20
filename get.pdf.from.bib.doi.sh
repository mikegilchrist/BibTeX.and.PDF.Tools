#!/bin/bash
#
#get papers from doi in bibtex file if possible

if [ "$#" -eq 0 ]; then
    echo "$0: Script for downloading pdf's based on doi in .bib file";
    echo "usage: <command> BIBFILE TARGETDIR";
    exit 0
fi

if [ "$#" -ne 2 ]; then
    echo "Error in $0:  Two arguments expected: BIBFILE TARGETDIR"
    exit 1
fi

BIBFILE=$1;
TARGETDIR=$2;

#extract PMID list
doilist=($(grep "doi" $BIBFILE | grep -o "[0-9]\+" | tr '\n' ' ') );

echo "DOI's Extracted ${doilist[*]}";

#extract list of file names to use
filenamelist=($(grep "^[[:space:]]file.= {" $BIBFILE | grep -o "References\/[[:alpha:]].*.pdf" | tr '\n' ' ' | sed 's/References\///g') );

echo "File names to use ${filenamelist[*]}"



#check to see lengths of filelist and doi match
ndois=${#doilist[@]}
nfilenames=${#filenamelist[@]}


#printf '%s\n' "${doilist[@]}"
#printf '%s\n' "${filenamelist[@]}"

echo "# DOIS: $ndois\t# Files: $nfilenames";

if [ $ndois -ne $nfilenames ]; then
    echo "Error in $0: Number of DOIs in $BIBFILE ($ndois) does not match the number of file names extracted ($nfilenames)."
    echo "Exiting."
    exit 1
fi


#premature exit for trouble shooting
#exit 0

for i in `seq 0 $((ndois-1))`; do
    if [ -f "$TARGETDIR/toPaperDownload$i.pdf" ]; then  rm "$TARGETDIR/toPaperDownload$i.pdf";fi
    #to paper modifies the file name so save it to a tmp file and then move it
    #wait -n;
    ~/bin/topaper "${doilist[$i]}" "/tmp/toPaperDownload$i";
    mv -f "/tmp/toPaperDownload$i.pdf" "$TARGETDIR/${filenamelist[$i]}";
    
    if [ $? -ne 0 ]; then
	echo "$0 WARNING: Failed to get ${doilist[$i]} \t ${filenamelist[$i]}";
    fi
    
    echo "Creating local link for $TARGETDIR/${filenamelist[$i]}?"
    #read TMP;
    #if [[ $TMP == "y" || $TMP == "Y" ]]; then
	ln -s "$TARGETDIR/${filenamelist[$i]}" .
    #fi
done

exit 0
