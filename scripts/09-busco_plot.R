args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1)

finaldir <- args[1]
plotdir <- file.path(finaldir, "plots")

dir.create(plotdir, recursive = TRUE, showWarnings = FALSE)

# Read percentages from a BUSCO summary.
read_busco <- function(directory) {
  files <- list.files(
    directory,
    pattern = "^short_summary.*\\.txt$",
    full.names = TRUE
  )

  specific <- files[
    grepl("short_summary\\.specific\\.", basename(files))
  ]

  if (length(specific) > 0) files <- specific

  if (length(files) != 1) {
    stop(
      "Expected one BUSCO summary in ", directory,
      "; found ", length(files),
      ". Select the desired lineage summary."
    )
  }

  lines <- readLines(files)

  score_line <- grep(
    "C:[0-9.]+%\\[S:[0-9.]+%,D:[0-9.]+%\\]",
    lines,
    value = TRUE
  )

  if (length(score_line) != 1) {
    stop("Could not identify BUSCO percentage summary in ", files)
  }

  extract <- function(letter) {
    pattern <- paste0(letter, ":([0-9.]+)%")
    hit <- regmatches(
      score_line,
      regexec(pattern, score_line)
    )[[1]]

    if (length(hit) < 2) {
      stop("Missing BUSCO category: ", letter)
    }

    as.numeric(hit[2])
  }

  c(
    "Complete single-copy" = extract("S"),
    "Complete duplicated" = extract("D"),
    "Fragmented" = extract("F"),
    "Missing" = extract("M")
  )
}

scores <- cbind(
  Proteins = read_busco(file.path(finaldir, "busco_proteins")),
  Transcripts = read_busco(file.path(finaldir, "busco_transcripts"))
)

write.csv(
  data.frame(
    Category = rownames(scores),
    scores,
    check.names = FALSE
  ),
  file.path(plotdir, "BUSCO_summary.csv"),
  row.names = FALSE
)

# Plot bars and legend in separate panels.
colors <- c("#238B45", "#74C476", "#FEC44F", "#DE2D26")

pdf(
  file.path(plotdir, "06_BUSCO_completeness.pdf"),
  width = 9,
  height = 5.5
)

layout(
  matrix(c(1, 2), ncol = 1),
  heights = c(4, 1.2)
)

par(mar = c(4, 8, 4, 2), las = 1)

positions <- barplot(
  scores,
  horiz = TRUE,
  col = colors,
  border = NA,
  space = 0.6,
  xlim = c(0, 100),
  axes = FALSE,
  xlab = "BUSCO markers (%)",
  main = "Annotation completeness",
  sub = "Lineage: brassicales_odb10",
  cex.names = 1.1
)

axis(1, at = seq(0, 100, by = 20))

# Label segments large enough to hold readable text.
for (j in seq_len(ncol(scores))) {
  midpoints <- cumsum(scores[, j]) - scores[, j] / 2

  for (i in seq_len(nrow(scores))) {
    if (scores[i, j] >= 5) {
      text(
        x = midpoints[i],
        y = positions[j],
        labels = sprintf("%.1f%%", scores[i, j]),
        col = if (i %in% c(1, 4)) "white" else "black",
        cex = 0.9
      )
    }
  }
}

# Dedicated legend panel: entirely inside the PDF.
par(mar = c(0, 0, 0, 0))
plot.new()

legend(
  "center",
  legend = rownames(scores),
  fill = colors,
  border = NA,
  ncol = 2,
  bty = "n",
  cex = 1,
  x.intersp = 0.7,
  y.intersp = 1.3
)

dev.off()
