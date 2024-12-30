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