# Genome annotation repository for the SA26 - Bioinformatics

Genome annotation of the *Arabidopsis thaliana* accession **Altai-5** (HiFi assembly `ERR11437324_Altai-5.fa`):
transposable-element (TE) annotation, gene annotation with MAKER, quality control, functional annotation,
and a comparative/pangenome analysis against TAIR10 and other accessions with GENESPACE.

All jobs run on the IBU cluster via SLURM (`sbatch`) using the course containers in
`/data/courses/genome_annotation_resources/2026` (`$COURSEDIR`). Logs go to `logs/`, results to `output/`.

## Pipeline

| Step | Script(s) | What it does |
|------|-----------|--------------|
| 01 | `01-run_EDTA.sh` | De novo TE annotation and TE library with EDTA |
| 02 | `02-run_TEsorter_full_length_LTRs.sh` (+ course R script `03-full_length_LTRs_identity_copy.R`) | Classify intact LTR-RTs into clades (REXdb plant), plot LTR identity / insertion age |
| 03 | `03-run_TEmap.sh` | Circos-style map of TE density along the genome |
| 04 | `04-run_TEsorter_Copia_Gypsy.sh` | Extract and classify Copia/Gypsy sequences from the TE library |
| 05 | `05-RepeatMasker.sh`, `05-parseRM.pl` | Parse RepeatMasker output for TE divergence (landscape) |
| 06 | `06-runplot.sh`, `06-plot*.R` | TE landscape / summary plots |
| 07 | `07-0-run_maker.sh` → `07-1-megeGFF.sh` → `07-2-rename.sh` → `07-3-prefix.sh` | MAKER gene annotation (control files in `scripts/MAKER_control_files/`), merge GFF/FASTA, rename IDs |
| 08 | `08-protscan.sh`, `08-protplot_run.sh` | InterProScan domains, AED filtering and plots (AED distribution, Pfam) |
| 09 | `09-busco.sh`, `09-busco_plot_run.sh` | BUSCO completeness of proteins/transcripts + plots |
| 10 | `10-AGAT_stats.sh` | Gene model statistics with AGAT |
| 11 | `11-func-val.sh` | BLASTp of predicted proteins vs UniProt (Viridiplantae) and TAIR10 |
| 12 | `12-uniprot.sh` | Transfer UniProt functional annotation to the GFF/FASTA |
| 13–14 | `13-genespace_preparation.sh`, `14-genespace_run.sh` | Prepare inputs and run GENESPACE (synteny / orthology) |
| 15 | `15-run_process.sh` | Pangenome summary: core / accessory / specific genes, plots and tables |
| 16 | `16-run_fixrep.sh` | Re-draw riparian plots (Altai-5 vs TAIR10, re-oriented) |

Run the scripts in numeric order: `sbatch scripts/<NN>-<name>.sh`. Paths (`WORKDIR`, `COURSEDIR`) are hard-coded at
the top of each script; change them if you clone this elsewhere.

## Layout

```
data/     softlinks to the assembly (Altai-5) and Trinity transcriptome
scripts/  SLURM + R scripts, numbered by pipeline step
output/   results per step (01-EDTA, 02-LTR_full_length, ..., MAKER, comparisons/GENESPACE)
logs/     SLURM stdout/stderr
```

## Setup notes

Since I did the magic trick to delete the repo from the assembly course with the results, I'll be softlinking to the assembly given by this course instead.
```{bash}
ln -s /data/courses/genome_annotation_resources/2026/data/Genome_biol_students/* ./data/
```

then setup directory while cd into my directory and run the command after changing the directory
```{bash}
COURSEDIR=/data/courses/genome_annotation_resources/2026
cp "$COURSEDIR/scripts/01-run_EDTA.sh" scripts/
sbatch scripts/01-run_EDTA.sh
```


```{bash}
cp "$COURSEDIR/scripts/02-run_TEsorter_full_length_LTRs.sh" scripts/
# modify script path
sbatch scripts/02-run_TEsorter_full_length_LTRs.sh
```

R-script run in the srun session
```{bash}
srun --cpus-per-task=2 --mem-per-cpu=4GB --time=00:30:00 --partition=pshort_el8 --pty bash

WORKDIR=/data/users/iambrogetti/genome_annotation_SA26
OUTDIR="$WORKDIR/output/LTR_full_length"
cd "$OUTDIR"

apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" --pwd "$OUTDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla "$COURSEDIR/scripts/03-full_length_LTRs_identity_copy.R"
```

