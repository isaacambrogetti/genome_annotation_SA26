#!/bin/bash
#SBATCH --job-name=protscan_plots
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=logs/08-%x_%j.out
#SBATCH --error=logs/08-%x_%j.err

set -euo pipefail

WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
FINALDIR="$WORKDIR/output/MAKER/final"
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

mkdir -p "$FINALDIR/plots"

# Cumulative AED distribution
apptainer exec --cleanenv \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" \
    "$ANALYSIS_SIF" \
    Rscript "$WORKDIR/scripts/08-plot_AED_cumdist.R" "$FINALDIR"

# AED distribution split by Pfam presence
apptainer exec --cleanenv \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" \
    "$ANALYSIS_SIF" \
    Rscript "$WORKDIR/scripts/08-plot_AED_Pfam.R" "$FINALDIR"

echo "Finished. Plots saved in $FINALDIR/plots"
