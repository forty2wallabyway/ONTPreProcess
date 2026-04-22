## ONTPreProcess
### A workflow for preprocessing of ONT (Nanopore) raw reads.

### Currently designed to: 
  a) Quality filter using nanoq \
  b) Remove non-target (e.g., host) reads using mimimap2 \
  b) Subsample using seqtk \
  c) Trim adapters using porechop \
  d) Generate a summary report using nanoq

Minimum read length, quality, and subsampling depth are currently set to 300bp, 12, and 60,000, respectively. Values can be adjusted directly in the Snakefile for variable processing. For the removal of non-target reads, the workflow assumes a local directory `refs` with a `refs/host.fasta` file present.

### Suggested usage: 
1. Clone repo to desired workspace. 
2. Create conda environment using provided environment file. 
3. Run workflow by activating Snakemake with the desired number of `--cores`
