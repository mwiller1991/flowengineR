#--------------------------------------------------------------------
### single round master workflow ###
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
  control$params$fairness$actuals <- control$data$test[[control$vars$target_var]]
  
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
  predictions <- as.numeric(predict(model_output$model, newdata = control$data$test))
  
  # 4. Fairness Post-Processing (optional)
  if (!is.null(control$fairness_post)) {
    control$params$fairness$predictions <- predictions
    post_fairness_driver <- engines[[control$fairness_post]]
    predictions <- post_fairness_driver(control)
  }
  
  # 5. Evaluation
  control$params$eval$eval_data <- cbind(
    predictions = predictions,
    actuals = control$data$test[[control$vars$target_var]],
    control$data$test[control$vars$protected_vars_eval]
  )
  evaluation_results <- lapply(control$evaluation, function(metric) {
    engines[[metric]](control)
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
### full package master workflow ###
#--------------------------------------------------------------------
#' Run multiple workflow variants
#'
#' Executes the workflow in three variants: discrimination-free, best-estimate, and unawareness.
#' @param control The control object containing all parameters.
#' @return A list of results for each variant.
#' @export
run_workflow_variants <- function(control) {
  results <- list()
  
  # 1. discrimination-free workflow
  message("Running discrimination-free workflow...")
  results$discriminationfree <- run_workflow(control)
  
  # 2. best-estimate workflow (no fairness adjustments)
  message("Running best-estimate workflow (no fairness adjustments)...")
  bestestimate_control <- control
  bestestimate_control$fairness_pre <- NULL
  bestestimate_control$fairness_in <- NULL
  bestestimate_control$fairness_post <- NULL
  results$bestestimate <- run_workflow(bestestimate_control)
  
  # 3. Unawareness workflow (removing protected variables)
  message("Running unawareness workflow (removing protected variables)...")
  unawareness_control <- control
  unawareness_control$params$train$formula <- as.formula(paste(
    control$vars$target_var, "~", paste(control$vars$feature_vars, collapse = " + ")
  ))
  unawareness_control$vars$feature_vars <- setdiff(
    control$vars$feature_vars,
    control$vars$protected_vars
  )
  results$unawareness <- run_workflow(unawareness_control)
  
  return(results)
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