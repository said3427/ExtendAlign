ExtendAlign
===============

A computational algorithm to correct the match/mismatch bias reported on end-to-end alignments of short sequences.


Usage
=====
ExtendAlign has three versions:

  - **EA-preprint:** Performs sense/antisense alignemnts and reports the number of match/mismatch of the best alignment for each query.
  - **EA-plus:** Performs only sense alignments and reports the number of match/mismatch for the best alignment for each query.
  - **EA-nobest:** Performs sense/antisense alignments and does not select the best alignent, reports all hits given by HSe-blastn.


For any version, place the sequences to be aligned (query) in fasta format into the `data/query` directory.
Place the sequences to be used as reference (subject) in fasta format into the `data/subject` directory and execute:

```
export PATH=$PATH:$(pwd)/bin
targets | xargs mk
```

Your results will be on `reports/` when the process ends.

The reports consist on a table containing the following information, separated by tabs:

```
query_name, subj_name, query_length, complete_query_seq, complete_subj_seq, total_match, total_mismatch
```

If the process is too slow for you, `split` the query files before using ExtendAlign.

Test data set
=============

A test dataset can be downloaded from:

```

```


Options
=======

`NPROC` environment variable can be specified to run multiple processes simultaneously.

```
targets | xargs env NPROC=$(grep proc /proc/cpuinfo | wc -l ) mk
```


Design considerations
=====================



Algorithm
=========



Requirements
============

  - [`blast`](ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ "Basic Local Alignment Search Tool.")

  - [`coreutils`](https://www.gnu.org/software/coreutils/coreutils.html "Basic file, shell and text manipulation utilities of the GNU operating system.")
  
  - [`execline`](http://www.skarnet.org/software/execline/ "execline is a (non-interactive) scripting language")

  - [`findutils`](https://www.gnu.org/software/findutils/ "Basic directory searching utilities of the GNU operating system.")

  - [`mk`](http://doc.cat-v.org/bell_labs/mk/mk.pdf "A successor for `make`.")

  - [`samtools`](http://www.htslib.org/download/ "Utilities for interacting with and post-processing short DNA sequence read alignments")


References
==========

Please cite as «Flores-Torres, M. *et al.* (2018) ExtendAlign: a computational algorithm to correct the match/mismatch bias reported on end-to-end alignments of short sequences».

Doubts or questions? Feel free to contact us, Dr. Fabian Flores-Jasso cfflores@inmegen.gob.mx
```

```