#!/bin/bash
#
# a program to convert downloaded isi files into bib files (both 
# full and abbrv versions) and to prepend this output to my 
# master bibliography files
#
# TODO 6/23/16 -- add downloading and saving of paper using tool topaper at
#    https://schneider.ncifcrf.gov/bibtex.html
#
#cp /tmp/uml_view.cgi  /tmp/full;

MYCOMMAND="$HOME/bin/get.pdf.from.bib.sh";  #command for getting files


ISITMPFILE="/tmp/isi-tmpfile";

if [ ! -f /tmp/savedrecs.txt ]; then
    echo "/tmp/savedrecs.txt does not exist. Please supply. Exiting"
    exit 1
fi


if [ -f /tmp/tmp.bib ]; then
    echo "/tmp/tmp.bib already exists."
    echo "Remove file and continue (n)"
    read TMP
    if [[ $TMP == "y" || $TMP == "Y" ]]; then
	echo "Removing /tmp/tmp.bib and continuing";
	rm /tmp/tmp.bib;
    else
	echo "Leaving /tmp/tmp.bib untouched\nExiting..."
	exit 1
    fi
fi

cp -f /tmp/savedrecs.txt "$ISITMPFILE";  #changed input file due to change by isi

~/bin/isi2bibtex $ISITMPFILE /tmp/tmp.bib;

echo "Check isi2bibtex output?"
read TMP;
if [[ $TMP == "y" || $TMP == "Y" ]]; then
    less /tmp/tmp.bib;
fi

echo "Append full.bib output to bibliography.full.bib?"
read TMP;
if [[ $TMP == "y" || $TMP == "Y" ]]; then
    cat /tmp/tmp.bib ~/BiBTeX/bibliography.full.bib > /tmp/bibliography.full.bib;

    cp -pf ~/BiBTeX/Bkups/bibliography.full.bib ~/BiBTeX/Bkups/bibliography.full.bkup;
    cp -pf ~/BiBTeX/bibliography.full.bib ~/BiBTeX/Bkups/bibliography.full.bib ;
    cp -pf /tmp/bibliography.full.bib ~/BiBTeX/bibliography.full.bib;


    #mv -f /tmp/uml_view.cgi /tmp/uml_view.cgi.old
    mv -f /tmp/savedrecs.txt /tmp/savedrecs.txt.old

    #if you want the abbrv file. This should no longer be needed since we use journal-iso
    if [ 1 -eq 0 ]; then
	~/bin/convert.bib.full.to.abbrv.pl /tmp/tmp.bib /tmp/abbrv.bib;
	cat /tmp/abbrv.bib ~/BiBTeX/bibliography.abbrv.bib > /tmp/bibliography.abbrv.bib;
	cp -pf ~/BiBTeX/Bkups/bibliography.abbrv.bib ~/BiBTeX/Bkups/bibliography.abbrv.bkup;
	cp -pf ~/BiBTeX/bibliography.abbrv.bib ~/BiBTeX/Bkups/bibliography.abbrv.bib ;
	cp -pf /tmp/bibliography.abbrv.bib ~/BiBTeX/bibliography.abbrv.bib;

    fi

    echo "Process any previously downloaded pdfs using bib.move.and.link.sh? (n)";
    read TMP;
    if [[ $TMP == "y" || $TMP == "Y" ]]; then
	~/bin/bib.move.and.link.sh
	#echo "exitcode = $exitcode"
    else
        #get the papers if you can added 10/10/19
        echo "Get papers in /tmp/tmp.bib using pmid, place in ~/References, and make link in current dir? (n)\n(Note need to have Pubmed-Batch-Download/ installed in ~/Repositories, required python libraries installed using anaconda)\n";
        read TMP;
        if [[ $TMP == "y" || $TMP == "Y" ]]; then
	    ~/bin/get.pdf.from.bib.pmid.sh /tmp/tmp.bib ~/References
	    #exitcode=$($MYCOMMAND /tmp/tmp.bib ~/tmp/tmp);
        else
	    echo "Not downloading files.\n"
        fi
    fi
    
    #if [ $exitcode -eq 0 ]; then
    #    #clean up
    #    rm -f /tmp/tmp.bib
    echo "Remove /tmp/tmp.bib? (n)";
    read TMP;
    if [[ $TMP == "y" || $TMP == "Y" ]]; then
	rm -f /tmp/tmp.bib;
    else
	echo "leaving /tmp/tmp.bib";
    fi
    rm -f /tmp/bibliography.full.bib
    rm -f /tmp/abbrv.bib
    #else
    #    echo "non-zero exit code encountered from $MYCOMMAND";
    #fi
else
    echo "Leaving files unchanged and not updating bibliography.full.bib"
fi
