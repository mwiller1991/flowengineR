#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Batchtools SLURM Execution
#'
#' Executes one split using `run_workflow_single()` as part of a batchtools job.
#' Designed for use with a SLURM-based HPC cluster.
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
engine_execution_basic_batchtools_slurm <- function(control, split) {
  control$data$train <- split$train
  control$data$test  <- split$test
  run_workflow_single(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Batchtools SLURM
#'
#' Registers jobs and submits them to a SLURM cluster using a job template.
#'
#' **Required:** A valid SLURM template file (`slurm_template`) must be provided in parameters.
#'
#' **Standardized Inputs:**
#' - `control$params$execution$params`: Parameters specific to batchtools and SLURM.
#' - `control`: The full control object.
#' - `split_output`: The result from the splitter engine.
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_execution()`:
#'   - `execution_type`: "batchtools_slurm".
#'   - `workflow_results`: Named list of results per split.
#'   - `params`: Merged parameter list.
#'   - `continue_workflow`: `TRUE` (ready for next steps).
#'   - `specific_output`: Includes metric values, reconstructed split_output and used seeds.
#'
#' @param control The standardized control object.
#' @param split_output The result from the splitter engine.
#'
#' @return A standardized execution output object.
#' @export
wrapper_execution_basic_batchtools_slurm <- function(control, split_output) {
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_basic_batchtools_slurm())
  
  if (is.null(params$slurm_template)) {
    stop("Missing 'slurm_template' path in execution parameters.")
  }
  
  # Create or clear registry
  reg_dir <- params$registry_folder
  unlink(reg_dir, recursive = TRUE)
  reg <- batchtools::makeRegistry(
    file.dir = reg_dir,
    make.default = FALSE,
    seed = params$seed,
    packages = params$required_packages
  )
  
  # Assign SLURM as backend
  reg$cluster.functions <- batchtools::makeClusterFunctionsSlurm(template = params$slurm_template)
  
  # Map jobs
  batchtools::batchMap(fun = engine_execution_basic_batchtools_slurm,
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
    execution_type = "basic_batchtools_slurm",
    workflow_results = workflow_results,
    params = params,
    continue_workflow = TRUE,
    specific_output = list(
      n_splits = length(split_output$splits),
      registry = reg_dir
    )
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Execution Engine: Batchtools SLURM
#'
#' Provides default parameters for SLURM-based batchtools execution.
#' Includes registry folder, SLURM template path, job resources, and required packages.
#'
#' **Default Parameters:**
#' - `registry_folder`: Registry location.
#' - `slurm_template`: Path to SLURM job template (must exist).
#' - `seed`: Random seed for reproducibility.
#' - `required_packages`: Packages to load in each job.
#' - `resources`: SLURM resource specs (e.g., walltime, mem).
#'
#' @return A named list of default parameters.
#' @export
default_params_execution_basic_batchtools_slurm <- function() {
  list(
    registry_folder = "~/fairness_toolbox/tests/BATCHTOOLS/bt_SLURM_basic/bt_registry_SLURM",
    slurm_template = "~/fairness_toolbox/tests/BATCHTOOLS/bt_SLURM_basic/default.tmpl",
    seed = 123,
    required_packages = character(0),
    resources = list(
      ncpus = 1,
      memory = 2048,      # in MB
      walltime = 3600     # in seconds
    )
  )
}
#--------------------------------------------------------------------