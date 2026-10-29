#!/bin/bash
#SBATCH --job-name=plotting
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=logs/07-%x_%j.out
#SBATCH --error=logs/07-%x_%j.err

WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
COURSEDIR="/data/courses/genome_annotation_resources/2026"

# derived paths
CONTAINER="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

mkdir -p "$WORKDIR/output/06-plots"

apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" "$CONTAINER" \
    Rscript "$WORKDIR/scripts/06-plot_a.R"

apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" "$CONTAINER" \
    Rscript "$WORKDIR/scripts/06-plot.R"