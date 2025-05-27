#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Batchtools Local Execution
#'
#' Executes one split using `run_workflow_single()` as part of a batchtools job.
#' This function is designed to be called internally by batchtools with the split passed explicitly.
#'
#' **Inputs (passed to engine via wrapper/batchtools):**
#' - `control`: Full control object with configuration.
#' - `split`: A single list containing `train` and `test` datasets.
#'
#' **Output (returned to wrapper):**
#' - A single result list as returned by `run_workflow_single()`.
#'
#' @param control The full control object.
#' @param split A single list with `$train` and `$test`.
#'
#' @return Result from `run_workflow_single()`.
#' @export
engine_execution_batchtools_local <- function(control, split) {
  control$data$train <- split$train
  control$data$test  <- split$test
  run_workflow_single(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Batchtools Local
#'
#' Registers one job per split in a local batchtools registry, executes them in parallel or sequentially,
#' waits for completion, and collects the results into a standardized output.
#'
#' **Standardized Inputs:**
#' - `control$params$execution$params`: Parameters specific to batchtools (e.g., `registry_folder`, `resources`, etc.).
#' - `control`: The full control object passed to each job.
#' - `split_output`: The result from the splitter engine containing all splits.
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_execution()`:
#'   - `execution_type`: "batchtools_local".
#'   - `workflow_results`: Named list of results per split.
#'   - `params`: Merged parameter list.
#'   - `continue_workflow`: `TRUE` (ready for next steps).
#'   - `specific_output`: Metadata including number of splits and registry path.
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list of splits from the splitter engine.
#'
#' @return A standardized execution output object.
#' @export
wrapper_execution_batchtools_local <- function(control, split_output) {
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_batchtools_local())
  
  # Create or clear registry
  reg_dir <- params$registry_folder
  unlink(reg_dir, recursive = TRUE)  # Clean existing if necessary
  reg <- batchtools::makeRegistry(
    file.dir = reg_dir,
    make.default = FALSE,
    seed = params$seed,
    packages = params$required_packages
  )
  
  # Map jobs
  batchtools::batchMap(fun = engine_execution_batchtools_local,
                       more.args = list(control = control),
                       split = split_output$splits,
                       reg = reg)
  
  # Submit and wait
  batchtools::submitJobs(reg = reg, resources = params$resources)
  batchtools::waitForJobs(reg = reg)
  
  # Collect results
  workflow_results <- batchtools::reduceResultsList(reg = reg)
  names(workflow_results) <- names(split_output$splits)
  
  # Output
  initialize_output_execution(
    execution_type = "batchtools_local",
    workflow_results = workflow_results,
    params = params,
    continue_workflow = TRUE,
    specific_output = list(n_splits = length(split_output$splits),
                           registry = reg_dir)
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Execution Engine: Batchtools Local
#'
#' Provides default parameters for the `execution_batchtools_local` engine.
#' These parameters are optional and can be adjusted to control the behavior
#' of the batchtools backend.
#'
#' **Purpose:**
#' - Defines engine-specific execution parameters that are not part of the base control structure.
#' - Used by the wrapper to configure the batchtools registry and job resources.
#'
#' **Default Parameters:**
#' - `registry_folder`: Folder where the batchtools registry will be stored (default: `"bt_registry"`).
#' - `seed`: Seed value used for the batchtools registry (default: `123`).
#' - `required_packages`: Character vector of R package names to be loaded in each job (default: empty).
#' - `resources`: Named list of resource constraints for each job, passed to `submitJobs()`:
#'     - `ncpus`: Number of CPUs per job (default: `1`)
#'     - `memory`: RAM in MB (default: `2048`)
#'     - `walltime`: Maximum runtime in seconds (default: `3600`)
#'
#' @return A named list of default parameters for the batchtools execution engine.
#' @export
default_params_execution_batchtools_local <- function() {
  list(
    registry_folder = "bt_registry",
    seed = 123,
    required_packages = character(0),
    resources = list(ncpus = 1, memory = 2048, walltime = 3600)
  )
}
#--------------------------------------------------------------------