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
#' @seealso [wrapper_eval_summarystats()]
#'
#' @param predictions A numeric vector of predicted values.
#'
#' @return A list containing the computed summary statistics.
#' @keywords internal
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
#' - `control$params$eval$eval_data$predictions`: Numeric vector of predictions (automatically provided by workflow).
#' - `control$params$eval$protected_name`: Names of protected attributes (not used by this engine).
#' - `control$params$eval$params`: Optional engine-specific parameters (none used here).
#'
#' **Engine-Specific Parameters (`control$params$eval$params`):**
#' - None. This engine performs statistical evaluation using fixed metrics.
#'
#' **Example Control Snippet:**
#' ```
#' control$evaluation <- "eval_summarystats"
#' control$params$eval <- controller_evaluation(
#'   protected_name = c("gender")
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/7_1_a_template_eval_summarystats.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_eval()`:
#' - `metrics`: List with entry `summary_stats`, containing:
#'     - `mean`, `median`, `sd`, `var`, `min`, `max`, `quantile_25`, `quantile_75`, `iqr`, `skewness`, `kurtosis`, `range`
#' - `eval_type`: `"summarystats_eval"`
#' - `input_data`: Original evaluation input (predictions etc.)
#' - `params`: `NULL` (no tunable parameters)
#' - `specific_output`: `NULL`
#'
#' @seealso 
#'   [engine_eval_summarystats()],  
#'   [default_params_eval_summarystats()],  
#'   [initialize_output_eval()],  
#'   [controller_evaluation()],  
#'   Template: `inst/templates_control/7_1_a_template_eval_summarystats.R`
#'
#' @param control A standardized control object (see `controller_evaluation()`).
#' @return A standardized evaluation output object.
#' @keywords internal
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
#' @seealso [wrapper_eval_summarystats()]
#'
#' @return A list of default parameters for the MSE evaluation engine.
#' @keywords internal
default_params_eval_summarystats <- function() {
  NULL
}
#--------------------------------------------------------------------