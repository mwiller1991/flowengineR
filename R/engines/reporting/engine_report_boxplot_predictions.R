#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Engine for Reporting: Boxplot of Predictions by Group
#'
#' Aggregates predictions from all splits and generates a ggplot2 boxplot
#' grouped by the specified binary group variable (e.g., "genderMale").
#'
#' @param workflow_results A named list of workflow results per split.
#' @param group_var A character string specifying the grouping variable.
#'
#' @return A ggplot2 object showing grouped boxplots.
#' @export
engine_report_boxplot_predictions <- function(workflow_results, split_output, group_var, source) {
  combined <- do.call(rbind, lapply(names(workflow_results), function(split) {
    split_result <- workflow_results[[split]]
    test_data <- split_output[[split]]$test
    
    predictions <- switch(source,
                          train = split_result$output_train$predictions,
                          post = split_result$output_fairness_post$adjusted_predictions,
                          inproc = split_result$output_fairness_in$predictions,
                          stop("Unknown source for predictions.")
    )
    
    if (is.null(predictions) || is.null(test_data[[group_var]])) return(NULL)
    
    data.frame(
      prediction = predictions,
      group = as.factor(test_data[[group_var]]),
      split = split
    )
  }))
  
  if (nrow(combined) == 0) stop("No data available to create boxplot.")
  
  ggplot2::ggplot(combined, ggplot2::aes(x = group, y = prediction)) +
    ggplot2::geom_boxplot(outlier.alpha = 0.2) +
    ggplot2::facet_wrap(~split) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = paste("Predictions by", group_var, "(source:", source, ")"),
      x = group_var,
      y = "Prediction"
    )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Boxplot Reporting Engine
#'
#' Handles control input and initializes standardized reporting output.
#'
#' @param control The control object.
#' @param workflow_results The list of workflow results.
#' @param alias Alias for this reporting instance.
#'
#' @return A standardized list containing the ggplot object.
#' @export
wrapper_report_boxplot_predictions <- function(control, workflow_results, split_output, alias = NULL) {
  report_params <- control$params$report  # Accessing the report parameters
  if (is.null(alias)) stop("Reporting alias must be specified.")
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(report_params$params[[alias]], default_params_report_boxplot_predictions())
  
  plot <- engine_report_boxplot_predictions(
    workflow_results = workflow_results,
    split_output = split_output$splits,
    group_var = params$group_var,
    source = params$source
  )
  
  initialize_output_report(
    report_object = plot,
    report_type = "boxplot_predictions",
    input_data = names(workflow_results),
    params = params,
    specific_output = list(
      alias = alias,
      group_var = params$group_var,
      source = params$source
    )
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Boxplot Reporting Engine
#'
#' @return A list with default group_var.
#' @export
default_params_report_boxplot_predictions <- function() {
  list(
    source = "train"  # can be "train", "post", or "inproc"
  )
}
#--------------------------------------------------------------------