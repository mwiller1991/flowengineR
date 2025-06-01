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
#' @seealso [wrapper_execution_basic_slurm_array()]
#'
#' @param control A list containing all workflow parameters and inputs.
#' @param split_output A list of splits from the splitter engine.
#'
#' @return A placeholder list indicating deferred execution.
#' @keywords internal
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
#' - `control`: The full control object containing workflow configuration.
#' - `split_output`: The result from the splitter engine containing multiple data splits.
#' - `control$params$execution$params`: Engine-specific parameters (see below).
#'
#' **Engine-Specific Parameters (`control$params$execution$params`):**
#' - `output_folder` *(character, default = "slurm_inputs")*: Directory to store the control and split files.
#'
#' **Notes:**
#' - This wrapper **only prepares input files** for SLURM execution. The actual model training must be performed externally.
#' - The control object, split output, and number of splits are written to `output_folder`.
#'
#' **Example Control Snippet:**
#' ```
#' control$execution <- "execution_basic_slurm_array"
#' control$params$execution <- controller_execution(
#'   params = list(output_folder = "slurm_inputs")
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/2_1_b_template_control_execution_basic_slurm_array.R`
#' 
#' **Resuming Workflow after SLURM Execution:**
#' After completing the external SLURM jobs, resume the workflow using:
#' ```r
#' resume_object <- prepare_resume_from_slurm_array(
#'   control_path = "slurm_inputs/control_base.rds",
#'   split_output_path = "slurm_inputs/split_output.rds",
#'   result_dir = "slurm_outputs/"
#' )
#' result <- resume_fairness_workflow(resume_object)
#' ```
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_execution()`:
#' - `execution_type`: `"basic_slurm_array"`
#' - `workflow_results`: `NULL` (execution deferred to SLURM)
#' - `params`: Engine parameters (merged default and user-defined)
#' - `continue_workflow`: `FALSE` (must be resumed via `resume_fairness_workflow()`)
#' - `specific_output`: List with:
#'     - `message`: Informative status string
#'     - `output_dir`: Path to directory containing saved inputs
#'     - `n_splits`: Number of splits prepared for execution
#'
#' @seealso 
#'   [engine_execution_basic_slurm_array()],  
#'   [default_params_execution_basic_slurm_array()],  
#'   [initialize_output_execution()],  
#'   [controller_execution()],  
#'   Template: `inst/templates_control/2_1_b_template_control_execution_basic_slurm_array.R`  
#'   Helper: [prepare_resume_from_slurm_array()], [show_template()]
#'
#' @param control A standardized control object.
#' @param split_output A list of splits from the splitter engine.
#'
#' @return A standardized execution output indicating that external SLURM execution is required.
#' @keywords internal
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
#' @seealso [wrapper_execution_basic_slurm_array()]
#'
#' @return A named list of default parameters for the SLURM array execution engine.
#' @keywords internal
default_params_execution_basic_slurm_array <- function() {
  list(
    output_folder = "slurm_inputs"
  )
}
#--------------------------------------------------------------------