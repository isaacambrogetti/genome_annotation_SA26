args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1)
finaldir <- args[1]

plotdir <- file.path(finaldir, "plots")
dir.create(plotdir, recursive = TRUE, showWarnings = FALSE)

gff <- read.delim(
  file.path(finaldir, "assembly.all.maker.noseq.gff.renamed.gff"),
  header = FALSE, sep = "\t", comment.char = "#",
  quote = "", stringsAsFactors = FALSE
)

get_attribute <- function(x, key) {
  pattern <- paste0("(^|;)", key, "=([^;]*)")
  vapply(x, function(a) {
    hit <- regmatches(a, regexec(pattern, a))[[1]]
    if (length(hit) == 0) NA_character_ else hit[3]
  }, character(1))
}

attributes <- gff[gff$V3 == "mRNA", 9]

models <- data.frame(
  id = get_attribute(attributes, "ID"),
  AED = suppressWarnings(as.numeric(get_attribute(attributes, "_AED")))
)

models <- models[
  !is.na(models$id) &
    is.finite(models$AED) &
    models$AED >= 0 &
    models$AED <= 1,
]

if (nrow(models) == 0) stop("No mRNA features with valid _AED values.")

protein_headers <- readLines(
  file.path(finaldir, "assembly.all.maker.proteins.fasta.renamed.fasta")
)
protein_ids <- sub(
  "^>(\\S+).*", "\\1",
  protein_headers[startsWith(protein_headers, ">")]
)

models <- models[models$id %in% protein_ids, ]
if (nrow(models) == 0) {
  stop("No matching IDs between GFF mRNAs and protein FASTA.")
}

ipr_lines <- readLines(file.path(finaldir, "output.iprscan"))
ipr_fields <- strsplit(ipr_lines[nzchar(ipr_lines)], "\t", fixed = TRUE)

pfam_ids <- unique(vapply(
  Filter(function(x) length(x) >= 4 && x[4] == "Pfam", ipr_fields),
  function(x) x[1], character(1)
))

if (length(pfam_ids) > 0 && !any(models$id %in% pfam_ids)) {
  stop("Pfam IDs do not match GFF mRNA IDs; check naming.")
}

models$Pfam <- models$id %in% pfam_ids

write.csv(
  models,
  file.path(plotdir, "AED_Pfam_per_model.csv"),
  row.names = FALSE
)

colors <- c("With Pfam" = "#238B45", "Without Pfam" = "#756BB1")
groups <- ifelse(models$Pfam, "With Pfam", "Without Pfam")

pdf(file.path(plotdir, "04_AED_by_Pfam.pdf"), width = 7, height = 5)

plot(
  NA, xlim = c(0, 1), ylim = c(0, 1),
  xlab = "Annotation Edit Distance (AED)",
  ylab = "Cumulative proportion within group",
  main = "AED distribution by Pfam presence"
)

labels <- character()
legend_colors <- character()

for (group in names(colors)) {
  values <- models$AED[groups == group]
  if (length(values) > 0) {
    plot(
      ecdf(values), add = TRUE,
      verticals = TRUE, do.points = FALSE,
      col = colors[group], lwd = 2
    )
    labels <- c(labels, sprintf("%s (n = %d)", group, length(values)))
    legend_colors <- c(legend_colors, colors[group])
  }
}

abline(v = 0.5, lty = 2, col = "grey60")
legend("bottomright", legend = labels, col = legend_colors,
       lwd = 2, bty = "n")
dev.off()

models$AED_group <- ifelse(
  models$AED < 0.5, "Low AED (<0.5)", "High AED (>=0.5)"
)

summary_table <- do.call(rbind, lapply(
  c("Low AED (<0.5)", "High AED (>=0.5)"),
  function(group) {
    x <- models[models$AED_group == group, ]
    data.frame(
      AED_group = group,
      total = nrow(x),
      with_Pfam = sum(x$Pfam),
      percent_Pfam = if (nrow(x) > 0) 100 * mean(x$Pfam) else NA_real_
    )
  }
))

write.csv(
  summary_table,
  file.path(plotdir, "Pfam_by_AED_summary.csv"),
  row.names = FALSE
)

available <- summary_table[summary_table$total > 0, ]

pdf(file.path(plotdir, "05_Pfam_presence_by_AED.pdf"),
    width = 7, height = 5)

positions <- barplot(
  available$percent_Pfam,
  names.arg = available$AED_group,
  ylim = c(0, 110),
  col = "#4682B4",
  ylab = "Proteins with a Pfam hit (%)",
  main = "Pfam support in low- and high-AED models"
)

text(
  positions, available$percent_Pfam + 4,
  labels = sprintf("%.1f%% (n=%d)",
                   available$percent_Pfam, available$total)
)
dev.off()
