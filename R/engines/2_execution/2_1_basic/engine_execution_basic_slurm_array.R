#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: SLURM Array Preparation
#'
#' Prepares split definitions and the control object for execution via SLURM array jobs.
#' This engine itself does not perform any execution; all processing is handled externally.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `control`: The full control object containing workflow configuration.
#' - `split_output`: Output from the splitter engine, containing all data splits.
#'
#' **Output (returned to wrapper):**
#' - A placeholder list indicating that SLURM preparation was handled in the wrapper.
#'
#' @param control A list containing all workflow parameters and inputs.
#' @param split_output A list of splits from the splitter engine.
#'
#' @return A placeholder list indicating deferred execution.
#' @export
engine_execution_basic_slurm_array <- function(control, split_output) {
  # No-op placeholder – actual work is done in the wrapper
  return(list(info = "SLURM Array preparation is handled in wrapper."))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: SLURM Array Preparation
#'
#' Prepares files for distributed execution via SLURM array jobs by storing the control object
#' and split definitions to disk. This wrapper does not execute any models directly.
#'
#' **Standardized Inputs:**
#' - `control$params$execution$params`: List of execution-specific parameters (e.g., `output_folder`).
#' - `control`: The full control object to be serialized.
#' - `split_output`: The result from the splitter engine containing multiple data splits.
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_execution()`:
#'   - `execution_type`: "slurm_array".
#'   - `workflow_results`: `NULL` (execution deferred).
#'   - `params`: Merged parameter list.
#'   - `continue_workflow`: `FALSE`, indicating that manual resumption is required.
#'   - `specific_output`: Metadata including output folder and number of splits.
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list of splits from the splitter engine.
#'
#' @return A standardized execution output indicating that external SLURM execution is required.
#' @export
wrapper_execution_basic_slurm_array <- function(control, split_output) {
  # Merge optional parameters
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_basic_slurm_array())
  
  # Define folder for SLURM input preparation
  output_dir <- params$output_folder
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  
  # Store control object and split definitions
  saveRDS(control, file.path(output_dir, "control_base.rds"))
  saveRDS(split_output, file.path(output_dir, "split_output.rds"))
  writeLines(as.character(length(split_output$splits)), file.path(output_dir, "n_splits.txt"))
  
  # Return standardized execution output
  initialize_output_execution(
    execution_type = "basic_slurm_array",
    workflow_results = NULL,
    params = params,
    continue_workflow = FALSE,
    specific_output = list(
      message = "SLURM array preparation complete. Run splits externally and resume later.",
      output_dir = output_dir,
      n_splits = length(split_output$splits)
    )
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Execution Engine: SLURM Array
#'
#' Provides default parameters for the `execution_basic_slurm_array` engine.
#' These parameters are used to configure where the control object and
#' split definitions are written before external execution via SLURM array jobs.
#'
#' **Purpose:**
#' - Defines engine-specific parameters required for preparing the SLURM job infrastructure.
#' - Used by the wrapper to write all required files to disk.
#'
#' **Default Parameters:**
#' - `output_folder`: Directory where the control and split files are stored (default: `"slurm_inputs"`).
#'
#' @return A named list of default parameters for the SLURM array execution engine.
#' @export
default_params_execution_basic_slurm_array <- function() {
  list(
    output_folder = "slurm_inputs"
  )
}
#--------------------------------------------------------------------