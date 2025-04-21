#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Reporting Engine: Table of Evaluation Metrics per Split
#'
#' Creates a data.frame summarizing selected evaluation metrics for each split.
#'
#' **Input:**
#' - `workflow_results`: List of workflow results per split.
#' - `metrics`: Vector of metrics to extract for each split.
#'
#' @param workflow_results A named list of workflow results (from multiple splits).
#' @param metrics A vector of metric names to extract (e.g., c("mse", "statistical_parity")).
#' @return A data.frame with one row per split and one column per selected metric.
#' @export
engine_report_table_splitmetrics <- function(workflow_results, metrics) {
  result_rows <- lapply(names(workflow_results), function(split_name) {
    split_result <- workflow_results[[split_name]]
    
    all_values <- list()
    
    for (metric_name in metrics) {
      eval_result <- split_result$output_eval[[paste0("eval_", metric_name)]]
      if (is.null(eval_result)) next
      
      value_list <- eval_result$metrics
      
      # If metrics contains only one named entry, and that entry is itself a list, go one level deeper
      if (length(value_list) == 1 && is.list(value_list[[1]])) {
        value_list <- value_list[[1]]
      }
      
      # Now extract all named numeric values
      for (subname in names(value_list)) {
        value <- value_list[[subname]]
        if (is.numeric(value) && length(value) == 1) {
          key <- paste0(metric_name, "_", subname)
          all_values[[key]] <- value
        }
      }
    }
    
    data.frame(split = split_name, as.data.frame(as.list(all_values)))
  })
  
  result_table <- do.call(rbind, result_rows)
  return(result_table)
}
#--------------------------------------------------------------------

#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Reporting Engine: Table of Evaluation Metrics
#'
#' Extracts parameters for the specified alias and calls the engine with cleaned input.
#'
#' @param control The control object containing user configurations.
#' @param workflow_results A named list of workflow results for each split.
#' @param alias A character string identifying this specific instance of the reporting engine.
#'
#' @return A standardized reporting output list.
#' @export
wrapper_report_table_splitmetrics <- function(control, workflow_results, split_output, alias = NULL) {
  report_params <- control$params$report  # Accessing the report parameters
  if (is.null(alias)) stop("Reporting alias must be specified.")
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(report_params$params[[alias]], default_params_report_table_splitmetrics())
  
  
  # Run reporting engine
  table <- engine_report_table_splitmetrics(
    workflow_results = workflow_results,
    metrics = params$metrics
  )
  
  # Initialize standardized output
  initialize_output_report(
    report_object = table,
    report_type = "table_splitmetrics",
    input_data = names(workflow_results),
    params = params,
    specific_output = list(
      n_splits = length(workflow_results),
      alias = alias
    )
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Reporting Engine: Table of Split Metrics
#'
#' @return A list of default parameters.
#' @export
default_params_report_table_splitmetrics <- function() {
  list(
    metrics = c("summarystats")
  )
}
#--------------------------------------------------------------------