#!/bin/bash
#SBATCH --job-name=maker_GFF_merge
#SBATCH --partition=pshort_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --output=logs/07-%x_%j.out
#SBATCH --error=logs/07-%x_%j.err

COURSEDIR=/data/courses/genome_annotation_resources/2026
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
OUTDIR="$WORKDIR/output/MAKER"


mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"

shopt -s nullglob

INDEXES=(*.maker.output/*_master_datastore_index.log)
test "${#INDEXES[@]}" -eq 1
INDEX="${INDEXES[0]}"

apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$OUTDIR" "$MAKER_SIF" gff3_merge -d "$INDEX" -o assembly.all.maker.gff

apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$OUTDIR" "$MAKER_SIF" gff3_merge -n -d "$INDEX" -o assembly.all.maker.noseq.gff

apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$OUTDIR" "$MAKER_SIF" fasta_merge -d "$INDEX" -o assembly
