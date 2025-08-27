#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Reportelement Engine: Table of Evaluation Metrics per Split
#'
#' Aggregates selected evaluation metrics from each split and compiles them into a data.frame.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `workflow_results`: Named list of workflow results per split.
#' - `metrics`: Character vector of metric identifiers to extract (e.g., `"mse"`, `"summarystats"`).
#'
#' **Output (returned to wrapper):**
#' - A data.frame with one row per split and one column per extracted metric.
#'
#' @seealso [wrapper_reportelement_table_splitmetrics()]
#'
#' @param workflow_results A named list of workflow results (from multiple splits).
#' @param metrics A character vector of metric names to extract.
#'
#' @return A data.frame summarizing the selected metrics per split.
#' @keywords internal
engine_reportelement_table_splitmetrics <- function(workflow_results, metrics) {
  result_rows <- lapply(names(workflow_results), function(split_name) {
    split_result <- workflow_results[[split_name]]
    
    all_values <- list()
    
    for (metric_name in metrics) {
      eval_result <- split_result$output_eval[[paste0("eval_", metric_name)]]
      if (is.null(eval_result)) next
      
      value_list <- eval_result$metrics
      
      if (length(value_list) == 1 && is.list(value_list[[1]])) {
        value_list <- value_list[[1]]
      }
      
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
#' Wrapper for Reportelement Engine: Table of Evaluation Metrics per Split
#'
#' Validates and prepares standardized inputs, merges default and user-defined parameters,
#' and invokes the table engine. Wraps the result using `initialize_output_reportelement()`.
#'
#' **Standardized Inputs:**
#' - `control$params$reportelement$params[[alias]]`: Named list of engine-specific parameters.
#' - `workflow_results`: Named list of workflow results per split (provided by the workflow).
#' - `split_output`: Output of the splitter engine (not used by this engine).
#' - `alias`: Character string identifying the reportelement instance.
#'
#' **Engine-Specific Parameters (`control$params$reportelement$params[[alias]]`):**
#' - `metrics` *(character vector)*: Metric types to include in the table.  
#'   Supported: `"mse"`, `"summarystats"`, `"spd"`, etc.
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$reportelement <- list("split_table" = "reportelement_table_splitmetrics")
#' control$params$reportelement <- controller_reportelement(
#'   params = list("split_table" = list(
#'     metrics = c("mse", "summarystats")
#'   ))
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/8_b_template_reportelement_table_splitmetrics.R`
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_reportelement()`:
#'   - `type`: `"table"`
#'   - `content`: data.frame with one row per split and one column per selected metric
#'   - `compatible_formats`: `c("pdf", "html", "xlsx", "json")`
#'   - `input_data`: Names of processed splits
#'   - `params`: Merged parameter list
#'   - `specific_output`: Metadata including `n_splits` and `alias`
#'
#' @seealso 
#'   [engine_reportelement_table_splitmetrics()],  
#'   [default_params_reportelement_table_splitmetrics()],  
#'   [initialize_output_reportelement()],  
#'   [controller_reportelement()],  
#'   Template: `inst/templates_control/8_b_template_reportelement_table_splitmetrics.R`
#'
#' @param control A standardized control object (see `controller_reportelement()`).
#' @param workflow_results Named list of workflow results.
#' @param split_output Output from the splitter engine (not used here).
#' @param alias Unique identifier for this reportelement instance.
#'
#' @return A standardized reportelement output object.
#' @keywords internal
wrapper_reportelement_table_splitmetrics <- function(control, workflow_results, split_output, alias = NULL) {
  report_params <- control$params$reportelement  # Access reportelement params
  if (is.null(alias)) stop("Reportelement alias must be specified.")
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(report_params$params[[alias]], default_params_reportelement_table_splitmetrics())
  
  # Run reportelement engine
  table <- engine_reportelement_table_splitmetrics(
    workflow_results = workflow_results,
    metrics = params$metrics
  )
  
  log_msg(sprintf("[REPORTELEMENT] Table generated with %d rows and %d columns.", nrow(table), ncol(table)), level = "info", control = control)
  
  # Initialize standardized output
  initialize_output_reportelement(
    type = "table",
    content = table,
    compatible_formats = c("pdf", "html", "xlsx", "json"),
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
#' Default Parameters for Reportelement Engine: Table of Split Metrics
#'
#' Provides default parameters for the `reportelement_table_splitmetrics` engine.
#' These parameters determine which evaluation metrics are included in the summary table.
#'
#' **Purpose:**
#' - Specifies which metrics to extract and display per split.
#' - Allows modular extension by adding other registered metric types.
#'
#' **Default Parameters:**
#' - `metrics`: A character vector of metric types to include in the table.
#'     - `"summarystats"` (default): summary statistics like mean, sd, min, etc.
#'     - Additional types may include `"mse"`, `"fairness"`, etc., depending on availability.
#'
#' @seealso [wrapper_reportelement_table_splitmetrics()]
#'
#' @return A named list of default parameters for the split metrics reportelement engine.
#' @keywords internal
default_params_reportelement_table_splitmetrics <- function() {
  list(
    metrics = c("summarystats")
  )
}
#--------------------------------------------------------------------