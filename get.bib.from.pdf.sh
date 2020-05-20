#!/bin/bash
# Script to extract DOI info from a .pdf file named using my standard convention
#    AUTHORS_YEAR_TITLE_JOURNAL.pdf
# and then download the bibtex entry from crossref.org
# Likely does not include abstract
# usage: command FILE.pdf

if [ "$#" -ne 1 ]; then
    echo "Error in $0:  One argument expected: File name";
    exit 1
fi

DOI2BIB="$HOME/bin/doi2bib"

# Get command invoked
command="$0";

#strip off leading information
command=${command##*/}


#echo "command argument: $command"

INFILE="$1";
AUTHOR=$(echo $INFILE| cut -d '_' -f 1);
YEAR=$(echo $INFILE| cut -d '_' -f 2)
AUTHOR=${AUTHOR/\.et\.al/EtAl};
AUTHOR=${AUTHOR/\.and\./And};

AUTHORYEAR=$AUTHOR'_'$YEAR;


#remove line feeds
BIBFILE="/tmp/$AUTHORYEAR.bib";
echo "\$BIBFILE is $BIBFILE"

#remove any commas.
#Note bash seems to remove multiple spaces from strings by default.
# This behavior is fine, but unexpected.
BIBFILE="${BIBFILE//,/ }"
#replace any spaces with a period.
BIBFILE="${BIBFILE// /.}"
#replace any double periods with a single period
BIBFILE="${BIBFILE//../.}"

echo "\$AUTHOR is $AUTHOR"
echo "\$YEAR is $YEAR"
echo "\$BIBFILE is $BIBFILE"
#echo -n "Attempt to create BiBTeX entry for article? (n)        : ";
#read  RENAME;
#if [[ $RENAME == "y" || $RENAME == "Y" ]]; then
    echo "Extracting DOI and attempting to get BiBTeX information";
    DOIINFO=$(pdfinfo $INFILE | grep -o doi:.*);
    if [[ ${#DOIINFO} -eq 0 ]]; then
	echo "No DOI info found for $AUTHORYEAR using pdfinfo.";
	echo "Creating error message in file";
	echo "Error: No DOI info found for $INFILE using pdfinfo." > $BIBFILE;
	exit 1
    else
	echo "Extracted DOI $DOIINFO of length ${#DOIINFO} for $AUTHORYEAR";
	echo "Creating $BIBFILE"
	$DOI2BIB $DOIINFO > $BIBFILE; #installed in watauga ~/bin
	sed -i -E "s/@article\{.*/article@{$AUTHOR$YEAR,/i" $BIBFILE;
    fi
    
#else
#    echo "Not generating BiBTeX entry.";
#fi
