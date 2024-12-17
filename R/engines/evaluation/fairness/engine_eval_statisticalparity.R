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
engine_eval_statisticalparity <- function(predictions, actuals, protected_attribute, protected_name) {
  results <- sapply(seq_along(protected_name), function(i) {
    attribute <- protected_attribute[[i]]
    levels <- unique(attribute)
    
    if (length(levels) != 2) {
      stop(paste("Statistical Parity requires binary attributes. Issue with:", protected_name[i]))
    }
    
    # Calculate mean prediction for each group
    group_means <- tapply(predictions, attribute, mean)
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
  if (is.null(eval_params$predictions)) stop("Missing predictions for Statistical Parity")
  if (is.null(eval_params$protected_attribute)) stop("Missing protected attributes for Statistical Parity")
  
  # Call the engine
  engine_eval_statistical_parity(
    predictions = eval_params$predictions,
    actuals = eval_params$actuals,
    protected_attribute = eval_params$protected_attribute,
    protected_name = eval_params$protected_name
  )
}
#--------------------------------------------------------------------