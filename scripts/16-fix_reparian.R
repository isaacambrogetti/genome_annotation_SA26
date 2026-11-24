library(GENESPACE)

wd <-"/data/users/iambrogetti/genome_annotation_SA26/output/comparisons/GENESPACE"
focal_genome <-"Altai_5"

load(file.path(wd,"results","gsParams.rda")) # Loads gsParam.
dir.create(file.path(wd,"processed_riparian"), showWarnings = FALSE)

plot_riparian(gsParam, genomeIDs = c("TAIR10", focal_genome), refGenome ="TAIR10",reorderBySynteny = TRUE, pdfFile = file.path(wd,"processed_riparian", "Altai_5_vs_TAIR10.pdf"))

flips <- data.frame(genome = focal_genome, chr ="Altai_5")
plot_riparian(gsParam, genomeIDs = c("TAIR10", focal_genome), refGenome = "TAIR10", reorderBySynteny = TRUE, syntenyWeight = 1, invertTheseChrs = flips, pdfFile = file.path(wd, "processed_riparian", "Altai_5_vs_TAIR10_oriented.pdf"))

plot_riparian(gsParam, refGenome ="TAIR10", reorderBySynteny = TRUE, syntenyWeight = 1, invertTheseChrs = flips, scalePlotWidth = 1.5, pdfFile = file.path(wd, "processed_riparian", "all_genomes_TAIR10.pdf"))