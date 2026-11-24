#!/bin/bash
#SBATCH --job-name=proc_pang
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=logs/15-%x_%j.out
#SBATCH --error=logs/15-%x_%j.err

WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
COURSEDIR=/data/courses/genome_annotation_resources/2026
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
TMPDIR="$WORKDIR/output/comparisons/Annotation_R_tmp"

mkdir -p "$TMPDIR"

apptainer exec --cleanenv \
    --bind /data --bind "$WORKDIR" \
    --bind "$TMPDIR":/temp --env TMPDIR=/temp --pwd "$WORKDIR" \
    "$ANALYSIS_SIF" Rscript "$WORKDIR/scripts/15-process_pangenome.R"