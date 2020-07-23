# BibTeX.Tools
My tools for creating custom bibtex entries, moving and renaming downloaded files to a standard name, placing them in the directory '~/References', and making symbolic (soft) links to files in current (or other) directory.

# Pipeline
1. Place references in ISI format in /tmp/savedrecs.txt file
    a. Download references from Web of Science in ISI format
    b. Alternatively, convert references to ISI format using tools from the bibutils suite  (e.g. ris2xml piped to xml2isi) or personal scripts that utilize these tools, e.g. ris2isi.
1. (OPTIONAL) Download PDFs of the files described in savedrecs.txt and place them in /tmp/.  with the timestamps corresponding to the time they were downloaded.
2. Run prepend.bib.pl which runs
    - isi2bibtex on /tmp/savedrecs.txt, creating /tmp/tmp.bib
    - Asks if you wish to append /tmp/tmp.bib to ~/BiBTeX/bibliography.full.bib (and creates a backup of bibliography.full.bib)
    - Renames savedrecs.txt as savedrecs.txt.old
    - Asks if you wish to run bib.move.and.link.sh which will 
        a. use the information in /tmp/tmp.bib to generate appropriate filenames for the pdfs
        b. provide an indexed list of the filenames for the pdfs.
        c. print some information from the pdf to the std. output, and ask the user to assign the pdf file to one of the references.
        d. Move the pdf to ~/Reference and make a symbolic link to the directory the script is being run from.

## Issues
- Automatic download of pdfs listed in tmp.bib using PMID works inconsistently.
- RIS doesn't use PMIDs
- Need to automate means of creating savedrecs.txt such as bulk conversion of individual .ris files (or other formats).
- Need to be able to edit proposed file names since scripts are imperfect.


# File Descriptions
## isi2bibtex
Takes a 'plain text' (really an ISI formated file) file of references exported from from Web of Science. 
Exported file is saved in /tmp/savedrecs.txt. 
Script creates a .bib version of entries where the bibkey is customized to be either
    - AuthorYear: Single author paper
    - Author1AndAuthor2Year: Two author paper
    - Author1EtAlYear: 2+ author paper
Script also populates the `file = {}' entry as
    - Author_Year_article.title_Journal.Title.pdf
    - Author1.and.Author2_Year_article.title_Journal.Title.pdf
    - Author1.et.al_Year_article.title_Journal.Title.pdf
Script relies on .isi2bibtexrc file in home directory for some of this customization.

# Issues
---2xml seems to loose PMID info
isi uses PM for pubmed ID
