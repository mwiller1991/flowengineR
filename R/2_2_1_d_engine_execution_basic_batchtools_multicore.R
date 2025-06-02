#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Batchtools Multicore Execution
#'
#' Executes one split using `run_workflow_singlesplitloop()` as part of a batchtools job.
#' Uses the `multicore` backend of batchtools for local parallelization.
#'
#' This engine only works on Unix-like systems (Linux, macOS, WSL). It does not work on Windows.
#'
#' **Inputs (passed to engine via wrapper/batchtools):**
#' - `control`: Full control object with configuration.
#' - `split`: A single list containing `train` and `test` datasets.
#'
#' **Output (returned to wrapper):**
#' - A single result list as returned by `run_workflow_singlesplitloop()`.
#'
#' @seealso [wrapper_execution_basic_batchtools_multicore()]
#'
#' @param control The full control object.
#' @param split A single list with `$train` and `$test`.
#'
#' @return Result from `run_workflow_singlesplitloop()`.
#' @keywords internal
engine_execution_basic_batchtools_multicore <- function(control, split) {
  # Assign current split to control
  control$data$train <- split$train
  control$data$test  <- split$test
  
  # Run workflow for this split
  run_workflow_singlesplitloop(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Batchtools Multicore
#'
#' Registers one job per split in a local batchtools registry and executes them
#' in parallel using the `multicore` backend.
#'
#' **Platform Restriction:** Only works on Unix-like systems (Linux, macOS, WSL).  
#' Not supported on Windows. Use `"execution_basic_batchtools_local"` instead.
#'
#' **Standardized Inputs:**
#' - `control`: Full control object.
#' - `split_output`: Output of the splitter engine.
#' - `control$params$execution$params`: Optional engine-specific parameters (see below).
#'
#' **Engine-Specific Parameters (`control$params$execution$params`):**
#' - `registry_folder` *(character)*: Folder where the batchtools registry will be stored.  
#'   *Default:* `"~/flowengineR/tests/BATCHTOOLS/bt_registry_basic_multicore"`
#' - `seed` *(integer)*: Seed for registry initialization. *Default:* `123`
#' - `required_packages` *(character vector)*: R packages to load within each batchtools job. *Default:* `character(0)`
#' - `ncpus` *(integer)*: Number of parallel cores to use. *Default:* `parallel::detectCores()`
#'
#' **Example Control Snippet:**
#' ```
#' control$execution <- "execution_basic_batchtools_multicore"
#' control$params$execution <- controller_execution(
#'   params = list(
#'     registry_folder = "~/flowengineR/tests/BATCHTOOLS/bt_registry_basic_multicore",
#'     seed = 42,
#'     ncpus = 4
#'   )
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/2_1_d_template_control_execution_basic_batchtools_multicore.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_execution()`:
#' - `execution_type`: `"basic_batchtools_multicore"`
#' - `workflow_results`: Named list of results from each split
#' - `params`: Engine parameters (merged default and user-defined)
#' - `continue_workflow`: `TRUE` (execution is complete)
#' - `specific_output`: List with:
#'   - `n_splits`: Number of executed splits
#'   - `registry`: Path to batchtools registry used
#'
#' @seealso 
#'   [engine_execution_basic_batchtools_multicore()],  
#'   [default_params_execution_basic_batchtools_multicore()],  
#'   [initialize_output_execution()],  
#'   [controller_execution()],  
#'   Template: `inst/templates_control/2_1_d_template_control_execution_basic_batchtools_multicore.R`  
#'   Helper: [show_template()]
#'
#' @param control A standardized control object.
#' @param split_output A list of data splits from the splitter engine.
#'
#' @return A standardized execution result list.
#' @keywords internal
wrapper_execution_basic_batchtools_multicore <- function(control, split_output) {
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_basic_batchtools_multicore())
  
  # Safety check for supported OS
  if (.Platform$OS.type == "windows") {
    stop("Batchtools multicore execution is not supported on Windows. Please use 'batchtools_local' instead.")
  }
  
  # Create or clear registry
  reg_dir <- params$registry_folder
  unlink(reg_dir, recursive = TRUE)
  
  log_msg(sprintf("[EXECUTION] Creating multicore batchtools registry at '%s'...", reg_dir), level = "info", control = control)
  
  reg <- batchtools::makeRegistry(
    file.dir = reg_dir,
    make.default = FALSE,
    seed = params$seed,
    packages = params$required_packages
  )
  
  # Set cluster function to multicore
  reg$cluster.functions <- batchtools::makeClusterFunctionsMulticore(ncpus = params$ncpus)
  
  # Map jobs
  log_msg("[EXECUTION] Registering jobs for each split...", level = "info", control = control)
  batchtools::batchMap(fun = engine_execution_basic_batchtools_multicore,
                       more.args = list(control = control),
                       split = split_output$splits,
                       reg = reg)
  
  # Submit and wait
  log_msg("[EXECUTION] Submitting and running jobs in parallel...", level = "info", control = control)
  batchtools::submitJobs(reg = reg)
  batchtools::waitForJobs(reg = reg)
  
  # Collect results
  log_msg("[EXECUTION] Collecting results from multicore execution...", level = "info", control = control)
  workflow_results <- batchtools::reduceResultsList(reg = reg)
  names(workflow_results) <- names(split_output$splits)
  
  # Output
  initialize_output_execution(
    execution_type = "basic_batchtools_multicore",
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
#' Default Parameters for Execution Engine: Batchtools Multicore
#'
#' Provides default parameters for the `execution_basic_batchtools_multicore` engine.
#' These parameters are optional and can be adjusted to control the behavior
#' of the batchtools backend.
#'
#' **Purpose:**
#' - Defines engine-specific execution parameters that are not part of the base control structure.
#' - Used by the wrapper to configure the batchtools registry and job resources.
#'
#' Note: This engine only works on Unix-like systems (Linux, macOS, WSL). It is not compatible with Windows.
#'
#' **Default Parameters:**
#' - `registry_folder`: Folder where the batchtools registry will be stored.
#' - `seed`: Seed value used for the batchtools registry.
#' - `required_packages`: Character vector of R package names to be loaded in each job.
#' - `ncpus`: Number of parallel cores to use locally.
#'
#' @seealso [wrapper_execution_basic_batchtools_multicore()]
#'
#' @return A named list of default parameters.
#' @keywords internal
default_params_execution_basic_batchtools_multicore <- function() {
  list(
    registry_folder = "~/flowengineR/tests/BATCHTOOLS/bt_registry_basic_multicore",
    seed = 123,
    required_packages = character(0),
    ncpus = parallel::detectCores()
  )
}
#--------------------------------------------------------------------