#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Statistical Parity Difference (SPD)
#'
#' Computes the absolute Statistical Parity Difference (SPD) for each protected attribute.
#' The SPD is defined as the absolute difference in mean predicted values between the two groups.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `eval_data`: A data frame containing:
#'     - `predictions`: A numeric vector of predicted values.
#'     - Protected attribute columns.
#' - `protected_name`: Character vector of protected attribute names.
#'
#' **Output (returned to wrapper):**
#' - A named list with SPD values for each protected attribute.
#'
#' @seealso [wrapper_eval_statisticalparity()]
#'
#' @param eval_data A data frame containing predictions and protected attributes.
#' @param protected_name A character vector specifying the names of protected attributes.
#'
#' @return A list containing the SPD values for each protected attribute.
#' @keywords internal
engine_eval_statisticalparity <- function(eval_data, protected_name) {
  # Calculate Statistical Parity for each protected attribute
  results <- sapply(protected_name, function(attr_name) {
    attribute <- eval_data[[attr_name]]
    group_means <- tapply(eval_data$predictions, attribute, mean)
    spd <- abs(group_means[1] - group_means[2])  # Absolute difference
    return(spd)
  })
  
  names(results) <- protected_name
  return(as.list(results))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Evaluation Engine: Statistical Parity Difference (SPD)
#'
#' Validates and prepares standardized inputs, checks for binary protected attributes,
#' and invokes the SPD engine. Wraps the result using `initialize_output_eval()`.
#'
#' **Standardized Inputs:**
#' - `control$params$evaluation$eval_data`: Data frame including predictions and protected attributes (injected by workflow).
#' - `control$params$evaluation$protected_name`: Character vector of protected attribute names.
#'   → This field is auto-filled from `control$data$vars$protected_vars_binary` and must not be set manually.
#' - `control$params$evaluation$params`: Optional engine-specific parameters (not used here).
#'
#' **Binary Attribute Requirement:**
#' - All variables listed in `protected_name` must be binary (e.g., 0/1, TRUE/FALSE).
#' - Multi-class or continuous variables must be transformed into binary dummies during setup (via `controller_vars()`).
#' - This wrapper validates binary structure and returns an error if invalid formats are detected.
#'
#' **Engine-Specific Parameters (`control$params$evaluation$params`):**
#' - None. This engine evaluates group fairness based on fixed logic.
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$evaluation <- "eval_statisticalparity"
#' control$params$evaluation <- controller_evaluation(
#'   params = list()
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/7_3_a_template_eval_statisticalparity.R`
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_eval()`:
#'   - `metrics`: Named list `spd`, containing values per protected attribute.
#'   - `eval_type`: `"statistical_parity_eval"`.
#'   - `input_data`: Original evaluation data (incl. predictions).
#'   - `protected_attributes`: List of protected attributes used.
#'   - `params`: `NULL`.
#'   - `specific_output`: `NULL`.
#'
#' @seealso 
#'   [engine_eval_statisticalparity()],  
#'   [default_params_eval_statisticalparity()],  
#'   [initialize_output_eval()],  
#'   [controller_evaluation()],  
#'   Template: `inst/templates_control/7_3_a_template_eval_statisticalparity.R`
#'
#' @param control A standardized control object (see `controller_evaluation()`).
#' @return A standardized evaluation output object.
#' @keywords internal
wrapper_eval_statisticalparity <- function(control) {
  eval_params <- control$params$evaluation
  
  # Validate inputs
  if (is.null(eval_params$eval_data)) {
    stop("Statistical Parity Wrapper: 'eval_data' is missing.")
  }
  
  # Validate protected attributes
  missing_columns <- setdiff(eval_params$protected_name, colnames(eval_params$eval_data))
  if (length(missing_columns) > 0) {
    stop(paste("Statistical Parity Wrapper: Missing protected attributes:", 
               paste(missing_columns, collapse = ", ")))
  }
  
  non_binary_attributes <- sapply(eval_params$protected_name, function(attr_name) {
    attribute <- eval_params$eval_data[[attr_name]]
    length(unique(attribute)) != 2
  })
  if (any(non_binary_attributes)) {
    stop(paste("Statistical Parity Wrapper: Non-binary protected attributes:", 
               paste(eval_params$protected_name[non_binary_attributes], collapse = ", ")))
  }
  
  # Call the engine
  spd_results <- engine_eval_statisticalparity(
    eval_data = eval_params$eval_data,
    protected_name = eval_params$protected_name
  )
  
  log_msg(sprintf("[EVAL] Statistical Parity evaluation complete: %s",
                  paste(paste(names(spd_results), sprintf("%.6f", unlist(spd_results))), collapse = ", ")),
          level = "info", control = control)
  
  # Standardized output
  initialize_output_eval(
    metrics = list(spd = spd_results),
    eval_type = "statistical_parity_eval",
    input_data = eval_params$eval_data,
    protected_attributes = eval_params$protected_name,
    params = NULL,  # No specific params for SP evaluation
    specific_output = NULL  # No specific output for SP evaluation
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Evaluation Engine: Statitical parity
#'
#' Provides default parameters for the MSE evaluation engine.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' **Additional Parameters:**
#' - None for this engine; it relies entirely on the base fields from the controller.
#'
#' @seealso [wrapper_eval_statisticalparity()]
#'
#' @return A list of default parameters for the MSE evaluation engine.
#' @keywords internal
default_params_eval_statisticalparity <- function() {
  list()
}
#--------------------------------------------------------------------