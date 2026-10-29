#!/bin/bash
#SBATCH --job-name=rename
#SBATCH --partition=pshort_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G
#SBATCH --time=00:20:00
#SBATCH --output=logs/07-2-%x_%j.out
#SBATCH --error=logs/07-2-%x_%j.err

COURSEDIR=/data/courses/genome_annotation_resources/2026
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"

mkdir -p "$FINALDIR/tmp"
cd "$OUTDIR"

protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"

cp "$OUTDIR/$gff" "$FINALDIR/${gff}.renamed.gff"
cp "$OUTDIR/$protein" "$FINALDIR/${protein}.renamed.fasta"
cp "$OUTDIR/$transcript" "$FINALDIR/${transcript}.renamed.fasta"
cd "$FINALDIR"

cut -f9 $FINALDIR/${gff}.renamed.gff | cut -d ';' -f1 | sed 's/ID=//g' | head

# ##gff-version 3
# ptg000341l
# augustus_masked-ptg000341l-processed-gene-0.0
# augustus_masked-ptg000341l-processed-gene-0.0-mRNA-1
# augustus_masked-ptg000341l-processed-gene-0.0-mRNA-1:1
# augustus_masked-ptg000341l-processed-gene-0.0-mRNA-1:cds
# augustus_masked-ptg000341l-processed-gene-0.1
# augustus_masked-ptg000341l-processed-gene-0.1-mRNA-1
# augustus_masked-ptg000341l-processed-gene-0.1-mRNA-1:1
# augustus_masked-ptg000341l-processed-gene-0.1-mRNA-1:2