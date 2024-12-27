#--------------------------------------------------------------------
### master workflow ###
#--------------------------------------------------------------------
# Meta-level Workflow

#' Run the full workflow
#'
#' @param control A list containing all parameters for the workflow.
#' @return A list containing the trained model and predictions.
#' @export
run_workflow <- function(control) {
  # 0. Automatic data splitting if needed
  if (is.null(control$data$train) || is.null(control$data$test)) {
    message("Train and test data not provided. Splitting data automatically...")
    split <- split_data(control$data$full)
    control$data$train <- split$train
    control$data$test <- split$test
  }
  
  # 1. Assigning data in the meta-level
  # Ensure training data is available for training
  control$params$train$data <- control$data$train
  
  # Ensure test data is available for fairness and evaluation
  control$params$fairness$actuals <- control$data$test[[control$variable_config$target_var]]
  control$params$eval$actuals <- control$data$test[[control$variable_config$target_var]]
  control$params$eval$protected_attribute <- control$data$test[control$variable_config$protected_vars]
  
  # 2. Fairness Pre-Processing (optional)
  if (!is.null(control$fairness_pre)) {
    pre_fairness_driver <- engines[[control$fairness_pre]]
    control <- pre_fairness_driver(control)
  }
  
  # 3. Training (with optional In-Processing Fairness)
  model_driver <- engines[[control$model]]
  if (!is.null(control$fairness_in)) {
    in_fairness_driver <- engines[[control$fairness_in]]
    model_output <- in_fairness_driver(control, model_driver)
  } else {
    model_output <- model_driver(control)
  }
  predictions <- predict(model_output$model, newdata = control$data$test)
  
  # 4. Fairness Post-Processing (optional)
  if (!is.null(control$fairness_post)) {
    control$params$fairness$predictions <- predictions
    post_fairness_driver <- engines[[control$fairness_post]]
    predictions <- post_fairness_driver(control)
  }
  
  # 5. Evaluation
  control$params$eval$predictions <- predictions
  evaluation_results <- lapply(control$evaluation, function(metric) {
    engines[[metric]](control$params$eval)
  })
  names(evaluation_results) <- control$evaluation
  
  # Return results
  list(
    model = model_output$model,
    predictions = predictions,
    evaluation = evaluation_results
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### data splitter ###
#--------------------------------------------------------------------
#' Split Data into Training and Test Sets
#'
#' Splits the dataset into training and test sets based on a given ratio.
#' @param data The full dataset as a data frame.
#' @param split_ratio The ratio of data to use for training (default: 0.7).
#' @param seed A random seed for reproducibility (default: 123).
#' @return A list with two elements: train and test datasets.
split_data <- function(data, split_ratio = 0.7, seed = 123) {
  set.seed(seed)
  train_indices <- sample(1:nrow(data), size = split_ratio * nrow(data))
  list(
    train = data[train_indices, ],
    test = data[-train_indices, ]
  )
}
#--------------------------------------------------------------------