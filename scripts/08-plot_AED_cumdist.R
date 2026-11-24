args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1)

finaldir <- args[1]
plotdir <- file.path(finaldir, "plots")

dir.create(plotdir, recursive = TRUE, showWarnings = FALSE)

# Read the renamed, unfiltered annotation
gff <- read.delim(
  file.path(finaldir, "assembly.all.maker.noseq.gff.renamed.gff"),
  header = FALSE,
  sep = "\t",
  comment.char = "#",
  quote = "",
  stringsAsFactors = FALSE
)

# Extract transcript IDs and AED values
get_attribute <- function(x, key) {
  pattern <- paste0("(^|;)", key, "=([^;]*)")

  vapply(x, function(attribute) {
    hit <- regmatches(
      attribute,
      regexec(pattern, attribute)
    )[[1]]

    if (length(hit) == 0) NA_character_ else hit[3]
  }, character(1))
}

attributes <- gff[gff$V3 == "mRNA", 9]

models <- data.frame(
  id = get_attribute(attributes, "ID"),
  AED = suppressWarnings(
    as.numeric(get_attribute(attributes, "_AED"))
  )
)

models <- models[
  !is.na(models$id) &
    is.finite(models$AED) &
    models$AED >= 0 &
    models$AED <= 1,
]

if (nrow(models) == 0) {
  stop("No mRNA features with valid _AED values found.")
}

# Save the underlying values
write.csv(
  models,
  file.path(plotdir, "AED_per_transcript.csv"),
  row.names = FALSE
)

# Plot the cumulative distribution
pdf(
  file.path(plotdir, "03_AED_distribution.pdf"),
  width = 7,
  height = 5
)

plot(
  ecdf(models$AED),
  main = "MAKER annotation evidence support",
  xlab = "Annotation Edit Distance (AED)",
  ylab = "Cumulative proportion of transcript models",
  xlim = c(0, 1),
  ylim = c(0, 1),
  verticals = TRUE,
  do.points = FALSE,
  col = "steelblue",
  lwd = 2
)

abline(v = 0.5, lty = 2, col = "grey50")

legend(
  "bottomright",
  legend = c(
    sprintf(
      "Transcript models: %s",
      format(nrow(models), big.mark = ",")
    ),
    sprintf(
      "AED < 0.5: %.1f%%",
      100 * mean(models$AED < 0.5)
    )
  ),
  bty = "n"
)

dev.off()
