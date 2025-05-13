#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Summary Statistics
#'
#' Computes summary statistics for the given predictions.
#'
#' **Inputs:**
#' - `predictions`: A numeric vector of predicted values.
#'
#' **Outputs (passed to wrapper):**
#' - `metrics`: A list containing summary statistics, including:
#'   - `mean`: Mean of the predictions.
#'   - `median`: Median of the predictions.
#'   - `sd`: Standard deviation.
#'   - `var`: Variance.
#'   - `min`: Minimum value.
#'   - `max`: Maximum value.
#'   - `quantile_25`: 25th percentile.
#'   - `quantile_75`: 75th percentile.
#'   - `iqr`: Interquartile range.
#'   - `skewness`: Skewness of the predictions.
#'   - `kurtosis`: Kurtosis of the predictions.
#'
#' @param predictions A numeric vector of predicted values.
#' @return A list containing the computed summary statistics.
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
#' Handles input validation, calls the Summary Statistics engine, and creates standardized output.
#'
#' @param control A list containing predictions and other evaluation parameters.
#' @return A standardized list containing the evaluation results.
#' @export
wrapper_eval_summarystats <- function(control) {
  eval_params <- control$params$eval
  
  # Validate input: Predictions must be present
  if (is.null(eval_params$eval_data$predictions)) {
    stop("wrapper_eval_summarystats: Missing required input: predictions")
  }
  
  # Call the engine
  summary_stats <- engine_eval_summarystats(
    predictions = as.numeric(eval_params$eval_data$predictions)
  )
  
  # Standardized output
  initialize_output_eval(
    metrics = list(summary_stats = summary_stats),
    eval_type = "summarystats_eval",
    input_data = eval_params$eval_data,
    params = NULL,
    specific_output = NULL
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Evaluation Engine: MSE
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
default_params_eval_summarystats <- function() {
  NULL
}
#--------------------------------------------------------------------