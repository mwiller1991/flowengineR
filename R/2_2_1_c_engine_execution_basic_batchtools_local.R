#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Batchtools Local Execution
#'
#' Executes one split using `run_workflow_singlesplitloop()` as part of a batchtools job.
#' This function is designed to be called internally by batchtools with the split passed explicitly.
#'
#' **Inputs (passed to engine via wrapper/batchtools):**
#' - `control`: Full control object with configuration.
#' - `split`: A single list containing `train` and `test` datasets.
#'
#' **Output (returned to wrapper):**
#' - A single result list as returned by `run_workflow_singlesplitloop()`.
#'
#' @seealso [wrapper_execution_basic_batchtools_local()]
#'
#' @param control The full control object.
#' @param split A single list with `$train` and `$test`.
#'
#' @return Result from `run_workflow_singlesplitloop()`.
#' @keywords internal
engine_execution_basic_batchtools_local <- function(control, split) {
  # Assign current split to control object
  control$data$train <- split$train
  control$data$test  <- split$test
  
  # Run full workflow for this split
  run_workflow_singlesplitloop(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Batchtools Local
#'
#' Registers one job per split in a local batchtools registry, executes them (optionally in parallel),
#' and collects results into a standardized format.
#'
#' **Standardized Inputs:**
#' - `control`: The full control object.
#' - `split_output`: Output of the splitter engine.
#' - `control$params$execution$params`: Optional engine-specific parameters (see below).
#'
#' **Engine-Specific Parameters (`control$params$execution$params`):**
#' - `registry_folder` *(character, default = `"~/flowengineR/tests/BATCHTOOLS/bt_registry_basic"`)*: Folder for the batchtools registry.
#' - `seed` *(integer, default = 123)*: Seed for the registry.
#' - `required_packages` *(character vector)*: Packages to be loaded inside each job.
#' - `resources` *(list)*: Batchtools resource constraints per job:
#'   - `ncpus`: CPUs per job (default: 1)
#'   - `memory`: RAM in MB (default: 2048)
#'   - `walltime`: Max runtime in seconds (default: 3600)
#'
#' **Notes:**
#' - Each job executes `run_workflow_singlesplitloop()` on a single data split.
#' - Results are stored in a local registry directory and retrieved automatically.
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$execution <- "execution_basic_batchtools_local"
#' control$params$execution <- controller_execution(
#'   params = list(
#'     registry_folder = "~/flowengineR/tests/BATCHTOOLS/bt_registry_basic",
#'     seed = 42,
#'     resources = list(ncpus = 2, memory = 4096, walltime = 600)
#'   )
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/2_1_c_template_control_execution_basic_batchtools_local.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_execution()`:
#' - `execution_type`: `"basic_batchtools_local"`
#' - `workflow_results`: Named list of results from each split
#' - `params`: Engine parameters (merged default and user-defined)
#' - `continue_workflow`: `TRUE` (execution completed successfully)
#' - `specific_output`: List with:
#'     - `n_splits`: Number of executed splits
#'     - `registry`: Path to the used batchtools registry
#'
#' @seealso 
#'   [engine_execution_basic_batchtools_local()],  
#'   [default_params_execution_basic_batchtools_local()],  
#'   [initialize_output_execution()],  
#'   [controller_execution()],  
#'   Template: `inst/templates_control/2_1_c_template_control_execution_basic_batchtools_local.R`  
#'   Helper: [show_template()]
#'
#' @param control A standardized control object.
#' @param split_output A list of data splits from the splitter engine.
#'
#' @return A standardized execution result list.
#' @keywords internal
wrapper_execution_basic_batchtools_local <- function(control, split_output) {
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_basic_batchtools_local())
  
  # Create or clear registry
  reg_dir <- params$registry_folder
  unlink(reg_dir, recursive = TRUE)  # Clean existing if necessary
  
  log_msg(sprintf("[EXECUTION] Creating batchtools registry at '%s'...", reg_dir), level = "info", control = control)
  
  reg <- batchtools::makeRegistry(
    file.dir = reg_dir,
    make.default = FALSE,
    seed = params$seed,
    packages = params$required_packages
  )
  
  log_msg("[EXECUTION] Registering jobs for each split...", level = "info", control = control)
  
  # Map jobs
  batchtools::batchMap(fun = engine_execution_basic_batchtools_local,
                       more.args = list(control = control),
                       split = split_output$splits,
                       reg = reg)
  
  # Submit and wait
  log_msg("[EXECUTION] Submitting and waiting for batchtools jobs...", level = "info", control = control)
  batchtools::submitJobs(reg = reg, resources = params$resources)
  batchtools::waitForJobs(reg = reg)
  
  # Collect results
  log_msg("[EXECUTION] Collecting results from completed jobs...", level = "info", control = control)
  workflow_results <- batchtools::reduceResultsList(reg = reg)
  names(workflow_results) <- names(split_output$splits)
  
  # Output
  initialize_output_execution(
    execution_type = "basic_batchtools_local",
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
#' Provides default parameters for the `execution_basic_batchtools_local` engine.
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
#' @seealso [wrapper_execution_basic_batchtools_local()]
#'
#' @return A named list of default parameters for the batchtools execution engine.
#' @keywords internal
default_params_execution_basic_batchtools_local <- function() {
  list(
    registry_folder = "~/flowengineR/tests/BATCHTOOLS/bt_registry_basic", # later just: bt_registry
    seed = 123,
    required_packages = character(0),
    resources = list(ncpus = 1, memory = 2048, walltime = 3600)
  )
}
#--------------------------------------------------------------------