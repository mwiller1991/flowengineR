#--------------------------------------------------------------------
### Controller: Input for Variable Definition ###
#--------------------------------------------------------------------
#' Controller for Variable Definitions
#'
#' Creates a standardized list of variables used in the workflow, including features, protected attributes,
#' target variables, and grouped protected attributes.
#'
#' @param feature_vars Character vector of input features used for training.
#' @param protected_vars Character vector of protected attributes used in fairness processing.
#' @param target_var Name of the target variable.
#' @param protected_vars_binary Character vector of protected attributes in binary/grouped form for evaluation.
#'
#' @return A standardized list of variables for the workflow.
#' @export
controller_vars <- function(feature_vars, protected_vars, target_var, protected_vars_binary) {
  list(
    feature_vars = feature_vars,
    protected_vars = protected_vars,
    target_var = target_var,
    protected_vars_binary = protected_vars_binary
  )
}
#--------------------------------------------------------------------


#--------------------------------------------------------------------
### Controller: Split Inputs (supports multiple splitter engines)###
#--------------------------------------------------------------------
#' Controller for Split Inputs
#'
#' Creates a minimal and generic input structure for splitter engines.
#' This structure supports any splitter type by separating general inputs from engine-specific parameters.
#'
#' **Standardized Input:**
#' - `seed`: Random seed for reproducibility (optional).
#' - `target_var`: Target variable used in stratified or CV-based splitting.
#' - `params`: Named list of engine-specific parameters.
#'
#' @param seed Optional random seed for reproducibility.
#' @param target_var Character string specifying the target variable (used e.g. in CV).
#' @param params A named list of additional engine-specific parameters.
#'
#' @return A standardized list containing splitter input.
#' @export
controller_split <- function(seed = 123, target_var, params = list()) {
  list(
    seed = seed,
    target_var = target_var,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Execution Engine ###
#--------------------------------------------------------------------
#' Controller for Execution Engine Inputs
#'
#' Prepares standardized input for execution engines. This includes optional parameters
#' such as the execution engine to use, storage folder, and parallelization-specific settings.
#'
#' @param params Named list of engine-specific parameters (optional).
#'
#' **Common Parameters (within `params`)**
#' - `output_folder`: Folder where RDS files should be written for external engines (e.g., SLURM).
#' - Further parameters depend on the selected execution engine.
#'
#' @return A standardized list to be stored in `control$execution`.
#' @export
controller_execution <- function(method = "execution_sequential", params = list()) {
  list(
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Training (supports multiple training engines) ###
#--------------------------------------------------------------------
#' Controller for Training Inputs
#'
#' Creates standardized input for training engines. Ensures all necessary fields are included for processing.
#'
#' **Standardized Input:**
#' - `formula`: A formula specifying the model structure.
#' - `params`: Optional hyperparameters for the training engine.
#'
#' @param formula A formula specifying the model structure.
#' @param hyperparameters A list of additional hyperparameters for the training engine.
#'
#' @return A standardized list for training input.
#' @export
controller_training <- function(formula, norm_data = TRUE, params = NULL) {
  list(
    formula = formula,
    norm_data = norm_data,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Fairness Pre-Processing (supports multiple fairness pre-processing engines) ###
#--------------------------------------------------------------------
#' Controller for Fairness Pre-Processing Inputs
#'
#' Creates standardized input for fairness pre-processing engines.
#' Ensures all necessary fields are included for processing.
#'
#' **Standardized Input:**
#' - `protected_attributes`: Names of the protected attributes.
#' - `target_var`: The name of the target variable.
#' - `params`: Optional parameters for the fairness pre-processing engine.
#'
#' @param protected_attributes A character vector of protected attribute names.
#' @param target_var The name of the target variable.
#' @param params A list of additional parameters for the fairness pre-processing engine.
#'
#' @return A standardized list for fairness pre-processing input.
#' @export
controller_fairness_pre <- function(protected_attributes, target_var, params = NULL) {
  list(
    protected_attributes = protected_attributes,
    target_var = target_var,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Fairness In-Processing Inputs ###
#--------------------------------------------------------------------
#' Controller for Fairness In-Processing Inputs
#'
#' Creates standardized input for fairness in-processing engines.
#' Ensures all necessary fields are included for processing.
#'
#' **Standardized Input:**
#' - `protected_attributes`: Names of the protected attributes.
#' - `target_var`: The name of the target variable.
#' - `params`: Optional parameters for the fairness in-processing engine.
#'
#' @param protected_attributes A character vector of protected attribute names.
#' @param target_var The name of the target variable.
#' @param params A list of additional parameters for the fairness in-processing engine.
#'
#' @return A standardized list for fairness in-processing input.
#' @export
controller_fairness_in <- function(protected_attributes, target_var, norm_data = TRUE, params = NULL) {
  list(
    protected_attributes = protected_attributes,
    target_var = target_var,
    norm_data = norm_data,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Fairness Post-Processing (supports multiple fairness post-processing engines) ###
#--------------------------------------------------------------------
#' Controller for Fairness Post-Processing Inputs
#'
#' Creates standardized input for fairness post-processing engines. 
#' Ensures all necessary fields are included for processing.
#'
#' **Standardized Input:**
#' - `protected_name`: Names of the protected attributes.
#' - `params`: Optional parameters for the fairness post-processing engine.
#'
#' @param fairness_post_data A data frame containing predictions, actuals, and protected attributes.
#' @param protected_name A character vector of protected attribute names.
#' @param params A list of additional parameters for the fairness engine.
#'
#' @return A standardized list for fairness post-processing.
#' @export
controller_fairness_post <- function(fairness_post_data, protected_name, params = NULL) {
  list(
    protected_name = protected_name,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Evaluation (supports multiple evaluation engines) ###
#--------------------------------------------------------------------
#' Controller for Evaluation Inputs
#'
#' Creates standardized input for evaluation engines. 
#' Ensures all necessary fields are included for processing.
#'
#' **Standardized Input:**
#' - `protected_name`: Names of the protected attributes.
#' - `params`: A named list where keys are engine names and values are their specific parameters in another list (optional).
#'
#' @param protected_name A character vector of protected attribute names.
#' @param params A named list of additional parameters for specific evaluation engines (optional).
#'
#' @return A standardized list for evaluation engines.
#' @export
controller_evaluation <- function(protected_name, params = NULL) {
  list(
    protected_name = protected_name,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Report Elements (multi-instance support) ###
#--------------------------------------------------------------------
#' Controller for Reportelement Inputs
#'
#' Creates standardized input for multiple reporting elements.
#' Allows specifying individual parameters per named reporting alias.
#'
#' **Standardized Input:**
#' - `params`: A named list of parameter lists, where names are reportelement aliases (e.g., "split_table").
#'   Each alias is mapped to a specific reportelement engine via `control$reporting`.
#'
#' @param params A named list of parameter lists. Each name should match an alias from `control$reporting`.
#'
#' @return A standardized list for reportelement input.
#' @export
controller_reportelement <- function(params = NULL) {
  list(
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Report Definitions (multi-instance support) ###
#--------------------------------------------------------------------
#' Controller for Report Inputs
#'
#' Creates standardized input structure for reports.
#' Allows specifying individual parameters per named report alias.
#'
#' **Standardized Input:**
#' - `params`: A named list of parameter lists, where names are report aliases (e.g., "modelsummary").
#'   Each alias is mapped to a specific report engine via `control$report`.
#'
#' @param params A named list of parameter lists. Each name should match an alias from `control$report`.
#'
#' @return A standardized list for report input.
#' @export
controller_report <- function(params = NULL) {
  list(
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Publisher Parameters (multi-instance support) ###
#--------------------------------------------------------------------
#' Controller for Publisher Parameters
#'
#' Creates standardized input for publishing engines.
#' Includes a global output folder and per-alias publishing settings.
#'
#' **Standardized Input:**
#' - `output_folder`: Global target folder for all export files.
#' - `params`: A named list of parameter lists, where names are publishing aliases.
#'
#' @param output_folder A character string indicating the base folder for all exports.
#' @param params A named list of parameter lists. Each name should match a publishing alias.
#'
#' @return A standardized list for publisher configuration.
#' @export
controller_publish <- function(output_folder = NULL, params = NULL) {
  list(
    output_folder = output_folder,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Resuming Fairness Workflow after External Execution ###
#--------------------------------------------------------------------
#' Controller for Resuming Fairness Workflow after External Execution
#'
#' This controller prepares a standardized resume object, which contains
#' the original control configuration, the splitter output, and the
#' externally computed workflow results (e.g., from SLURM jobs).
#'
#' This structure ensures that `resume_fairness_workflow()` can be used
#' in a consistent and extendable way across different execution types.
#'
#' @param control The original control object used in the workflow.
#' @param split_output The output object returned by the splitter engine.
#' @param workflow_results A list of `run_workflow_single()` results, typically loaded from disk.
#' @param metadata (Optional) A named list of additional metadata, e.g., runtime info, engine identifiers, tags.
#'
#' @return A structured list to be passed to `resume_fairness_workflow()`.
#' @export
controller_resume_execution <- function(control, split_output, workflow_results, metadata = NULL) {
  list(
    control = control,
    split_output = split_output,
    execution_output = initialize_output_execution(
      execution_type = "external",
      workflow_results = workflow_results,
      params = NULL,
      specific_output = metadata,
      continue_workflow = TRUE
    )
  )
}
#--------------------------------------------------------------------