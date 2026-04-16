import os
import glob

SAMPLES = glob_wildcards("data/{sample}.fastq.gz").sample

if not SAMPLES:
    raise ValueError("No input files found. Place your *.fastq.gz files in the data/ directory, please!")

rule all:
    input:
        expand("results/{sample}.final.fastq.gz", sample=SAMPLES)

rule nanoq:
    input:
        "data/{sample}.fastq.gz"
    output:
        temp("work/nanoq/{sample}.filtered.fastq.gz")
    shell:
        "nanoq -i {input} -o {output} --min-len 500 --min-qual 12"

rule seqtk:
    input:
        temp("work/nanoq/{sample}.filtered.fastq.gz")
    output:
        temp("work/seqtk/{sample}.filtered.subsampled.fastq.gz")
    shell:
        "seqtk sample -s 11 {input} 60000 | gzip -c > {output}"

rule porechop:
    input:
        temp("work/seqtk/{sample}.filtered.subsampled.fastq.gz")
    output:
        "results/{sample}.final.fastq.gz"
    shell:
        "porechop -i {input} -o {output} --threads 4"

rule report:
    input:
        "results/{sample}.final.fastq.gz"
    output:
        "reports/{sample}.report.txt"
    shell:
        "nanoq {input} -s -r -vvv > {output}"