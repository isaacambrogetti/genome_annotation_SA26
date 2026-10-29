# Genome Annotation

I took 01-EDTA from Sara because my run hadn't finished and I haven't realized, I though I had all the necessary files.

## Week 1
Transposable elements (TEs) fall into two main classes based on how they move within the genome. Class I
elements, or retrotransposons, use an RNA intermediate to “copy and paste” themselves, increasing their copy
number. We're interested in them, especially Copia and Gypsy which are LTR retrotransposons, we want to identify the conserved TE protein domains to classify the elements and assign them to their respective superfamilies (clades).

### EDTA
Extensive de novo TE Annotator (EDTA) is a pipeline designed for the annotation of both structurally intact and
fragmented TEs. It generates a non-redundant TE library, classifies the elements into superfamilies, and outputs
annotations in GFF3 format.

Outputs are in `01-EDTA``

#### TEsorter
Visualize the TE annotation. focusing on the structure-based annotation of full-length LTR retrotransposons (LTR-RTs).

**Percent identity** is a measure of similarity between two DNA sequences. In the case of Long Terminal Repeats
(LTRs) of retrotransposons, it reflects the evolutionary divergence between the two flanking LTRs. Initially, LTR
retrotransposons contain two identical LTRs surrounding an internal coding region. Over time, these LTRs
accumulate mutations, and as a result, the percent identity between them decreases.
Thus, by analyzing the percent identity of LTR sequences within a retrotransposon, we can infer the relative age of
the element and date their insertion.

Steps:
1. Extract Percent identity of two LTRs from full length LTR-RTs
    - Use the intact GFF3 under output/EDTA/assembly.fasta.mod.EDTA.raw/, together with its matching assembly.fasta.mod.LTR.intact.raw.fa.
    - we use the REXdb plant database (Zhang et al., 2022) to assign Copia and Gypsy retrotransposons to evolutionary clades
2. Refine TE classification for full length LTR-RTs and split them into Clades using TEsorter which classify TEs based on their protein domains

3. Plot LTR-RT identity by clade and globally for Copia versus Gypsy
    - use given R script that reads `intact_LTR.gff3 and intact_LTR.fa.rexdb-plant.cls.tsv` and creates 2 comparison plots.

results are at global and at clade level.

> Are there differences in the number of full length LTR-RTs between the clades?

[Full-length LTRs for all clades pooled](/genome_annotation_SA26/output/02-LTR_full_length/plots/02_LTR_Copia_Gypsy_global.pdf)



> Are there any clades with High percent identity (e.g., 99-100%) or relatively younger insertions and Low
percent identity (e.g., 80-90%) or relatively older insertions?





## Week 3

### MAKER pipeline

MAKER is a genome annotation pipeline designed for eukaryotic genomes. It integrates multiple sources of
evidence—ab initio prediction models, RNA-Seq data, and protein homology—to generate gene annotations.

1. Ab Initio Gene Prediction:
Tools like Augustus and GeneMark predict gene structures based on sequence patterns (e.g., start
codons, splice sites).
2. RNA-Seq Data:
Provide evidence for transcribed regions, exon boundaries and splice junctions. Their usefulness
depends on transcript completeness, sequencing coverage and the tissues sampled.
3. Protein Homology-Based Annotation:
Uses known protein sequences from related species to predict gene structures.
Tools like BLAST, Exonerate, and GenomeThreader identify conserved genes by aligning transcripts
and known proteins to the genome.
4. Final Gene Model Refinement:
Manual curation or additional refinement to produce high-quality gene models.

```{bash}
COURSEDIR=/data/courses/genome_annotation_resources/2026
cd /data/users/iambrogetti/genome_annotation_SA26/
mkdir scripts/MAKER_control_files
cp "$COURSEDIR/tools/MAKER/control_files/"maker_{opts,bopts,exe,evm}.ctl scripts/MAKER_control_files
```

cp "$COURSEDIR/scripts/XX-run_maker.sh" scripts/