#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Reportelement Engine: Boxplot of Predictions by Group
#'
#' Aggregates predictions from all splits and creates a `ggplot2` boxplot grouped by a specified binary attribute.
#' Supports different prediction sources (raw model, post-processed, or in-processing adjusted).
#'
#' **Inputs (passed to engine via wrapper):**
#' - `workflow_results`: Named list of per-split workflow results.
#' - `split_output`: Named list of split data, including test sets.
#' - `group_var`: Character string specifying the grouping variable.
#' - `source`: Character string, one of `"train"`, `"post"`, or `"inproc"`.
#'
#' **Output (returned to wrapper):**
#' - A `ggplot2` object visualizing prediction distributions per group and per split.
#'
#' @param workflow_results A named list of workflow results per split.
#' @param split_output A list of split metadata (including test data).
#' @param group_var A character string specifying the grouping variable.
#' @param source One of `"train"`, `"post"`, or `"inproc"`.
#'
#' @return A `ggplot2` object showing grouped boxplots per split.
#' @export
engine_reportelement_boxplot_predictions <- function(workflow_results, split_output, group_var, source) {
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
#' Wrapper for Reportelement Engine: Boxplot of Predictions
#'
#' Validates and prepares standardized inputs, merges default and user-defined parameters,
#' and invokes the boxplot prediction engine. Returns standardized reportelement output.
#'
#' **Standardized Inputs:**
#' - `control$params$reportelement$params[[alias]]`: Named list of engine-specific parameters (e.g., `group_var`, `source`).
#' - `workflow_results`: List of workflow results per split.
#' - `split_output`: List of split definitions from the splitter engine.
#' - `alias`: Character string identifying the reportelement instance.
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_reportelement()`:
#'   - `type`: `"plot"`.
#'   - `content`: ggplot2 object.
#'   - `compatible_formats`: c("pdf", "html").
#'   - `input_data`: Names of splits used.
#'   - `params`: Merged parameter list.
#'   - `specific_output`: Metadata including alias, group variable, and prediction source.
#'
#' @param control A standardized control object (see `controller_reportelement()`).
#' @param workflow_results Named list of workflow results.
#' @param split_output Output list from the splitter engine.
#' @param alias Unique identifier for this reportelement instance.
#'
#' @return A standardized reportelement output object.
#' @export
wrapper_reportelement_boxplot_predictions <- function(control, workflow_results, split_output, alias = NULL) {
  report_params <- control$params$reportelement
  if (is.null(alias)) stop("Reportelement alias must be specified.")
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(report_params$params[[alias]], default_params_reportelement_boxplot_predictions())
  
  plot <- engine_reportelement_boxplot_predictions(
    workflow_results = workflow_results,
    split_output = split_output$splits,
    group_var = params$group_var,
    source = params$source
  )
  
  initialize_output_reportelement(
    type = "plot",
    content = plot,
    compatible_formats = c("pdf", "html"),
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
#' Default Parameters for Reportelement Engine: Boxplot Predictions
#'
#' Provides default parameters for the `reportelement_boxplot_predictions` engine.
#' These parameters define which prediction source is used for the boxplot.
#'
#' **Purpose:**
#' - Controls the prediction type visualized in the boxplot.
#' - Allows selection between raw model output and fairness-adjusted predictions.
#'
#' **Default Parameters:**
#' - `source`: Determines which predictions to visualize. Options are:
#'     - `"train"`: raw model predictions (default)
#'     - `"post"`: post-processed predictions (e.g., adjusted for fairness)
#'     - `"inproc"`: in-processing adjusted predictions
#'
#' @return A named list of default parameters for the boxplot predictions reportelement engine.
#' @export
default_params_reportelement_boxplot_predictions <- function() {
  list(
    source = "train"  # can be "train", "post", or "inproc"
  )
}
#--------------------------------------------------------------------