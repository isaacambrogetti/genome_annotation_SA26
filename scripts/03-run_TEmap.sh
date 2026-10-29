#!/bin/bash
#SBATCH --job-name=TE_circos
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=begin,end
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-21
#SBATCH --output=logs/03-%x_%j.out
#SBATCH --error=logs/03-%x_%j.err

set -euo pipefail

# Use the EDTA LTR annotation and the assembly from this project.
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/iambrogetti/genome_annotation_SA26
CONTAINER="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
GENOME="$WORKDIR/data/ERR11437324_Altai-5.fa"
GFF="$WORKDIR/output/EDTA/ERR11437324_Altai-5.fa.mod.EDTA.raw/LTR/ERR11437324_Altai-5.fa.mod.pass.list.gff3"
OUTDIR="$WORKDIR/output/03-TE_map"

for input in "$GENOME" "$GFF" "$CONTAINER"; do
    if [[ ! -e "$input" ]]; then
        echo "Required input does not exist: $input" >&2
        exit 1
    fi
done

mkdir -p "$OUTDIR"

# The course R script expects a text FASTA index and fixed input filenames.
FAI="$GENOME.fai"
if [[ ! -s "$FAI" ]]; then
    apptainer exec -C \
        --bind "$WORKDIR" --bind "$COURSEDIR" \
        "$CONTAINER" samtools faidx "$GENOME"
fi

ln -sfn "$GFF" "$OUTDIR/assembly.fasta.mod.EDTA.TEanno.gff3"
ln -sfn "$FAI" "$OUTDIR/assembly.fasta.fai"

cd "$OUTDIR"
apptainer exec -C \
    --bind "$WORKDIR" --bind "$COURSEDIR" \
    --pwd "$OUTDIR" "$CONTAINER" \
    Rscript --vanilla "$COURSEDIR/scripts/04-annotation_circlize.R"
