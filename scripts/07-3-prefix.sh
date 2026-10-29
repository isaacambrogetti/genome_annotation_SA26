#!/bin/bash
#SBATCH --job-name=prefix
#SBATCH --partition=pshort_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G
#SBATCH --time=00:20:00
#SBATCH --output=logs/07-3-%x_%j.out
#SBATCH --error=logs/07-3-%x_%j.err

COURSEDIR=/data/courses/genome_annotation_resources/2026
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"

protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"

prefix="ALT" # Replace with your accession prefix/short name.

cd "$FINALDIR"

apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$MAKER_SIF" maker_map_ids --prefix $prefix --justify 7 ${gff}.renamed.gff > id.map
apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$MAKER_SIF" map_gff_ids id.map ${gff}.renamed.gff
apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$MAKER_SIF" map_fasta_ids id.map ${protein}.renamed.fasta
apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$MAKER_SIF" map_fasta_ids id.map ${transcript}.renamed.fasta