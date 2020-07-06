#!/bin/bash
#
#get papers from PubMed ID's in bibtex file if possible

if [ "$#" -eq 0 ]; then
    echo -e "$0: Script for downloading pdf's based on pubmed IDs in .bib file.\nWill download file to TARGETDIR and then make symbolic link to current dir.\nIn general, TARGETDIR should be ~/References.";
    echo -e "usage: <command> BIBFILE TARGETDIR";
    exit 0
fi

if [ "$#" -ne 2 ]; then
    echo -e "Error in $0:  Two arguments expected: BIBFILE TARGETDIR"
    exit 1
fi

BIBFILE=$1;
TARGETDIR=$2;

if [ ! -d "$HOME/Repositories/Pubmed-Batch-Download/" ]; then echo -e "Need to download Pubmed-Batch-Download repo from git hub\n Use $ git clone  https://github.com/billgreenwald/Pubmed-Batch-Download.git and place in ~/Repositories. You'll also need to install pip"
fi

#extract PMID list
pmidlist=($(grep "pmid" $BIBFILE | grep -o "[0-9]\+" | tr '\n' ' ') );

echo -e "PMID's Extracted ${pmidlist[*]}\n";

#extract list of file names to use
filenamelist=($(grep "^[[:space:]]file.= {" $BIBFILE | grep -o "References\/[[:alpha:]].*.pdf" | tr '\n' ' ' | sed 's/References\///g') );

echo -e "File names to use ${filenamelist[*]}\n"



#check to see lengths of filelist and pmid match
npmids=${#pmidlist[@]}
nfilenames=${#filenamelist[@]}


#echo -e '%s\n' "${pmidlist[@]}"
#echo -e '%s\n' "${filenamelist[@]}"

echo -e "# PMIDS: $npmids\t# Files: $nfilenames";

if [ $npmids -ne $nfilenames ]; then
    echo -e "Warning in $0: Number of PubMedIDs in $BIBFILE ($npmids) does not match the number of file names extracted ($nfilenames)."
    #echo -e "Exiting."
    #exit 1
fi


#premature exit for trouble shooting
#exit 0

for i in `seq 0 $((npmids-1))`; do
    if [ -f "$TARGETDIR/toPaperDownload$i.pdf" ]; then  rm "$TARGETDIR/toPaperDownload$i.pdf";
    fi
    #to paper modifies the file name so save it to a tmp file and then move it
    #wait -n;
    pmid="${pmidlist[$i]}";
    python3.7 "$HOME/Repositories/Pubmed-Batch-Download/fetch_pdfs.py" -pmids  $pmid -out /tmp/;
    cp "/tmp/$pmid.pdf" "$TARGETDIR/${filenamelist[$i]}";
    
    if [ $? -ne 0 ]; then
	echo -e "$0 WARNING: Failed to get ${pmidlist[$i]} \t ${filenamelist[$i]}";
    fi
    
    echo -e "Creating local link for $TARGETDIR/${filenamelist[$i]}?"
    #read TMP;
    #if [[ $TMP == "y" || $TMP == "Y" ]]; then
	ln -s "$TARGETDIR/${filenamelist[$i]}" .
    #fi
done

exit 0
