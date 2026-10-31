# Helper for the end-to-end tests: PDF publishing needs pandoc and a LaTeX
# installation. Where these are missing, only the PDF expectations are
# skipped; the rest of each workflow test still runs.
can_render_pdf <- function() {
  rmarkdown::pandoc_available() && nzchar(Sys.which("pdflatex"))
}