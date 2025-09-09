# benchmark_runtime.R
# Full end-to-end runtime benchmarks for flowengineR using the realistic bank dataset

suppressPackageStartupMessages({
  library(flowengineR)
  library(bench)
  library(pryr)
})

`%||%` <- function(x, y) if (is.null(x)) y else x

# Locate paths (script lives in provenance/)
here <- tryCatch(normalizePath(file.path(dirname(sys.frame(1)$ofile %||% "."))),
                 error = function(e) getwd())
root <- normalizePath(file.path(here, ".."), mustWork = TRUE)
dir.create(file.path(root, "outputs"), showWarnings = FALSE, recursive = TRUE)
path_provenance <- "flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance"
path_outputs <- "flowengineR/inst/runtime_benchmarks/2025-09-09_bank_runtime/outputs"


# Sizes
SIZES <- list(
  S = list(n = 200, seed = 42L),
  M = list(n = 300, seed = 42L),
  L = list(n = 1000, seed = 42L)
)
#SIZES <- list(
  #S = list(n = 1e4L, seed = 42L),
  #M = list(n = 1e5L, seed = 42L),
  #L = list(n = 5e5L, seed = 42L)
#)


# define cv-size
CV_FOLDS <- list(
  S = list(cv_folds = 2),
  M = list(cv_folds = 5),
  L = list(cv_folds = 8)
)

# define all test cases
RUNTIME_CASES <- list(
  lm_base          = list(train_type="train_lm"),
  glm_base         = list(train_type="train_glm"),
  rf_base          = list(train_type="train_rf"),
  lm_pre           = list(train_type="train_lm", preprocessing=TRUE),
  lm_post          = list(train_type="train_lm", postprocessing=TRUE),
  glm_pre          = list(train_type="train_glm", preprocessing=TRUE),
  glm_in           = list(train_type="train_glm", inprocessing=TRUE),
  glm_post         = list(train_type="train_glm", postprocessing=TRUE),
  rf_pre           = list(train_type="train_rf", preprocessing=TRUE),
  rf_post          = list(train_type="train_rf", postprocessing=TRUE),
  lm_pre_post      = list(train_type="train_lm", preprocessing=TRUE, postprocessing=TRUE),
  glm_pre_post     = list(train_type="train_glm", preprocessing=TRUE, postprocessing=TRUE),
  rf_pre_post      = list(train_type="train_rf", preprocessing=TRUE, postprocessing=TRUE),
  glm_pre_in_post  = list(train_type="train_glm", preprocessing=TRUE, inprocessing=TRUE, postprocessing=TRUE)
)

# define execution types
EXECUTION_TYPES <- list (
  multicore        = list(execution_type = "execution_basic_batchtools_multicore"),
  sequential       =list(execution_type = "execution_basic_sequential")
)

# Dataset + vars builder
make_data <- function(n, seed) {
  set.seed(seed)
  d <- create_dataset_bank(n = n, 
                           seed = seed, 
                           onehot = TRUE, 
                           pos_rate = 0.05
                           )
  d
}

# Run exactly one full workflow and time it
run_once <- function(size_name, cfg, control_name, exe_name, cv_folds, control_fun, iterations = 1L) {
  gc()
  data <- make_data(cfg$n, cfg$seed)
  
  if (!is.function(control_fun)) stop("Control factory is not a function: ", control_name)
  ctrl <- control_fun(data)
  
  # Warm up not recorded
  try(invisible(run_workflow(control = ctrl)), silent = TRUE)
  
  bm <- bench::mark(
    workflow = run_workflow(control = ctrl), 
    iterations = iterations, 
    check = FALSE,
    memory = if(exe_name == "sequential"){TRUE}
              else {FALSE}
    )
  
  bm$size        <- size_name
  bm$n           <- cfg$n
  bm$seed        <- cfg$seed
  bm$control     <- control_name
  bm$execution   <- exe_name
  bm$cv_folds    <- cv_folds
  bm$timestamp   <- Sys.time()
  bm
}

print_mem <- function(tag = "") {
  used_mb <- tryCatch(pryr::mem_used()/1024^2, error=function(e) NA_real_)
  msg <- sprintf("[%s] %s | RAM: %.1f MB", format(Sys.time()), tag, used_mb)
  message(msg)
}

# Capture provenance
try(writeLines(capture.output(sessionInfo()), file.path(root, path_provenance, "sessionInfo.txt")), silent = TRUE)

# Execute matrix: sizes x controls
results <- list()

for (sz in names(SIZES)) {
  cfg <- SIZES[[sz]]
  
  for (cn in names(RUNTIME_CASES)) {
    case <- RUNTIME_CASES[[cn]]
    
    for (exe in names(EXECUTION_TYPES)) {
      case_exe <- EXECUTION_TYPES[[exe]]
      
      for (cv in names(CV_FOLDS)) {
        cv_no <- CV_FOLDS[[cv]]

        message(sprintf("Running size=%s (n=%s) | control=%s | execution=%s | cv_size=%s (n=%s)",
                      sz, format(cfg$n, big.mark=","), cn, exe, cv, format(cv_no$cv_folds)))
        
        ctrl_function <- function(data) {
          control_runtime(
            data,
            cv_folds = cv_no$cv_folds,
            execution_type = case_exe$execution_type,
            train_type = case$train_type,
            preprocessing_switch = case$preprocessing %||% FALSE,
            inprocessing_switch  = case$inprocessing %||% FALSE,
            postprocessing_switch= case$postprocessing %||% FALSE
          )
        }
        
        res <- run_once(size_name = sz, 
                        cfg = cfg, 
                        control_name = cn, 
                        exe_name = exe, 
                        cv_folds = cv_no$cv_folds, 
                        control_fun = ctrl_function, 
                        iterations = 3L)
        
        results[[paste(sz, cn, exe, sep = "_")]] <- res
        
        print_mem(sprintf("case=%s size=%s", cn, sz))
        gc()
      
      }
    }
  }
}

# Save outputs
out_rds <- file.path(root, path_outputs, "runtime_results.rds")
out_csv <- file.path(root, path_outputs, "runtime_summary.csv")

if (length(results)) {
  df <- do.call(rbind, lapply(results, as.data.frame))
  keep <- intersect(c("control","execution","size","n","median"), names(df))
  utils::write.csv(df[, keep, drop = FALSE], out_csv, row.names = FALSE)
  saveRDS(results, out_rds)
  message("Saved: ", out_csv)
  message("Saved: ", out_rds)
} else {
  message("No results produced.")
}
