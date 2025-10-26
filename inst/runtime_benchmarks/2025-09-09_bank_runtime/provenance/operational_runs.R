### Runs for every size and cv_number

devtools::load_all()
# load file
source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
# capture provenance
try(writeLines(capture.output(sessionInfo()), file.path(path_provenance, "sessionInfo.txt")), silent = TRUE)


# Size XS
results_interim_XS_S_multicore <- runtime_test(sz = "XS", cv ="S", exe = "multicore")
results <- append(results, results_interim_XS_S_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XS_S_sequential <- runtime_test(sz = "XS", cv ="S", exe = "sequential")
results <- append(results, results_interim_XS_S_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XS_M_multicore <- runtime_test(sz = "XS", cv ="M", exe = "multicore")
results <- append(results, results_interim_XS_M_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XS_M_sequential <- runtime_test(sz = "XS", cv ="M", exe = "sequential")
results <- append(results, results_interim_XS_M_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XS_L_multicore <- runtime_test(sz = "XS", cv ="L", exe = "multicore")
results <- append(results, results_interim_XS_L_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XS_L_sequential <- runtime_test(sz = "XS", cv ="L", exe = "sequential")
results <- append(results, results_interim_XS_L_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)


# Size S
results_interim_S_S_multicore <- runtime_test(sz = "S", cv ="S", exe = "multicore")
results <- append(results, results_interim_S_S_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_S_S_sequential <- runtime_test(sz = "S", cv ="S", exe = "sequential")
results <- append(results, results_interim_S_S_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_S_M_multicore <- runtime_test(sz = "S", cv ="M", exe = "multicore")
results <- append(results, results_interim_S_M_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_S_M_sequential <- runtime_test(sz = "S", cv ="M", exe = "sequential")
results <- append(results, results_interim_S_M_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_S_L_multicore <- runtime_test(sz = "S", cv ="L", exe = "multicore")
results <- append(results, results_interim_S_L_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_S_L_sequential <- runtime_test(sz = "S", cv ="L", exe = "sequential")
results <- append(results, results_interim_S_L_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)
  

# Size M
results_interim_M_S_multicore <- runtime_test(sz = "M", cv ="S", exe = "multicore")
results <- append(results, results_interim_M_S_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_M_S_sequential <- runtime_test(sz = "M", cv ="S", exe = "sequential")
results <- append(results, results_interim_M_S_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_M_M_multicore <- runtime_test(sz = "M", cv ="M", exe = "multicore")
results <- append(results, results_interim_M_M_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_M_M_sequential <- runtime_test(sz = "M", cv ="M", exe = "sequential")
results <- append(results, results_interim_M_M_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_M_L_multicore <- runtime_test(sz = "M", cv ="L", exe = "multicore")
results <- append(results, results_interim_M_L_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_M_L_sequential <- runtime_test(sz = "M", cv ="L", exe = "sequential")
results <- append(results, results_interim_M_L_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)
  

# Size L
results_interim_L_S_multicore <- runtime_test(sz = "L", cv ="S", exe = "multicore")
results <- append(results, results_interim_L_S_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_L_S_sequential <- runtime_test(sz = "L", cv ="S", exe = "sequential")
results <- append(results, results_interim_L_S_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_L_M_multicore <- runtime_test(sz = "L", cv ="M", exe = "multicore")
results <- append(results, results_interim_L_M_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_L_M_sequential <- runtime_test(sz = "L", cv ="M", exe = "sequential")
results <- append(results, results_interim_L_M_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_L_L_multicore <- runtime_test(sz = "L", cv ="L", exe = "multicore")
results <- append(results, results_interim_L_L_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_L_L_sequential <- runtime_test(sz = "L", cv ="L", exe = "sequential")
results <- append(results, results_interim_L_L_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)
  

# Size XL
results_interim_XL_S_multicore <- runtime_test(sz = "XL", cv ="S", exe = "multicore")
results <- append(results, results_interim_XL_S_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XL_S_sequential <- runtime_test(sz = "XL", cv ="S", exe = "sequential")
results <- append(results, results_interim_XL_S_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XL_M_multicore <- runtime_test(sz = "XL", cv ="M", exe = "multicore")
results <- append(results, results_interim_XL_M_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XL_M_sequential <- runtime_test(sz = "XL", cv ="M", exe = "sequential")
results <- append(results, results_interim_XL_M_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XL_L_multicore <- runtime_test(sz = "XL", cv ="L", exe = "multicore")
results <- append(results, results_interim_XL_L_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XL_L_sequential <- runtime_test(sz = "XL", cv ="L", exe = "sequential")
results <- append(results, results_interim_XL_L_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)
  

# Size XXL
results_interim_XXL_S_multicore <- runtime_test(sz = "XXL", cv ="S", exe = "multicore")
results <- append(results, results_interim_XXL_S_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XXL_S_sequential <- runtime_test(sz = "XXL", cv ="S", exe = "sequential")
results <- append(results, results_interim_XXL_S_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XXL_M_multicore <- runtime_test(sz = "XXL", cv ="M", exe = "multicore")
results <- append(results, results_interim_XXL_M_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XXL_M_sequential <- runtime_test(sz = "XXL", cv ="M", exe = "sequential")
results <- append(results, results_interim_XXL_M_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XXL_L_multicore <- runtime_test(sz = "XXL", cv ="L", exe = "multicore")
results <- append(results, results_interim_XXL_L_multicore)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)

results_interim_XXL_L_sequential <- runtime_test(sz = "XXL", cv ="L", exe = "sequential")
results <- append(results, results_interim_XXL_L_sequential)

  # reset environment for comparible results
  kill_environment()
  source("~/flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")
  devtools::load_all()
  results <- readRDS(out_rds)


# Save outputs
out_rds <- file.path(path_outputs, "runtime_results.rds")
out_csv <- file.path(path_outputs, "runtime_summary.csv")

to_seconds <- function(x) {
  # comments in English
  # Convert bench_time (nanoseconds) safely to seconds
  if (inherits(x, "bench_time")) {
    return(as.numeric(x))
  } else {
    return(suppressWarnings(as.numeric(x)))
  }
}

if (length(results)) {
  df <- do.call(rbind, lapply(results, as.data.frame))
  if ("median" %in% names(df)) df$median <- to_seconds(df$median)
  if ("min"    %in% names(df)) df$min    <- to_seconds(df$min)
  
  keep <- intersect(c("control","execution","cv_folds","size","n","median","min"), names(df))
  utils::write.csv(df[, keep, drop = FALSE], out_csv, row.names = FALSE)
  saveRDS(results, out_rds)
  message("Saved: ", out_csv)
  message("Saved: ", out_rds)
} else {
  message("No results produced.")
}
