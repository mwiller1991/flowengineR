#--------------------------------------------------------------------
# Helper Function to Merge User-Provided and Default Hyperparameters
#--------------------------------------------------------------------
#' Helper Function to Merge User-Provided and Default Hyperparameters
#'
#' @param user_hyperparameters A list of hyperparameters provided by the user.
#' @param default_hyperparameters A list of default hyperparameters for the model.
#'
#' @return A list of hyperparameters where missing values are filled with defaults.
#' @export
merge_with_defaults <- function(user_hyperparameters, default_hyperparameters) {
  if (is.null(user_hyperparameters)) {
    return(default_hyperparameters)
  }
  # Combine defaults and user-provided parameters
  modifyList(default_hyperparameters, user_hyperparameters)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# Helper Function to Normalize Data
#--------------------------------------------------------------------
#' Helper Function to Normalize Data
#'
#' Normalizes numeric columns in a dataset to a range of [0, 1].
#'
#' @param data A data frame containing the dataset to normalize.
#' @param feature_names A character vector specifying the columns to normalize.
#'
#' @return A data frame with normalized columns.
#' @export
normalize_data <- function(data, feature_names) {
  for (feature in feature_names) {
    if (is.numeric(data[[feature]])) {
      data[[feature]] <- (data[[feature]] - min(data[[feature]], na.rm = TRUE)) /
        (max(data[[feature]], na.rm = TRUE) - min(data[[feature]], na.rm = TRUE))
    }
  }
  return(data)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# Helper Function to Select Training Data
#--------------------------------------------------------------------
#' Helper Function to Select Training Data
#'
#' Selects the appropriate dataset (normalized or original) for training
#' based on the `norm_data` flag.
#'
#' @param norm_data A logical value indicating whether normalized data should be used.
#'   - `TRUE`: Use the normalized dataset.
#'   - `FALSE`: Use the original dataset.
#' @param data A list containing two datasets:
#'   - `data$normalized`: The normalized dataset.
#'   - `data$original`: The original dataset.
#'
#' @return A data frame containing the selected dataset (normalized or original).
#' @export
select_training_data <- function(norm_data, data) {
  if (isTRUE(norm_data)) {
    # Use normalized data if specified
    return(data$normalized)
  } else {
    # Use original data by default
    return(data$original)
  }
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# Helper Function to Denormalize Predictions
#--------------------------------------------------------------------
#' Helper Function to Denormalize Predictions
#'
#' Takes predictions made on normalized data and transforms them back to the original scale
#' using the original dataset's min and max values.
#'
#' @param predictions A numeric vector of predictions made on normalized data.
#' @param original_data A data frame containing the original, non-normalized dataset.
#' @param feature_name The name of the feature/column for which the predictions were made.
#'
#' @return A numeric vector of predictions transformed back to the original scale.
#' @export
denormalize_predictions <- function(predictions, original_data, feature_name) {
  # Extract the min and max values from the original data
  min_original <- min(original_data[[feature_name]], na.rm = TRUE)
  max_original <- max(original_data[[feature_name]], na.rm = TRUE)
  
  # Transform predictions back to the original scale
  predictions_original_scale <- predictions * (max_original - min_original) + min_original
  
  return(predictions_original_scale)
}
#--------------------------------------------------------------------