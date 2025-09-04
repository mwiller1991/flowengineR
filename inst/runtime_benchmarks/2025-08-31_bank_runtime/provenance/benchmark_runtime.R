# benchmark_runtime.R
# Full end-to-end runtime benchmarks for flowengineR using the realistic bank dataset

suppressPackageStartupMessages({
  library(flowengineR)
  library(bench)   # only for this script
})

`%||%` <- function(x, y) if (is.null(x)) y else x

# Locate paths (script lives in provenance/)
here <- tryCatch(normalizePath(file.path(dirname(sys.frame(1)$ofile %||% "."))),
                 error = function(e) getwd())
root <- normalizePath(file.path(here, ".."), mustWork = TRUE)
dir.create(file.path(root, "outputs"), showWarnings = FALSE, recursive = TRUE)

# Source user-defined control factories
src_cf <- file.path(here, "control_factories.R")
if (!file.exists(src_cf)) stop("Missing file: ", src_cf)
sys.source(src_cf, envir = .GlobalEnv)

# Sizes (enable L later if needed)
SIZES <- list(
  S = list(n = 1e4L, seed = 42L),
  M = list(n = 1e5L, seed = 42L),
  L = list(n = 5e5L, seed = 42L)
)

# Dataset + vars builder
make_data <- function(n, seed) {
  set.seed(seed)
  create_dataset_bank(n = n, seed = seed, onehot = FALSE)
}

# Run exactly one full workflow and time it
run_once <- function(size_name, cfg, control_name, control_fun) {
  gc()
  data <- make_data(cfg$n, cfg$seed)
  
  if (!is.function(control_fun)) stop("Control factory is not a function: ", control_name)
  ctrl <- control_fun(dv$data)
  
  bench::mark(
    workflow = run_workflow(control = ctrl),
    iterations = 1,
    check = FALSE
  ) -> bm
  
  bm$size        <- size_name
  bm$n           <- cfg$n
  bm$seed        <- cfg$seed
  bm$control     <- control_name
  bm$timestamp   <- Sys.time()
  bm
}

# Capture provenance
try(writeLines(capture.output(sessionInfo()), file.path(here, "sessionInfo.txt")), silent = TRUE)

# Execute matrix: sizes x controls
results <- list()
for (sz in names(SIZES)) {
  for (cn in names(CONTROL_FACTORIES)) {
    message(sprintf("Running size=%s (n=%s) | control=%s",
                    sz, format(SIZES[[sz]]$n, big.mark=","), cn))
    res <- run_once(sz, SIZES[[sz]], cn, CONTROL_FACTORIES[[cn]])
    results[[paste(sz, cn, sep = "_")]] <- res
  }
}

# Save outputs
out_rds <- file.path(root, "outputs", "runtime_results.rds")
out_csv <- file.path(root, "outputs", "runtime_summary.csv")

if (length(results)) {
  df <- do.call(rbind, lapply(results, as.data.frame))
  keep <- intersect(c("control","size","n","median","mem_alloc"), names(df))
  utils::write.csv(df[, keep, drop = FALSE], out_csv, row.names = FALSE)
  saveRDS(results, out_rds)
  message("Saved: ", out_csv)
  message("Saved: ", out_rds)
} else {
  message("No results produced.")
}
