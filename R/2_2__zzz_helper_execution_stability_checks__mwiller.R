#--------------------------------------------------------------------
### Strategy: Custom Relative ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Custom Function (Relative Difference)
#'
#' Applies a user-defined function (e.g., `mean`, `median`) to the complete set of metric values
#' and to the trailing window. Compares the relative difference between both to determine if 
#' the metric has stabilized.
#'
#' This strategy is intended for use in adaptive execution workflows where the evaluation
#' metric should converge over time (e.g., across cross-validation splits or random seeds).
#'
#' **Stability Rule:**
#' - Compute statistic on all values → `global_value`
#' - Compute same statistic on trailing `window` values → `window_value`
#' - Compute relative difference `|window_value - global_value| / |global_value|`
#' - If this is below `threshold`, return `is_stable = TRUE`
#'
#' **Notes:**
#' - If `global_value` is 0, a small constant is used to avoid division by zero.
#' - The function must be numeric and produce a single scalar.
#'
#' @param values Numeric vector. History of tracked metric values.
#' @param threshold Numeric. Maximum allowed relative deviation.
#' @param window Integer. Size of trailing window.
#' @param fun Function. Custom summary function (e.g., `mean`, `median`).
#'
#' @return A named list:
#'   - `is_stable`: Logical. Whether convergence is reached.
#'   - `stability_value`: Computed relative difference.
#'   - `threshold_value`: The comparison threshold.
#'   - `strategy`: Strategy identifier string.
#'
#' @keywords internal
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
### Strategy: Custom Absolute ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Custom Function (Absolute Difference)
#'
#' Applies a user-defined function (e.g., `mean`, `median`) to the complete set of metric values
#' and to the trailing window. Compares the absolute difference between both to determine if 
#' the metric has stabilized.
#'
#' This strategy is intended for use in adaptive execution workflows where the evaluation
#' metric should converge over time (e.g., across cross-validation splits or random seeds).
#'
#' **Stability Rule:**
#' - Compute statistic on all values → `global_value`
#' - Compute same statistic on trailing `window` values → `window_value`
#' - Compute absolute difference `|window_value - global_value|`
#' - If this is below `threshold`, return `is_stable = TRUE`
#'
#' **Notes:**
#' - The function `fun` must return a numeric scalar.
#' - No normalization or relative scaling is performed.
#'
#' @param values Numeric vector. History of tracked metric values.
#' @param threshold Numeric. Maximum allowed absolute deviation.
#' @param window Integer. Size of trailing window.
#' @param fun Function. Custom summary function (e.g., `mean`, `median`).
#'
#' @return A named list:
#'   - `is_stable`: Logical. Whether convergence is reached.
#'   - `stability_value`: Computed absolute difference.
#'   - `threshold_value`: The comparison threshold.
#'   - `strategy`: Strategy identifier string.
#'
#' @keywords internal
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
### Strategy: Mean Relative ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Relative Change in Mean (Window vs Global)
#'
#' Compares the mean of the full metric history to the mean of the most recent values 
#' (window) and checks whether their relative difference is below a defined threshold.
#' Used to assess convergence behavior in adaptive workflows.
#'
#' **Stability Rule:**
#' - Compute global mean across all metric values.
#' - Compute window mean over the trailing `window` values.
#' - Calculate relative deviation:
#'   `|window_mean - global_mean| / |global_mean|`
#' - Stability is confirmed if this relative value is below `threshold`.
#'
#' **Notes:**
#' - Handles division-by-zero via fallback (`1e-8`) to avoid instability.
#' - This is a fixed strategy; the `fun` argument is ignored and exists for compatibility only.
#'
#' @param values Numeric vector. Complete list of metric values.
#' @param threshold Numeric. Maximum allowed relative difference.
#' @param window Integer. Number of trailing values to use for local mean.
#' @param fun Ignored. Included for compatibility with the custom strategy interface.
#'
#' @return A named list:
#'   - `is_stable`: Logical. Whether convergence is reached.
#'   - `stability_value`: Computed relative deviation.
#'   - `threshold_value`: Threshold used for comparison.
#'   - `strategy`: Fixed string `"mean_relative"`.
#'
#' @keywords internal
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
### Strategy: Mean Absolute ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Mean Absolute Deviation from Global Mean
#'
#' Evaluates the average absolute deviation of the most recent metric values (window)
#' from the overall mean. This strategy is useful for detecting whether local fluctuations 
#' converge around the global trend.
#'
#' **Stability Rule:**
#' - Compute the mean across all available metric values.
#' - Compute the absolute deviation of the last `window` values from the global mean.
#' - Compute the mean of these deviations.
#' - Stability is confirmed if this value is smaller than the specified `threshold`.
#'
#' **Notes:**
#' - More robust to outliers than simple relative mean comparisons.
#' - The `fun` argument is ignored and exists only for interface compatibility.
#'
#' @param values Numeric vector. Historical metric values collected across iterations.
#' @param threshold Numeric. Maximum allowed average deviation from the global mean.
#' @param window Integer. Number of recent iterations considered.
#' @param fun Ignored. Reserved for compatibility with other strategy interfaces.
#'
#' @return A named list:
#'   - `is_stable`: Logical. TRUE if the strategy deems the process stable.
#'   - `stability_value`: Computed mean absolute deviation.
#'   - `threshold_value`: The threshold used for comparison.
#'   - `strategy`: Fixed string `"mean_absolute"`.
#'
#' @keywords internal
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
### Strategy: SD Relative ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Standard Deviation (Relative Difference)
#'
#' Evaluates the relative change in variability over time by comparing the standard deviation 
#' of all observed metric values with the standard deviation of the most recent `window` values.
#'
#' **Stability Rule:**
#' - Compute the standard deviation (SD) of the full metric vector.
#' - Compute the SD of the last `window` values.
#' - Calculate the relative difference between both values.
#' - If the relative difference is below `threshold`, stability is reached.
#'
#' **Use Case:**
#' - Good for identifying when variance in the metric stabilizes around a consistent level.
#'
#' **Notes:**
#' - The `fun` argument is ignored and only present for compatibility.
#'
#' @param values Numeric vector. Metric values collected across iterations.
#' @param threshold Numeric. Maximum allowed relative SD difference.
#' @param window Integer. Number of trailing values to include in the moving window.
#' @param fun Ignored. Reserved for strategy interface consistency.
#'
#' @return A named list:
#'   - `is_stable`: Logical. TRUE if relative SD difference is below `threshold`.
#'   - `stability_value`: Computed relative difference.
#'   - `threshold_value`: The threshold provided as input.
#'   - `strategy`: Fixed string `"sd_relative"`.
#'
#' @keywords internal
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
### Strategy: SD Absolute ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Standard Deviation (Absolute Difference)
#'
#' Evaluates the absolute change in variability over time by comparing the standard deviation 
#' of all observed metric values with the standard deviation of the most recent `window` values.
#'
#' **Stability Rule:**
#' - Compute the standard deviation (SD) of the full metric vector.
#' - Compute the SD of the last `window` values.
#' - Calculate the absolute difference between both values.
#' - If the absolute difference is below `threshold`, stability is reached.
#'
#' **Use Case:**
#' - Suitable for detecting when variability settles near a stable range regardless of scale.
#'
#' **Notes:**
#' - The `fun` argument is ignored and only present for compatibility.
#'
#' @param values Numeric vector. Metric values collected across iterations.
#' @param threshold Numeric. Maximum allowed absolute SD difference.
#' @param window Integer. Number of trailing values to include in the moving window.
#' @param fun Ignored. Reserved for strategy interface consistency.
#'
#' @return A named list:
#'   - `is_stable`: Logical. TRUE if absolute SD difference is below `threshold`.
#'   - `stability_value`: Computed absolute difference.
#'   - `threshold_value`: The threshold provided as input.
#'   - `strategy`: Fixed string `"sd_absolute"`.
#'
#' @keywords internal
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
### Strategy: MAD Relative ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Median Absolute Deviation (Relative Difference)
#'
#' Evaluates the relative change in variability based on the Median Absolute Deviation (MAD).
#' Compares the MAD of all observed metric values with the MAD of the most recent values.
#'
#' **Stability Rule:**
#' - Compute the MAD of the full metric vector.
#' - Compute the MAD of the last `window` values.
#' - Calculate the relative difference between both.
#' - If this difference is below `threshold`, stability is considered achieved.
#'
#' **Use Case:**
#' - Useful for stability assessment in metrics with heavy-tailed or skewed distributions.
#'
#' **Notes:**
#' - The `fun` argument is ignored and only present for compatibility with other strategy functions.
#'
#' @param values Numeric vector. Metric values collected across iterations.
#' @param threshold Numeric. Maximum allowed relative MAD difference.
#' @param window Integer. Number of trailing values to include in the moving window.
#' @param fun Ignored. Reserved for interface consistency across strategies.
#'
#' @return A named list:
#'   - `is_stable`: Logical. TRUE if relative MAD difference is below `threshold`.
#'   - `stability_value`: Computed relative difference.
#'   - `threshold_value`: The threshold provided as input.
#'   - `strategy`: Fixed string `"mad_relative"`.
#'
#' @keywords internal
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
### Strategy: MAD Absolute ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Median Absolute Deviation (Absolute Difference)
#'
#' Evaluates the absolute change in variability based on the Median Absolute Deviation (MAD).
#' Compares the MAD of all observed metric values with the MAD of the most recent values.
#'
#' **Stability Rule:**
#' - Compute the MAD of the full metric vector.
#' - Compute the MAD of the last `window` values.
#' - Calculate the absolute difference between both.
#' - If this difference is below `threshold`, stability is considered achieved.
#'
#' **Use Case:**
#' - Useful for metrics where relative comparisons are not appropriate (e.g., small ranges).
#'
#' **Notes:**
#' - The `fun` argument is ignored and only included for compatibility with other strategy functions.
#'
#' @param values Numeric vector. Metric values collected across iterations.
#' @param threshold Numeric. Maximum allowed absolute MAD difference.
#' @param window Integer. Number of trailing values to include in the moving window.
#' @param fun Ignored. Reserved for interface consistency across strategies.
#'
#' @return A named list:
#'   - `is_stable`: Logical. TRUE if absolute MAD difference is below `threshold`.
#'   - `stability_value`: Computed absolute difference.
#'   - `threshold_value`: The threshold provided as input.
#'   - `strategy`: Fixed string `"mad_absolute"`.
#'
#' @keywords internal
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
### Strategy: CV Relative ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Coefficient of Variation (Relative Difference)
#'
#' Evaluates whether the variability relative to the mean (CV = sd/mean) 
#' remains stable over time. Compares the CV of all metric values with 
#' the CV of the most recent subset.
#'
#' **Stability Rule:**
#' - Compute the CV of the full vector: `cv_global = sd / mean`.
#' - Compute the CV of the trailing window: `cv_window = sd / mean`.
#' - Calculate the relative difference between both CVs.
#' - If this difference is below `threshold`, stability is achieved.
#'
#' **Use Case:**
#' - Suitable for metrics where both mean and variability matter.
#'
#' **Notes:**
#' - The `fun` argument is ignored; included for interface consistency.
#'
#' @param values Numeric vector. Metric values collected across iterations.
#' @param threshold Numeric. Maximum allowed relative difference.
#' @param window Integer. Number of trailing values to include in the window.
#' @param fun Ignored. Reserved for interface consistency across strategies.
#'
#' @return A named list:
#'   - `is_stable`: Logical. TRUE if relative CV difference is below `threshold`.
#'   - `stability_value`: Computed relative CV difference.
#'   - `threshold_value`: The threshold provided as input.
#'   - `strategy`: Fixed string `"cv_relative"`.
#'
#' @keywords internal
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
### Strategy: CV Absolute ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Coefficient of Variation (Absolute Difference)
#'
#' Evaluates whether the coefficient of variation (CV = sd/mean) has stabilized 
#' by comparing the absolute difference between the full vector and the trailing window.
#'
#' **Stability Rule:**
#' - Compute CV of the full vector: `cv_global = sd(values) / mean(values)`
#' - Compute CV of the last `window` values: `cv_window = sd(tail(values, window)) / mean(tail(values, window))`
#' - If `|cv_window - cv_global| < threshold`, stability is reached.
#'
#' **Use Case:**
#' - Suitable when both dispersion and scale must be monitored jointly.
#'
#' **Notes:**
#' - `fun` argument is ignored; included for signature consistency.
#'
#' @param values Numeric vector. Metric values collected across iterations.
#' @param threshold Numeric. Maximum allowed absolute difference.
#' @param window Integer. Number of trailing values to include in the window.
#' @param fun Ignored. Included for consistent interface across strategies.
#'
#' @return A named list:
#'   - `is_stable`: Logical. Indicates if stability is achieved.
#'   - `stability_value`: Computed absolute CV difference.
#'   - `threshold_value`: The threshold provided as input.
#'   - `strategy`: Fixed string `"cv_absolute"`.
#'
#' @keywords internal
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
### Strategy: Cohen’s d (Absolute Difference) ###
#--------------------------------------------------------------------
#' Internal Stability Strategy: Cohen’s d (Absolute Difference)
#'
#' Evaluates the effect size between the most recent metric values (`window`) and
#' the earlier observations using **Cohen’s d**. Stability is considered achieved if
#' the effect size is smaller than the defined threshold.
#'
#' **Stability Rule:**
#' - Compute mean and standard deviation for both:
#'   - `window`: Last `window` values.
#'   - `global`: All preceding values.
#' - Compute pooled standard deviation:
#'   \deqn{sd_pooled = sqrt((sd_1^2 + sd_2^2) / 2)}
#' - Compute effect size:
#'   \deqn{d = |mean_1 - mean_2| / sd_pooled}
#' - If `d < threshold`, then `is_stable = TRUE`.
#'
#' **Use Case:**
#' - Appropriate when magnitude of mean difference relative to variability matters.
#'
#' **Notes:**
#' - Falls back to `Inf` if not enough global values are available.
#' - `fun` argument is ignored; included for interface consistency.
#'
#' @param values Numeric vector. Metric values collected across iterations.
#' @param threshold Numeric. Maximum allowed Cohen’s d effect size.
#' @param window Integer. Number of trailing values to include in the window.
#' @param fun Ignored. Included for consistent interface across strategies.
#'
#' @return A named list:
#'   - `is_stable`: Logical. Indicates if stability is achieved.
#'   - `stability_value`: Computed Cohen’s d effect size.
#'   - `threshold_value`: The threshold provided as input.
#'   - `strategy`: Fixed string `"cohen_absolute"`.
#'
#' @keywords internal
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