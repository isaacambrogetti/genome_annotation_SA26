# Genome annotation repository for the SA26 - Bioinformatics

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

