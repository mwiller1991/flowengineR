#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Statistical Parity Difference
#'
#' @param predictions A vector of model predictions.
#' @param actuals A vector of observed values (optional, not used here).
#' @param protected_attribute A data frame of protected attributes.
#' @param protected_name A vector of protected attribute names.
#' @return A named list of Statistical Parity Difference values for each protected attribute.
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
#' @param control A list containing evaluation parameters, including predictions and protected attributes.
#' @return A named list of Statistical Parity Difference values.
#' @export
wrapper_eval_statisticalparity <- function(control) {
  eval_params <- control$params$eval
  
  # Validate inputs
  
  # Validate input: Check if eval_data exists and has the necessary structure
  if (is.null(eval_params$eval_data)) {
    stop("Statistical Parity Wrapper: 'eval_data' is missing.")
  }
  
  # Validate input: Check for missing protected attributes
  missing_columns <- setdiff(eval_params$protected_name, colnames(eval_params$eval_data))
  if (length(missing_columns) > 0) {
    stop(paste("Statistical Parity Wrapper: The following protected attributes are missing in 'eval_data':", 
               paste(missing_columns, collapse = ", ")))
  }
  
  # Validate input: Ensure all protected attributes are binary
  non_binary_attributes <- sapply(eval_params$protected_name, function(attr_name) {
    attribute <- eval_params$eval_data[[attr_name]]
    length(unique(attribute)) != 2
  })
  if (any(non_binary_attributes)) {
    stop(paste("Statistical Parity Wrapper: The following attributes are not binary:", 
               paste(eval_params$protected_name[non_binary_attributes], collapse = ", ")))
  }
  
  # Call the engine
  engine_eval_statisticalparity(
    eval_data = eval_params$eval_data,
    protected_name = eval_params$protected_name
  )
}
#--------------------------------------------------------------------