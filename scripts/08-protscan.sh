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

# step 1 - renaming
# 07-02-rename.sh and 07-03-prefix.sh

echo "step 2 - beginning InterProScan"
# step 2 -  Run InterProScan on the Protein File
# apptainer exec --cleanenv --pwd "$FINALDIR" --bind $COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data --bind "$COURSEDIR" --bind "$WORKDIR" --bind "$FINALDIR/tmp":/temp \
#    "$INTERPROSCAN_SIF" /opt/interproscan/interproscan.sh \
#    -appl pfam --disable-precalc -f TSV \
#    --goterms --iprlookup --seqtype p \
#    -i ${protein}.renamed.fasta -o output.iprscan

echo "step 3 - beginning updating GFF"
# step 3 - Update GFF with InterProScan Results
#apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$MAKER_SIF" ipr_update_gff ${gff}.renamed.gff output.iprscan > ${gff}.renamed.iprscan.gff

echo "step 4 - beginning examine AED values"
# step 4 - Examine AED Values ##TORUN
apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$MAKER_SIF" perl /usr/local/bin/AED_cdf_generator.pl -b 0.025 ${gff}.renamed.gff > assembly.all.maker.renamed.gff.AED.txt

## plot the cumulative AED distribution using R ##

echo "step 5 - beginning GFF filtering for quality"
# step 5 - Filter the GFF File for Quality
apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$MAKER_SIF" perl /usr/local/bin/quality_filter.pl -s ${gff}.renamed.iprscan.gff > ${gff}_iprscan_quality_filtered.gff

echo "step 6 - beginning GFF filtering for Gene Features"
# step 6 - Filter the GFF File for Gene Features
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" ${gff}_iprscan_quality_filtered.gff > filtered.genes.renamed.gff3
sed -i '1i##gff-version 3' filtered.genes.renamed.gff3

echo "\n Check if the filtering worked"
cut -f3 filtered.genes.renamed.gff3 | sort | uniq
echo "-----------------------------------------"

echo "step 7 - beginning extracting remaining mRNA seq"
# step 7 - Extract the remaining mRNA Sequences after filtering
grep -P "\tmRNA\t" filtered.genes.renamed.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > list.txt
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

apptainer exec --cleanenv --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$ANALYSIS_SIF" seqkit grep -f list.txt ${transcript}.renamed.fasta -o ${transcript}.renamed.filtered.fasta
apptainer exec --cleanenv --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$ANALYSIS_SIF" seqkit grep -f list.txt ${protein}.renamed.fasta -o ${protein}.renamed.filtered.fasta

# The final annotation outputs in $FINALDIR are:
# - filtered.genes.renamed.gff3: filtered gene models and their subfeatures.
# - ${protein}.renamed.filtered.fasta: protein sequences for the retained models.
# - ${transcript}.renamed.filtered.fasta: transcript sequences for the retained models