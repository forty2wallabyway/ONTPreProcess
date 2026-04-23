import os
import glob

# -----------------------------
# Inputs
# -----------------------------
SAMPLES = glob_wildcards("data/{sample}.fastq.gz").sample
if not SAMPLES:
    raise ValueError("No input files found. Place your *.fastq.gz files in the data/ directory, please!")

# -----------------------------
# Host reference
# -----------------------------
HOST_FASTA = "refs/host.fasta"
HOST_INDEX = "refs/host.mmi"

if not os.path.exists(HOST_FASTA):
    raise ValueError(
        f"Host reference not found at {HOST_FASTA}. "
        "Add your host fasta there, or change HOST_FASTA in the Snakefile."
    )

# -----------------------------
# Final targets
# -----------------------------
rule all:
    input:
        expand("results/{sample}.final.fastq.gz", sample=SAMPLES),
        expand("reports/{sample}.report.txt", sample=SAMPLES)

# -----------------------------
# Step 0: Build minimap2 index
# -----------------------------
rule host_index:
    input:
        HOST_FASTA
    output:
        HOST_INDEX
    threads: 2
    shell:
        "minimap2 -d {output} {input}"

# -----------------------------
# Step 1: Filter reads
# -----------------------------
rule filter:
    input:
        "data/{sample}.fastq.gz"
    output:
        temp("work/nanoq/{sample}.filtered.fastq.gz")
    threads: 1
    shell:
        "nanoq -i {input} -o {output} --min-len 300 --min-qual 12"

# -----------------------------
# Step 2: Host removal (NEW)
# Keep only reads that do NOT map to host
# -----------------------------
rule host_remove:
    input:
        reads="work/nanoq/{sample}.filtered.fastq.gz",
        index=HOST_INDEX
    output:
        temp("work/host_removed/{sample}.filtered.nohost.fastq.gz")
    threads: 8
    shell:
        r"""
        minimap2 -t {threads} -ax map-ont {input.index} {input.reads} \
          | samtools view -@ {threads} -b -f 4 - \
          | samtools fastq -@ {threads} - \
          | gzip -c > {output}
        """

# -----------------------------
# Step 3: Subsample
# -----------------------------
rule subsample:
    input:
        "work/host_removed/{sample}.filtered.nohost.fastq.gz"
    output:
        temp("work/seqtk/{sample}.filtered.nohost.subsampled.fastq.gz")
    threads: 1
    shell:
        "seqtk sample -s 11 {input} 60000 | gzip -c > {output}"

# -----------------------------
# Step 4: Trim adapters
# -----------------------------
rule trim:
    input:
        "work/seqtk/{sample}.filtered.nohost.subsampled.fastq.gz"
    output:
        "results/{sample}.final.fastq.gz"
    threads: 4
    shell:
        "porechop -i {input} -o {output} --threads {threads}"

# -----------------------------
# Step 5: Report
# -----------------------------
rule report:
    input:
        "results/{sample}.final.fastq.gz"
    output:
        "reports/{sample}.report.txt"
    threads: 1
    shell:
        "nanoq -i {input} -s -vvv > {output}"
