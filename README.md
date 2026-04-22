## ONTPreProcess
### A workflow for preprocessing of ONT (Nanopore) raw reads.

### Currently designed to: 
  a) Quality filter using [nanoq](https://github.com/esteinig/nanoq) \
  b) Remove host reads using [mimimap2](https://github.com/lh3/minimap2) \
  b) Subsample using [seqtk](https://github.com/lh3/seqtk) \
  c) Trim adapters using [porechop](https://github.com/rrwick/porechop) \
  d) Generate a summary report using [nanoq](https://github.com/esteinig/nanoq)

Minimum read length, quality, and subsampling depth are currently set to 300bp, Q=12, and 60,000 reads, respectively. Values can be adjusted directly in the Snakefile for variable processing. For the removal of host reads, the workflow assumes a local directory `refs` with a `refs/host.fasta` file present.

### Suggested usage: 
1. Clone repo to desired workspace. 
2. Create conda environment using provided environment file. 
3. Run workflow by activating Snakemake with the desired number of `--cores`
