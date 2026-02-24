# CLAUDE.md - BibTeX.and.PDF.Tools

## Purpose

Personal reference management toolchain. Converts bibliography files
(RIS, BibTeX, NBIB, EndNote) into standardized BibTeX entries with
custom citation keys, generates descriptive PDF filenames, moves PDFs
to a central ~/References/ directory, and creates symlinks in project
directories.

## Key Filesystem Paths

| Path | Purpose |
|------|---------|
| ~/BiBTeX/bibliography.full.bib | Master bibliography file (~48K lines) |
| ~/BiBTeX/Bkups/ | Backup copies of bibliography files |
| ~/References/ | Central PDF store (~5000 files) |
| /tmp/ | Staging area for downloaded PDFs and bibliography files |
| ~/.isi2bibtexrc | Config for isi2bibtex (symlink to repo's isi2bibtexrc) |

## Naming Conventions

### PDF filenames
```
Author_YYYY_title.words.separated.by.periods_Journal.Name.pdf

1 author:   Smith_2012_title.words_Journal.pdf
2 authors:  Smith.and.Jones_2012_title.words_Journal.pdf
3+ authors: Smith.et.al_2012_title.words_Journal.pdf
```

### BibTeX citation keys
```
1 author:   Smith2012
2 authors:  SmithAndJones2012
3+ authors: SmithEtAl2012
```

### BibTeX entry format
```bibtex
@article{SmithEtAl2012,
    author      = {Smith, J. and Jones, K. and Lee, M.},
    title       = {Article Title Here},
    journal     = {Journal Name},
    journal-iso = {},
    keywords    = {},
    year        = {2012},
    volume      = {42},
    pages       = {1-15},
    abstract    = {Abstract text...},
    file    = {/home/mikeg/References/Smith.et.al_2012_article.title.here_Journal.Name.pdf:PDF},
    timestamp  = {2026.2.23},
    pmid       = {},
    doi       = {10.1234/example}
}
```

### File field format
`file = {/home/mikeg/References/FILENAME.pdf:PDF}`

## Scripts (repo root)

### Primary tool
| Script | Language | Purpose |
|--------|----------|---------|
| update.bib.py | Python | Main tool: convert bib files, generate keys/filenames, move PDFs |

### Legacy pipeline (Perl/Bash)
| Script | Language | Purpose |
|--------|----------|---------|
| isi2bibtex | Perl | ISI -> BibTeX with custom keys (legacy, replaced by update.bib.py) |
| customize.bibtex.key.and.pdf.file | Perl | Rekey existing BibTeX entries (ISI input despite the name) |
| updatebib | Perl | Variant of isi2bibtex for updating keys |
| update.bib.sh | Bash | Old pipeline entry point (N newest .ris from /tmp) |
| prepend.bib.pl | Bash | Interactive orchestrator (despite .pl extension) |

### Format conversion (bibutils wrappers)
| Script | Purpose |
|--------|---------|
| bib2ris | BibTeX -> RIS via bibutils |
| bib2isi | BibTeX -> ISI via bibutils |
| nbib2ris | NBIB (PubMed) -> RIS via bibutils |

### PDF management
| Script | Purpose |
|--------|---------|
| bib.move.and.link.sh | Interactive PDF-to-entry matching and moving |
| move.and.link.sh | Move file to target dir, create symlink |
| copy.and.link.sh | Copy file to target dir, create symlink |
| rename.move.and.link.sh | Manual rename + move + link (4 positional args) |
| copy.target.and.redirect.links.sh | Relocate symlink targets |

### PDF downloading
| Script | Purpose |
|--------|---------|
| download.pdfs.from.doi.sh | Download PDFs via Unpaywall API or publisher scraping |
| extract.doi.from.bib.sh | Extract DOIs from .bib file to dois.txt |
| get.pdf.from.bib.doi.sh | Batch download PDFs using DOIs from a .bib file |
| get.pdf.from.bib.pmid.sh | Batch download PDFs using PMIDs (requires conda env) |
| get.bib.from.pdf.sh | Extract BibTeX from PDF metadata (via DOI + doi2bib) |

### PDF layout tools
| Script | Purpose |
|--------|---------|
| make.2x1.and.link.pdf.sh | Multi-page PDF layouts via pdfxup |
| reduce.pdf.size.sh | Reduce PDF resolution via ghostscript |
| add.page.numbers.to.pdf.sh | Add page numbers to PDF |
| calc.pdf.page.sizes.sh | Report page dimensions |
| bundle_tex_figures.sh | Bundle .tex + figures for sharing |

### Helpers
| Script | Purpose |
|--------|---------|
| get.info.for.pdf.sh | Show first lines + pdfinfo of newest PDF in /tmp |
| append.ris.to.tmp.bib.sh | Single RIS -> BibTeX, append to /tmp/tmp.bib |

## Dependencies

### Required
- Python 3.9+ with bibtexparser, rispy (pip install)
- bibutils suite: ris2xml, bib2xml, nbib2xml, end2xml, xml2bib, etc.
  (locally compiled in ~/Repositories/bibutils/bin/, symlinked to ~/bin/)

### Optional (for legacy scripts)
- Perl (for isi2bibtex, customize.bibtex.key.and.pdf.file)
- pdfxup (for PDF layout scripts)
- ghostscript (for reduce.pdf.size.sh)
- pdfinfo from poppler-utils
- doi2bib, topaper in ~/bin/
- Pubmed-Batch-Download in ~/Repositories/ (for PMID downloads)

## Backup Chain

When prepending to bibliography.full.bib:
1. Copy Bkups/bibliography.full.bib -> Bkups/bibliography.full.bkup
2. Copy bibliography.full.bib -> Bkups/bibliography.full.bib
3. Write new content + old content -> bibliography.full.bib

## Config: isi2bibtexrc

```
authorkey = 3      # full 4-digit year in key
abstract = 1       # include abstracts
header = 0         # no header comment block
titlecase = 1      # title-case titles
authorcase = 1     # title-case author names
journalcase = 1    # title-case journal names
linelength = 32760
isotitle = 1       # include ISO journal title
```

## Future Work

- Auto-download from bibliography: given a .bib with DOIs but no PDFs,
  download articles, rename, move, update file field. Partial infrastructure
  exists (download.pdfs.from.doi.sh, extract.doi.from.bib.sh).
- Interactive key/filename review before prepending to master bib file.
- Gradually replace bibutils subprocess calls with native Python libraries
  as mature alternatives become available (rispy for RIS, bibtexparser
  for BibTeX are already used; NBIB/EndNote still need bibutils).
- Search and organize papers in ~/References/ by metadata, keywords, etc.
