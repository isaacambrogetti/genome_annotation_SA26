# Genome annotation repository for the SA26 - Bioinformatics

Since I did the magic trick to delete the repo from the assembly course with the results, I'll be softlinking to the assembly given by this course instead.
```
ln -s /data/courses/genome_annotation_resources/2026/data/Genome_biol_students/* ./data/
```

then setup directory while cd into my directory:
```
COURSEDIR=/data/courses/genome_annotation_resources/2026
cp "$COURSEDIR/scripts/01-run_EDTA.sh" scripts/
```

```
cp "$COURSEDIR/scripts/02-run_TEsorter_full_length_LTRs.sh" scripts/
```