#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' User-Defined Split Engine
#'
#' Dummy engine to support externally provided training and test data.
#'
#' @param train A pre-defined training dataset.
#' @param test A pre-defined test dataset.
#' @return A list with the train and test sets.
#' @export
engine_split_userdefined <- function(train, test) {
  list(train = train, test = test)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for User-Defined Split Engine
#'
#' Uses pre-specified train/test data from the control object.
#'
#' @param control A list containing preloaded training and test datasets.
#' @return A standardized splitter output object with the provided data.
#' @export
wrapper_split_userdefined <- function(control) {
  if (is.null(control$data$train) || is.null(control$data$test)) {
    stop("wrapper_split_userdefined: Both train and test data must be provided in control$data.")
  }
  
  message("[INFO] Using user-provided train/test split.")
  
  # Call dummy engine for completeness
  split <- engine_split_userdefined(train = control$data$train, test = control$data$test)
  
  # Standardized output
  initialize_output_split(
    split_type = "userdefined",
    splits = list(user = split),
    seed = NULL,
    params = NULL,
    specific_output = list(source = "user_provided")
  )
}
#--------------------------------------------------------------------