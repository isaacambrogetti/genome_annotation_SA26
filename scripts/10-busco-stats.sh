#!/bin/bash
#SBATCH --job-name=agat_stats
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=00:30:00
#SBATCH --output=logs/10-%x_%j.out
#SBATCH --error=logs/10-%x_%j.err

set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
AGAT_SIF="$COURSEDIR/containers/AGAT_v1.4.1.sif"

cd "$FINALDIR"

apptainer exec --cleanenv \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" \
    "$AGAT_SIF" \
    agat_sp_statistics.pl \
    --gff filtered.genes.renamed.gff3 \
    --output annotation.stat
