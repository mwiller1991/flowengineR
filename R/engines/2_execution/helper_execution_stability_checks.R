#--------------------------------------------------------------------
### custom relative ###
#--------------------------------------------------------------------
#' Stability Strategy: Custom Function (Relative Difference)
#'
#' Applies a custom function to both the full set of values and the trailing window,
#' and compares the **relative** difference. Stability is reached if the difference
#' is below the specified threshold.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for relative difference.
#' @param window Number of trailing values to include in the window.
#' @param fun A custom function (e.g., `mean`, `median`) applied to the value vectors.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed relative difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_custom_relative <- function(values, threshold, window, fun) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  stopifnot(is.function(fun))
  
  global_value <- fun(values)
  window_value <- fun(tail(values, window))
  base <- if (global_value == 0) 1e-8 else abs(global_value)
  delta <- abs(window_value - global_value) / base
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "custom_relative"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### custom absolute ###
#--------------------------------------------------------------------
#' Stability Strategy: Custom Function (Absolute Difference)
#'
#' Applies a custom function to both the full set of values and the trailing window,
#' and compares the absolute difference. Stability is reached if the difference
#' is below the specified threshold.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for absolute difference.
#' @param window Number of trailing values to include in the window.
#' @param fun A custom function (e.g., `mean`, `median`) applied to the value vectors.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed absolute difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_custom_absolute <- function(values, threshold, window, fun) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  stopifnot(is.function(fun))
  
  global_value <- fun(values)
  window_value <- fun(tail(values, window))
  delta <- abs(window_value - global_value)
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "custom_absolute"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### mean relative ###
#--------------------------------------------------------------------
#' Stability Strategy: Relative Change in Mean (Window vs Global)
#'
#' Evaluates whether the mean of the most recent values (window) differs
#' only marginally from the overall mean. Stability is reached if the relative
#' difference is below a threshold.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for relative difference.
#' @param window Number of trailing values to include in the window.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed relative difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_mean_relative <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  global_mean <- mean(values)
  window_mean <- mean(tail(values, window))
  base <- if (global_mean == 0) 1e-8 else abs(global_mean)
  delta <- abs(window_mean - global_mean) / base
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "mean_relative"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### mean absolute ###
#--------------------------------------------------------------------
#' Stability Strategy: Mean Absolute Deviation from Global Mean
#'
#' Evaluates whether the average absolute deviation of recent metric values (window)
#' from the global mean is below a given threshold.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for mean absolute deviation.
#' @param window Number of trailing values to include in the window.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed mean absolute deviation
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_mean_absolute <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  global_mean <- mean(values)
  window_values <- tail(values, window)
  deltas <- abs(window_values - global_mean)
  mad <- mean(deltas)
  
  list(
    is_stable = mad < threshold,
    stability_value = mad,
    threshold_value = threshold,
    strategy = "mean_absolute"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### sd relative ###
#--------------------------------------------------------------------
#' Stability Strategy: Standard Deviation (Relative Difference)
#'
#' Compares the relative difference between the standard deviation of the
#' full metric vector and the trailing window.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for relative difference.
#' @param window Number of trailing values to include in the window.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed relative difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_sd_relative <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  global_sd <- sd(values)
  window_sd <- sd(tail(values, window))
  base <- if (global_sd == 0) 1e-8 else abs(global_sd)
  delta <- abs(window_sd - global_sd) / base
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "sd_relative"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### sd absolute ###
#--------------------------------------------------------------------
#' Stability Strategy: Standard Deviation (Absolute Difference)
#'
#' Compares the absolute difference between the standard deviation of the
#' full metric vector and the trailing window.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for absolute difference.
#' @param window Number of trailing values to include in the window.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed absolute difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_sd_absolute <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  global_sd <- sd(values)
  window_sd <- sd(tail(values, window))
  delta <- abs(window_sd - global_sd)
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "sd_absolute"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### mad relative ###
#--------------------------------------------------------------------
#' Stability Strategy: Median Absolute Deviation (Relative Difference)
#'
#' Compares the relative difference between the MAD of the full vector and the window.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for relative difference.
#' @param window Number of trailing values to include in the window.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed relative difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_mad_relative <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  global_mad <- mad(values)
  window_mad <- mad(tail(values, window))
  base <- if (global_mad == 0) 1e-8 else abs(global_mad)
  delta <- abs(window_mad - global_mad) / base
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "mad_relative"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### mad absolute ###
#--------------------------------------------------------------------
#' Stability Strategy: Median Absolute Deviation (Absolute Difference)
#'
#' Compares the absolute difference between the MAD of the full and
#' trailing window metric values.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for absolute difference.
#' @param window Number of trailing values to include in the window.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed absolute difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_mad_absolute <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  global_mad <- mad(values)
  window_mad <- mad(tail(values, window))
  delta <- abs(window_mad - global_mad)
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "mad_absolute"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### cv relative ###
#--------------------------------------------------------------------
#' Stability Strategy: Coefficient of Variation (Relative Difference)
#'
#' Compares the relative difference between the CV (sd/mean) of the
#' full metric vector and the trailing window.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for relative difference.
#' @param window Number of trailing values to include in the window.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed relative difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_cv_relative <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  global_cv <- sd(values) / mean(values)
  window_cv <- sd(tail(values, window)) / mean(tail(values, window))
  base <- if (global_cv == 0) 1e-8 else abs(global_cv)
  delta <- abs(window_cv - global_cv) / base
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "cv_relative"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### cv absolute ###
#--------------------------------------------------------------------
#' Stability Strategy: Coefficient of Variation (Absolute Difference)
#'
#' Compares the absolute difference between the CV (sd/mean) of the
#' full metric vector and the trailing window.
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for absolute difference.
#' @param window Number of trailing values to include in the window.
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed absolute difference
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_cv_absolute <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  global_cv <- sd(values) / mean(values)
  window_cv <- sd(tail(values, window)) / mean(tail(values, window))
  delta <- abs(window_cv - global_cv)
  
  list(
    is_stable = delta < threshold,
    stability_value = delta,
    threshold_value = threshold,
    strategy = "cv_absolute"
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Cohen’s d ###
#--------------------------------------------------------------------
#' Stability Strategy: Cohen’s d (Absolute Difference)
#'
#' Computes the effect size (Cohen's d) between the values in the trailing
#' window and the full set. Stability is reached if the absolute effect size
#' is below the defined threshold.
#'
#' **Formula:**  
#' `d = |mean_window - mean_global| / pooled_sd`
#'
#' @param values Numeric vector of tracked metric values.
#' @param threshold Numeric threshold for Cohen's d (e.g., 0.2 = small effect).
#' @param window Number of trailing values to include in the window.
#' @param fun Placeholder for generic strategy interface (unused).
#'
#' @return A list with:
#'   - `is_stable`: TRUE if below threshold
#'   - `stability_value`: computed effect size
#'   - `threshold_value`: input threshold
#'   - `strategy`: identifier string
#'
#' @export
check_stability_cohen_absolute <- function(values, threshold, window, fun = NULL) {
  stopifnot(is.numeric(values), length(values) >= window + 1)
  
  window_vals <- tail(values, window)
  global_vals <- head(values, length(values) - window)
  if (length(global_vals) < 2) return(list(
    is_stable = FALSE,
    stability_value = Inf,
    threshold_value = threshold,
    strategy = "cohen_absolute"
  ))
  
  m1 <- mean(window_vals)
  m2 <- mean(global_vals)
  sd1 <- sd(window_vals)
  sd2 <- sd(global_vals)
  pooled_sd <- sqrt((sd1^2 + sd2^2) / 2)
  if (pooled_sd == 0) pooled_sd <- 1e-8
  
  d <- abs(m1 - m2) / pooled_sd
  
  list(
    is_stable = d < threshold,
    stability_value = d,
    threshold_value = threshold,
    strategy = "cohen_absolute"
  )
}
#--------------------------------------------------------------------