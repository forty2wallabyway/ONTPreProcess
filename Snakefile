import os

SAMPLES = glob_wildcards("data/{sample}.fastq.gz").sample

if not SAMPLES:
    raise ValueError("No input FASTQ files found in data/. Place your *.fastq.gz files in the data/ directory.")

rule all:
    input:
        expand("results/{sample}.final.fasta.gz", sample=SAMPLES),
        expand("results/{sample}.nanoq.json", sample=SAMPLES)

rule porechop:
    input:
        "data/{sample}.fastq.gz"
    output:
        temp("work/porechop/{sample}.trimmed.fastq.gz")
    threads: 4
    conda:
        "envs/porechop.yaml"
    shell:
        "porechop -i {input} -o {output} --threads {threads}"

rule nanoq:
    input:
        trimmed="work/porechop/{sample}.trimmed.fastq.gz"
    output:
        filtered=temp("work/nanoq/{sample}.filtered.fastq.gz"),
        report="results/{sample}.nanoq.json"
    conda:
        "envs/nanoq.yaml"
    shell:
        "nanoq -i {input.trimmed} -o {output.filtered} -j -r {output.report} --min-len 500 --min-qual 10"

rule seqtk:
    input:
        "work/nanoq/{sample}.filtered.fastq.gz"
    output:
        "results/{sample}.final.fasta.gz"
    conda:
        "envs/seqtk.yaml"
    shell:
        "seqtk seq -A {input} | gzip -c > {output}"
