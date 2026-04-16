import os

SAMPLES = glob_wildcards("data/{sample}.fastq.gz").sample

if not SAMPLES:
    raise ValueError("No input FASTQ files found in data/. Place your *.fastq.gz files in the data/ directory, please!")

rule all:
    input:
        expand("results/{sample}.final.fastq.gz", sample=SAMPLES)

rule porechop:
    input:
        "data/{sample}.fastq.gz"
    output:
        temp("work/porechop/{sample}.trimmed.fastq.gz")
    shell:
        "porechop -i {input} -o {output} --threads {threads}"

rule nanoq:
    input:
        trimmed="work/porechop/{sample}.trimmed.fastq.gz"
    output:
        filtered=temp("work/nanoq/{sample}.filtered.fastq.gz")
    shell:
        "nanoq -i {input.trimmed} -o {output.filtered} --min-len 500 --min-qual 10"

rule seqtk:
    input:
        "work/nanoq/{sample}.filtered.fastq.gz"
    output:
        "results/{sample}.final.fastq.gz"
    shell:
        "seqtk sample -s 11 {input} 60000 | gzip -c > {output}"
