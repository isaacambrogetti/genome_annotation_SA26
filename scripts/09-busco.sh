#!/bin/bash
#SBATCH --job-name=busco
#SBATCH --partition=pshort_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/09-%x_%j.out
#SBATCH --error=logs/09-%x_%j.err

set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR="/data/users/iambrogetti/genome_annotation_SA26"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"

protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"

cd "$FINALDIR"

extract_longest_per_gene() {
    local input=$1
    local output=$2

    [[ -f "$input" ]] || {
        echo "Input FASTA not found: $input" >&2
        exit 1
    }

    awk '
        function save_record(    id, gene, n) {
            if (header == "")
                return

            id = header
            sub(/^>/, "", id)
            sub(/[[:space:]].*$/, "", id)
            gene = id
            sub(/-R.*/, "", gene)
            n = length(sequence)

            if (!(gene in order)) {
                order[gene] = ++count
                genes[count] = gene
            }
            if (!(gene in best_length) || n > best_length[gene]) {
                best_length[gene] = n
                best_header[gene] = header
                best_sequence[gene] = sequence
            }
        }

        /^>/ {
            save_record()
            header = $0
            sequence = ""
            next
        }

        {
            sequence = sequence $0
        }

        END {
            save_record()
            for (i = 1; i <= count; i++) {
                gene = genes[i]
                print best_header[gene]
                print best_sequence[gene]
            }
        }
    ' "$input" > "$output"
}

extract_longest_per_gene \
    "${protein}.renamed.filtered.fasta" \
    "${protein}.renamed.longest.fasta"
extract_longest_per_gene \
    "${transcript}.renamed.filtered.fasta" \
    "${transcript}.renamed.longest.fasta"

module load BUSCO/5.4.2-foss-2021a
export PYTHONNOUSERSITE=1

# Run BUSCO on the longest protein and transcript sequences.
busco -i "${protein}.renamed.longest.fasta" \
    -l brassicales_odb10 -o busco_proteins -m proteins -c 8
busco -i "${transcript}.renamed.longest.fasta" \
    -l brassicales_odb10 -o busco_transcripts -m transcriptome -c 8
