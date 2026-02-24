# BibTeX.and.PDF.Tools

Personal toolchain for managing academic references: converting bibliography
files (RIS, BibTeX, NBIB, EndNote) into standardized BibTeX entries with
custom citation keys, generating descriptive PDF filenames, moving PDFs to
a central `~/References/` directory, and creating symbolic links in project
directories.

Also includes tools for converting PDFs into multi-page layouts (via
`pdfxup`), reducing PDF size, adding page numbers, and bundling TeX files.


# Installation

- Clone this repo into a folder such as `~/Repositories/`.
- Add the repo folder to your `$PATH`, or create symlinks to executables
  in a folder already in your path (e.g., `~/bin/`):

      [~/bin] $ find -L ~/Repositories/BiBTeX.and.PDF.Tools/* \
                  -type f -executable -exec ln -s {} . \; -print

- Install Python dependencies:

      pip install rispy bibtexparser

- (Legacy only) Create a symlink for the isi2bibtex config file:

      [~/] $ ln -s ~/Repositories/BiBTeX.and.PDF.Tools/isi2bibtexrc .isi2bibtexrc


# Requirements

## Directories

The following directories must exist in your home directory:

- `~/BiBTeX/`
- `~/BiBTeX/Bkups/`
- `~/References/`

Downloaded PDFs and bibliography files are expected in `/tmp/` (configurable
with `--dir`).

## Software

- Python 3.9+
- [bibutils](https://sourceforge.net/p/bibutils/home/Bibutils/) --
  for NBIB, EndNote, and fallback RIS/BibTeX conversion
- `pdfxup` -- for PDF layout tools (optional)
- `ghostscript` -- for PDF size reduction (optional)


# Supported Input Formats

| Extension | Format | Parser |
|-----------|--------|--------|
| `.ris` | RIS (Research Information Systems) | rispy (Python) or bibutils fallback |
| `.bib` | BibTeX | bibtexparser (Python) or built-in regex parser |
| `.nbib` | NBIB (PubMed/MEDLINE native) | bibutils (nbib2xml) |
| `.end` | EndNote plain text | bibutils (end2xml) |
| `.endx` | EndNote XML | bibutils (endx2xml) |
| `.xml` | MODS XML | bibutils (xml2bib) -- explicit file mode only |


# Pipeline (Usage)

## Primary Tool: update.bib.py

### Batch mode (default)

Process the N newest bibliography files from `/tmp/`:

    $ update.bib.py N

Where `N` is the number of files to process. This finds `.ris`, `.bib`,
`.nbib`, or `.end` files in `/tmp/`, converts them to BibTeX with
standardized keys and filenames, and prepends entries to
`~/BiBTeX/bibliography.full.bib`.

### Paired mode

Process a single bibliography file and associate it with a downloaded PDF:

    $ update.bib.py paper.ris paper.pdf

This converts the bibliography entry, generates the standardized filename,
moves the PDF to `~/References/`, and creates a symlink in the current
directory.

### File-list mode

Process one or more named bibliography files:

    $ update.bib.py ref1.ris ref2.bib ref3.nbib

### Options

    -n, --dry-run       Show what would be done without making changes
    -v, --verbose       Show detailed output
    -d, --dir DIR       Staging directory for batch mode (default: /tmp)
    -f, --format FMT    Force input format instead of auto-detecting
    --no-move           Skip PDF move/link step
    --no-prepend        Skip prepending to master bibliography
    --bib FILE          Master bibliography file
    --refs DIR          References directory (default: ~/References)


## Naming Conventions

### Citation keys

| Authors | Key format | Example |
|---------|-----------|---------|
| 1 | AuthorYear | Smith2012 |
| 2 | Author1AndAuthor2Year | SmithAndJones2012 |
| 3+ | Author1EtAlYear | SmithEtAl2012 |

### PDF filenames

| Authors | Filename format |
|---------|----------------|
| 1 | `Author_Year_title.words_Journal.Name.pdf` |
| 2 | `Author1.and.Author2_Year_title.words_Journal.Name.pdf` |
| 3+ | `Author1.et.al_Year_title.words_Journal.Name.pdf` |


## Legacy Pipeline

The original pipeline (still functional but deprecated) uses `update.bib.sh`,
`isi2bibtex` (Perl), and `prepend.bib.pl` (Bash). See `CLAUDE.md` for
details on all legacy scripts.


# Script Inventory

## Reference management
| Script | Purpose |
|--------|---------|
| update.bib.py | Main tool: multi-format bibliography conversion |
| update.bib.sh | Legacy batch RIS converter (deprecated) |
| isi2bibtex | Legacy ISI -> BibTeX converter (Perl) |
| prepend.bib.pl | Legacy interactive orchestrator |
| bib.move.and.link.sh | Interactive PDF-to-entry matching |

## Format conversion
| Script | Purpose |
|--------|---------|
| bib2ris | BibTeX -> RIS via bibutils |
| bib2isi | BibTeX -> ISI via bibutils |
| nbib2ris | NBIB -> RIS via bibutils |

## PDF downloading
| Script | Purpose |
|--------|---------|
| download.pdfs.from.doi.sh | Download via Unpaywall API or publisher scraping |
| extract.doi.from.bib.sh | Extract DOIs from .bib to dois.txt |
| get.pdf.from.bib.doi.sh | Batch download using DOIs from .bib |
| get.pdf.from.bib.pmid.sh | Batch download using PMIDs |
| get.bib.from.pdf.sh | Extract BibTeX from PDF metadata via DOI |

## File management
| Script | Purpose |
|--------|---------|
| move.and.link.sh | Move file to directory, create symlink |
| rename.move.and.link.sh | Rename, move, and link a PDF |
| copy.target.and.redirect.links.sh | Relocate symlink targets |

## PDF tools
| Script | Purpose |
|--------|---------|
| make.2x1.and.link.pdf.sh | Multi-page layouts (2x1, 2x2, 2x3, etc.) |
| reduce.pdf.size.sh | Reduce PDF resolution via ghostscript |
| add.page.numbers.to.pdf.sh | Add page numbers to PDF |
| calc.pdf.page.sizes.sh | Report per-page dimensions |
| bundle_tex_figures.sh | Bundle .tex + figures for sharing |


# Known Issues

- `*2xml` tools from bibutils may lose PMID information during conversion.
- ISI format uses `PM` for PubMed ID; RIS does not include PMIDs.
- Automatic PDF download via PMID is inconsistent.
