#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Statistical Parity Difference
#'
#' Computes the Statistical Parity Difference (SPD) for each protected attribute.
#'
#' **Inputs:**
#' - `eval_data`: A data frame containing:
#'   - `predictions`: A numeric vector of predicted values.
#'   - `protected_attributes`: One or more columns representing protected groups.
#'
#' **Outputs (passed to wrapper):**
#' - `metrics`: A list containing SPD values for each protected attribute, calculated as the absolute difference between group means.
#'
#' @param eval_data A data frame containing predictions and protected attributes.
#' @param protected_name A character vector specifying the names of protected attributes.
#' @return A list containing the SPD values for each protected attribute.
#' @export
engine_eval_statisticalparity <- function(eval_data, protected_name) {
  # Calculate Statistical Parity for each protected attribute
  results <- sapply(protected_name, function(attr_name) {
    attribute <- eval_data[[attr_name]]
    group_means <- tapply(eval_data$predictions, attribute, mean)
    spd <- abs(group_means[1] - group_means[2])  # Absolute difference
    return(spd)
  })
  
  names(results) <- protected_name
  return(results)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Statistical Parity Difference Evaluation
#'
#' Handles input validation, calls the Statistical Parity engine, and creates standardized output.
#'
#' @param control A list containing evaluation parameters, including predictions and protected attributes.
#' @return A standardized list containing the evaluation results.
#' @export
wrapper_eval_statisticalparity <- function(control) {
  eval_params <- control$params$eval
  
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
#' @return A list of default parameters for the MSE evaluation engine.
#' @export
default_params_eval_statisticalparity <- function() {
  NULL  # This engine does not require specific parameters -> for any other engine would be a list() necessary
}
#--------------------------------------------------------------------