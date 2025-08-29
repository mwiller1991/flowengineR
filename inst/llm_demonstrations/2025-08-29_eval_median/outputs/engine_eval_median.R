#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Median of Predictions
#'
#' Computes the median of the predicted values.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `predictions`: A numeric vector of predicted values.
#' - `actuals`: A numeric vector of actual observed values (not used by this engine; accepted for a consistent signature).
#' - `na_rm`: Logical indicating whether `NA` values should be removed before computing the median.
#'
#' **Output (returned to wrapper):**
#' - A single numeric value representing the median of predictions.
#'
#' @seealso [wrapper_eval_median()], [default_params_eval_median()]
#' @param predictions Numeric vector of predicted values.
#' @param actuals Numeric vector of actual values (unused).
#' @param na_rm Logical; if TRUE, remove NA values before computing the median.
#' @return A single numeric value: the median of predictions.
#' @keywords internal
engine_eval_median <- function(predictions, actuals = NULL, na_rm = TRUE) {
  preds <- as.numeric(predictions)

  if (!na_rm && any(is.na(preds))) {
    # If we keep NAs and any NA exists, the result will be NA_real_
    return(stats::median(preds, na.rm = FALSE))
  }

  # Remove NAs if requested
  preds_clean <- if (na_rm) preds[!is.na(preds)] else preds

  if (length(preds_clean) == 0L) {
    warning("engine_eval_median: No non-missing predictions available. Returning NA_real_.")
    return(NA_real_)
  }

  stats::median(preds_clean, na.rm = FALSE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Evaluation Engine: Median of Predictions
#'
#' Validates and prepares standardized inputs, applies default parameters,
#' and invokes the median evaluation engine. Wraps the result using `initialize_output_eval()`.
#'
#' **Standardized Inputs (injected by the workflow via `control`):**
#' - `control$params$evaluation$eval_data$predictions`: Numeric vector of predicted values.
#' - `control$params$evaluation$eval_data$actuals`: Numeric vector of actual values (not used here).
#' - `control$params$evaluation$protected_attributes`: Optional `data.frame` of protected attributes.
#' - `control$params$evaluation$params$eval_median`: Optional engine-specific parameters list.
#'
#' **Engine-Specific Parameters (`control$params$evaluation$params$eval_median`):**
#' - `na_rm` (logical, default `TRUE`): Remove `NA` values before computing the median.
#'
#' **Standardized Output (returned to framework via `initialize_output_eval()`):**
#' - `metrics`: Named list with entry `median_prediction` (numeric).
#' - `eval_type`: `"median_prediction_eval"`.
#' - `input_data`: Evaluation input (`eval_data`).
#' - `protected_attributes`: Passed through from control (optional).
#' - `params`: Effective parameter list used for the computation.
#' - `specific_output`: `NULL`.
#'
#' @seealso 
#'   [engine_eval_median()],  
#'   [default_params_eval_median()],  
#'   [initialize_output_eval()],  
#'   [controller_evaluation()]
#'
#' @param control A standardized control object (see `controller_evaluation()`).
#' @return A standardized evaluation output object.
#' @keywords internal
wrapper_eval_median <- function(control) {
  eval_params <- control$params$evaluation
  
  # Basic input presence checks
  if (is.null(eval_params$eval_data$predictions)) {
    stop("wrapper_eval_median: Missing required input: predictions")
  }
  # `actuals` are optional for this engine but commonly present; we allow NULL.

  # Merge optional parameters with defaults
  specific_params <- eval_params$params[["eval_median"]] %||% list()
  params <- merge_with_defaults(specific_params, default_params_eval_median())

  # Compute metric
  median_pred <- engine_eval_median(
    predictions = as.numeric(eval_params$eval_data$predictions),
    actuals     = eval_params$eval_data$actuals,
    na_rm       = isTRUE(params$na_rm)
  )

  log_msg(sprintf("[EVAL] Median of predictions computed. median = %s",
                  ifelse(is.na(median_pred), "NA", formatC(median_pred, digits = 6, format = "fg"))),
         level = "info", control = control)

  # Wrap standardized output
  initialize_output_eval(
    metrics = list(median_prediction = median_pred),
    eval_type = "median_prediction_eval",
    input_data = eval_params$eval_data,
    protected_attributes = eval_params$protected_attributes,
    params = params,
    specific_output = NULL
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Evaluation Engine: Median of Predictions
#'
#' Provides default parameters for the median-of-predictions evaluation engine.
#'
#' **Defaults:**
#' - `na_rm = TRUE`: Remove `NA` values before computing the median.
#'
#' @seealso [wrapper_eval_median()]
#' @return A list of default parameters for the median evaluation engine.
#' @keywords internal
default_params_eval_median <- function() {
  list(
    na_rm = TRUE
  )
}
#--------------------------------------------------------------------
