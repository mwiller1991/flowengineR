#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Summary Statistics
#'
#' Computes basic statistical properties of the given predictions to evaluate their distribution.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `predictions`: A numeric vector of predicted values.
#'
#' **Output (returned to wrapper):**
#' - A named list of summary statistics, including mean, median, standard deviation, variance, percentiles, skewness, and kurtosis.
#'
#' @param predictions A numeric vector of predicted values.
#'
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
#' Wrapper for Evaluation Engine: Summary Statistics
#'
#' Validates and prepares standardized inputs, invokes the summary statistics engine,
#' and wraps the result using `initialize_output_eval()`.
#'
#' **Standardized Inputs:**
#' - `control$params$eval$eval_data$predictions`: A numeric vector of predicted values to be evaluated.
#' - `control$params$eval$protected_name`: Names of protected attributes (not used by this engine).
#' - `control$params$eval$params`: Optional engine-specific parameters (none used by this engine).
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_eval()`:
#'   - `metrics`: A named list with one entry `summary_stats`, containing the computed statistics.
#'   - `eval_type`: Set to `"summarystats_eval"`.
#'   - `input_data`: The evaluation input data object.
#'   - `params`: Set to `NULL`.
#'   - `specific_output`: Set to `NULL`.
#'
#' @param control A standardized control object (see `controller_evaluation()`).
#' @return A standardized evaluation output object.
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