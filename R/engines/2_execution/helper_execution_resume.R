#--------------------------------------------------------------------
### Helper: Prepare Resume Object from SLURM Array Execution ###
#--------------------------------------------------------------------
#' Prepare Resume Object from SLURM Array Execution
#'
#' Loads control and split definitions, collects all result files created by SLURM
#' array jobs, and creates a standardized resume object for further workflow continuation.
#'
#' This function wraps `controller_resume_execution()` and handles all required file I/O.
#'
#' @param control_path Path to the saved control object (default: "slurm_inputs/control_base.rds").
#' @param split_output_path Path to the saved split output (default: "slurm_inputs/split_output.rds").
#' @param result_dir Directory containing the result_split_*.rds files (default: "slurm_outputs/").
#' @param n_splits Number of splits. If NULL, tries to read from "slurm_inputs/n_splits.txt".
#' @param metadata Optional metadata to include in the resume object (e.g., engine, timestamp).
#'
#' @return A validated resume object to be passed to `resume_fairness_workflow()`.
#' @export
prepare_resume_from_slurm_array <- function(
    control_path = "slurm_inputs/control_base.rds",
    split_output_path = "slurm_inputs/split_output.rds",
    result_dir = "slurm_outputs",
    metadata = list(engine = "SLURM_ARRAY", timestamp = Sys.time())
) {
  # Load control and split definitions
  control <- readRDS(control_path)
  split_output <- readRDS(split_output_path)
  
  # Collect result files
  workflow_results <- list()
  for (i in names(split_output$splits)) {
    result_file <- file.path(result_dir, paste0("result_split_", i, ".rds"))
    if (!file.exists(result_file)) {
      warning(sprintf("[SLURM Resume] Missing result file: %s", result_file))
      next
    }
    workflow_results[[i]] <- readRDS(result_file)
  }
  
  # Build and validate resume object
  resume_object <- controller_resume_execution(
    control = control,
    split_output = split_output,
    workflow_results = workflow_results,
    metadata = metadata
  )
  
  validate_resume_object(resume_object)
  return(resume_object)
}
#--------------------------------------------------------------------