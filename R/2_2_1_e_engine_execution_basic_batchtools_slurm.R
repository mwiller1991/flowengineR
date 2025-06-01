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
#' @seealso [wrapper_execution_basic_batchtools_slurm()]
#'
#' @param control The full control object.
#' @param split A single list with `$train` and `$test`.
#'
#' @return Result from `run_workflow_single()`.
#' @keywords internal
engine_execution_basic_batchtools_slurm <- function(control, split) {
  control$data$train <- split$train
  control$data$test  <- split$test
  run_workflow_single(control)
}
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
#' **Engine-Specific Parameters (`control$params$execution$params`):**
#' - `registry_folder` *(character)*: Where to store the batchtools registry (default: `"~/fairness_toolbox/tests/BATCHTOOLS/bt_SLURM_basic/bt_registry_SLURM"`).
#' - `slurm_template` *(character)*: Path to SLURM job template (must exist).
#' - `seed` *(integer)*: RNG seed (default: 123).
#' - `required_packages` *(character vector)*: R packages to load in job.
#' - `resources` *(list)*: Resource specs passed to `submitJobs()` (e.g., `ncpus`, `memory`, `walltime`).
#'
#' **Notes:**
#' - This wrapper requires SLURM environment and a valid SLURM template.
#'
#' **Example Control Snippet:**
#' ```
#' control$execution <- "execution_basic_batchtools_slurm"
#' control$params$execution <- controller_execution(params = list(
#'   registry_folder = "my_bt_slurm",
#'   slurm_template = "~/templates/my_slurm.tmpl",
#'   seed = 111,
#'   required_packages = c("fairnessToolbox"),
#'   resources = list(ncpus = 2, memory = 4096, walltime = 7200)
#' ))
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/2_1_e_template_control_execution_basic_batchtools_slurm.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_execution()`:
#' - `execution_type`: `"basic_batchtools_slurm"`
#' - `workflow_results`: Named list of results from each split
#' - `params`: Engine parameters (merged default and user-defined)
#' - `continue_workflow`: `TRUE` (execution completed successfully)
#' - `specific_output`: List with:
#'     - `n_splits`: Number of executed splits
#'     - `registry`: Path to the used batchtools registry
#'
#' @seealso 
#'   [engine_execution_basic_batchtools_slurm()],
#'   [default_params_execution_basic_batchtools_slurm()],
#'   [initialize_output_execution()],
#'   [controller_execution()],
#'   Template: `inst/templates_control/2_1_e_template_control_execution_basic_batchtools_slurm.R`,
#'   Helper: [show_template()]
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list of splits from the splitter engine.
#'
#' @return A standardized execution output object.
#' @keywords internal
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
#' @seealso [wrapper_execution_basic_batchtools_slurm()]
#'
#' @return A named list of default parameters.
#' @keywords internal
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