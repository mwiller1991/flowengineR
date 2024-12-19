# Meta-level Workflow

#' Run the full workflow
#'
#' @param control A list containing all parameters for the workflow.
#' @return A list containing the trained model and predictions.
#' @export
run_workflow <- function(control) {
  # 1. Fairness Pre-Processing (optional)
  if (!is.null(control$fairness_pre)) {
    pre_fairness_driver <- engines[[control$fairness_pre]]
    control <- pre_fairness_driver(control)
  }
  
  # 2. Training (with optional In-Processing Fairness)
  model_driver <- engines[[control$model]]
  if (!is.null(control$fairness_in)) {
    in_fairness_driver <- engines[[control$fairness_in]]
    model_output <- in_fairness_driver(control, model_driver)
  } else {
    model_output <- model_driver(control)
  }
  predictions <- as.numeric(model_output$predictions)
  
  # Update control with predictions for post-processing
  control$params$fairness$predictions <- predictions
  
  
  # 3. Fairness Post-Processing (optional)
  if (!is.null(control$fairness_post)) {
    post_fairness_driver <- engines[[control$fairness_post]]
    adjusted_predictions <- post_fairness_driver(control)
  }
  
  # Update control for evaluation
  control$params$eval$predictions <- adjusted_predictions
  
  # Execute all evaluation wrappers
  evaluation_results <- lapply(control$evaluation, function(metric) {
    engines[[metric]](control$params$eval)
  })
  names(evaluation_results) <- control$evaluation
  
  # Return results
  list(
    model = model_output$model,
    predictions = predictions,
    adjusted_predictions = adjusted_predictions,
    evaluation = evaluation_results
  )
}