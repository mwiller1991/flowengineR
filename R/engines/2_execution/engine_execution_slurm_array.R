#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: SLURM Array Preparation
#'
#' Prepares split definitions and control structure for SLURM array batch processing.
#' Does not execute any splits directly.
#'
#' **Inputs:**
#' - `control`: The full control object.
#' - `split_output`: Output from the splitter engine, including all splits.
#'
#' **Outputs (passed to wrapper):**
#' - Metadata including number of splits and storage location.
#'
#' @param control A list containing all workflow parameters and inputs.
#' @param split_output A list of splits from the splitter engine.
#' @return Metadata placeholder; execution handled externally.
#' @export
engine_execution_slurm_array <- function(control, split_output) {
  # No-op placeholder – actual work is done in the wrapper
  return(list(info = "SLURM Array preparation is handled in wrapper."))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: SLURM Array Preparation
#'
#' Stores control and split definitions to disk so that each split can be
#' executed individually via SLURM array jobs. Does not perform execution.
#'
#' @param control The control object used throughout the workflow.
#' @param split_output The result of the splitter engine.
#'
#' @return A standardized execution output object indicating deferred execution.
#' @export
wrapper_execution_slurm_array <- function(control, split_output) {
  # Merge optional parameters
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_slurm_array())
  
  # Define folder for SLURM input preparation
  output_dir <- params$output_folder
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  
  # Store control object and split definitions
  saveRDS(control, file.path(output_dir, "control_base.rds"))
  saveRDS(split_output, file.path(output_dir, "split_output.rds"))
  writeLines(as.character(length(split_output$splits)), file.path(output_dir, "n_splits.txt"))
  
  # Return standardized execution output
  initialize_output_execution(
    execution_type = "slurm_array",
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
#' Defines the default parameters used during SLURM array preparation.
#'
#' @return A named list of default parameters.
#' @export
default_params_execution_slurm_array <- function() {
  list(
    output_folder = "slurm_inputs"
  )
}
#--------------------------------------------------------------------