#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Summary Statistics
#'
#' @param predictions A vector of predictions from the model.
#' @return A list of summary statistics including mean, median, sd, var, quantiles, etc.
#' @export
engine_eval_summarystats <- function(predictions) {
  stats <- c(
    mean = mean(predictions),
    median = median(predictions),
    sd = sd(predictions),
    var = var(predictions),
    min = min(predictions),
    max = max(predictions),
    quantile_25 = quantile(predictions, probs = 0.25),
    quantile_75 = quantile(predictions, probs = 0.75),
    iqr = IQR(predictions),
    skewness = moments::skewness(predictions),
    kurtosis = moments::kurtosis(predictions),
    range = diff(range(predictions))
  )
  
  return(as.list(stats))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Summary Statistics Evaluation
#'
#' @param control A list containing predictions.
#' @return A list of summary statistics for the predictions.
#' @export
wrapper_eval_summarystats <- function(control) {
  eval_params <- control$params$eval  # Accessing the evaluation parameters
  
  # Validate input: Predictions must be present
  if (is.null(eval_params$eval_data$predictions)) {
    stop("wrapper_eval_summary_stats: Missing required input: predictions")
  }
  
  # Call the specific evaluation engine
  stats_result <- engine_eval_summarystats(eval_params$eval_data$predictions)
  
  # Return the results
  return(stats_result)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
default_params_eval_summarystats <- function() {
  NULL  # This engine does not require specific parameters -> for any other engine would be a list() necessary
}
#--------------------------------------------------------------------