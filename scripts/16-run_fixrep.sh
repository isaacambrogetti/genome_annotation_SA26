#!/bin/bash
#SBATCH --job-name=fix_reparian
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=logs/16-%x_%j.out
#SBATCH --error=logs/16-%x_%j.err

WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
COURSEDIR=/data/courses/genome_annotation_resources/2026
TMPDIR="$WORKDIR/output/comparisons/Annotation_R_tmp"
GENESPACE_DIR="$WORKDIR/output/comparisons/GENESPACE"
GENESPACE_SIF="$COURSEDIR/containers/genespace_latest.sif"

mkdir -p "$TMPDIR"

apptainer exec --cleanenv \
    --bind /data --bind "$WORKDIR" \
    --bind "$TMPDIR":/temp --env TMPDIR=/temp --pwd "$WORKDIR" \
    "$GENESPACE_SIF" Rscript "$WORKDIR/scripts/16-fix_reparian.R"