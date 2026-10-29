#!/bin/bash
#SBATCH --job-name=interproscan
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/08-%x_%j.out
#SBATCH --error=logs/08-%x_%j.err

COURSEDIR=/data/courses/genome_annotation_resources/2026
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"

protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"

prefix="ALT"
INTERPROSCAN_SIF="$COURSEDIR/containers/InterProScan_5.70.sif"

cd "$FINALDIR"

apptainer exec --cleanenv --pwd "$FINALDIR" --bind $COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data --bind "$COURSEDIR" --bind "$WORKDIR" --bind "$FINALDIR/tmp":/temp \
    "$INTERPROSCAN_SIF" /opt/interproscan/interproscan.sh \
    -appl pfam --disable-precalc -f TSV \
    --goterms --iprlookup --seqtype p \
    -i ${protein}.renamed.fasta -o output.iprscan

apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$MAKER_SIF" ipr_update_gff ${gff}.renamed.gff output.iprscan > ${gff}.renamed.iprscan.gff