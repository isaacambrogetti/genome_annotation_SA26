#!/bin/bash
#SBATCH --job-name=uniprot_func
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=logs/12-%x_%j.out
#SBATCH --error=logs/12-%x_%j.err

set -euo pipefail

FINALDIR="$WORKDIR/output/MAKER/final"
PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
UNIPROT="$COURSEDIR/data/uniprot_viridiplantae_reviewed.fa"
OUTDIR="$WORKDIR/output/comparisons"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
GENES="$FINALDIR/filtered.genes.renamed.gff3"

apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind /data --bind "$WORKDIR" \
    --bind "$OUTDIR/tmp":/tmp \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    maker_functional_fasta "$UNIPROT" "$OUTDIR/blast_uniprot.besthits.tsv" "$PROTEINS" \
    > "$OUTDIR/maker_roteins.filtered.Uniprot.fasta"

apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind /data --bind "$WORKDIR" \
    --bind "$OUTDIR/tmp":/tmp \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    maker_functional_ff "$UNIPROT" "$OUTDIR/blast_uniprot.besthits.tsv" "$GENES" \
    > "$OUTDIR/filtered.genes.Uniprot.gff3"