#!/bin/bash
#SBATCH --job-name=BUSCO_plots
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --output=logs/10-%x_%j.out
#SBATCH --error=logs/10-%x_%j.err

set -euo pipefail

WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
FINALDIR="$WORKDIR/output/MAKER/final"
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

mkdir -p "$FINALDIR/plots"

apptainer exec --cleanenv \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" \
    "$ANALYSIS_SIF" \
    Rscript "$WORKDIR/scripts/09-busco_plot.R" "$FINALDIR"

echo "Finished. BUSCO plot saved in $FINALDIR/plots"
