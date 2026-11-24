#!/bin/bash
#SBATCH --job-name=gs_prep
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=logs/13-%x_%j.out
#SBATCH --error=logs/13-%x_%j.err


Accession=Altai_5
WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
COURSEDIR=/data/courses/genome_annotation_resources/2026
FINALDIR="$WORKDIR/output/MAKER/final"
GENES="$FINALDIR/filtered.genes.renamed.gff3"
OUTDIR="$WORKDIR/output/comparisons"
GENESPACE_DIR="$OUTDIR/GENESPACE"

cd $WORKDIR

mkdir -p "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide" "$GENESPACE_DIR/tmp"

grep -P "\tgene\t" "$GENES" > "$GENESPACE_DIR/tem_enes.gff3"

# Get the the first attribute in column 9 which is ID=gene_name.
awk 'BEGIN{OFS="\t"} {split($9,a,";"); split(a[1],b,"="); print $1, $4-1, $5, b[2]}' \
    "$GENESPACE_DIR/tem_enes.gff3" > "$GENESPACE_DIR/bed/${Accession}.bed"

LONGEST_PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.longest.fasta"

# Remove transcript suffixes and descriptions from FASTA headers.
sed '/^>/s/ .*//' "$LONGEST_PROTEINS" | sed '/^>/s/-R[A-Z]*$//' > "$GENESPACE_DIR/peptide/${Accession}.fa"

# add TAIR10
cp "$COURSEDIR/data/TAIR10.bed" "$GENESPACE_DIR/bed/TAIR10.bed"
cp "$COURSEDIR/data/TAIR10.fa" "$GENESPACE_DIR/peptide/TAIR10.fa"


other=Est_0
cp "$COURSEDIR/data/Lian_et_al/GENESPACE/bed/${other}.bed" \
    "$GENESPACE_DIR/bed/${other}.bed"
cp "$COURSEDIR/data/Lian_et_al/GENESPACE/peptide/${other}.fa" \
    "$GENESPACE_DIR/peptide/${other}.fa"

other=Ice_1
cp "$COURSEDIR/data/Lian_et_al/GENESPACE/bed/${other}.bed" \
    "$GENESPACE_DIR/bed/${other}.bed"
cp "$COURSEDIR/data/Lian_et_al/GENESPACE/peptide/${other}.fa" \
    "$GENESPACE_DIR/peptide/${other}.fa"

other=Are_6
cp "$COURSEDIR/data/Lian_et_al/GENESPACE/bed/${other}.bed" \
    "$GENESPACE_DIR/bed/${other}.bed"
cp "$COURSEDIR/data/Lian_et_al/GENESPACE/peptide/${other}.fa" \
    "$GENESPACE_DIR/peptide/${other}.fa"