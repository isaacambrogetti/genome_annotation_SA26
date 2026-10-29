#!/bin/bash
#SBATCH --job-name=TEsorter_Copia_Gypsy
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=logs/04-%x_%j.out
#SBATCH --error=logs/04-%x_%j.err

set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/iambrogetti/genome_annotation_SA26
GENOME="ERR11437324_Altai-5.fa"
OUTDIR="$WORKDIR/output/04-Extraction"

# creating output directory
mkdir -p $OUTDIR

# Extract Copia sequences
apptainer exec -C --bind "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  seqkit grep -r -p "Copia" "$WORKDIR/output/01-EDTA/${GENOME}.mod.EDTA.TElib.fa" \
  > $OUTDIR/Copia_sequences.fa

# Extract Gypsy sequences
apptainer exec -C --bind "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  seqkit grep -r -p "Gypsy" "$WORKDIR/output/01-EDTA/${GENOME}.mod.EDTA.TElib.fa" \
  > $OUTDIR/Gypsy_sequences.fa

# Refining TE Classification of all TE sequences
apptainer exec --bind $WORKDIR /data/courses/genome_annotation_resources/2026/containers/TEsorter_1.3.0.sif
TEsorter $OUTDIR/Copia_sequences.fa -db rexdb-plant -p 4

apptainer exec --bind $WORKDIR /data/courses/genome_annotation_resources/2026/containers/TEsorter_1.3.0.sif
TEsorter $OUTDIR/Gypsy_sequences.fa -db rexdb-plant -p 4