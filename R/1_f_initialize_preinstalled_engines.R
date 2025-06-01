#--------------------------------------------------------------------
### Package Attachment Hook: Initialize Global Engine Registry ###
#--------------------------------------------------------------------
#' @title Package Attachment Hook (.onAttach)
#'
#' @description
#' This function is automatically called when the fairnessToolbox package is attached
#' via `library(fairnessToolbox)`. It populates a global list named `engines` containing
#' all built-in engine wrapper functions, grouped by type (e.g., training, splitting,
#' execution, evaluation, fairness processing, reporting, publishing).
#'
#' **Purpose:**
#' - Makes all engine wrappers available in a centralized object `engines`.
#' - Enables consistent access to engine wrappers using `engines[["engine_name"]]`.
#' - Avoids runtime registration logic and external sourcing.
#'
#' **Structure of `engines`:**
#' - A named list where each entry is a wrapper function.
#' - The names follow the format `<type>_<name>`, e.g., `"train_lm"`, `"eval_mse"`, etc.
#'
#' **Example:**
#' ```r
#' engines[["execution_basic_sequential"]]
#' engines[["eval_mse"]](input_data, params)
#' ```
#'
#' @param libname The library path.
#' @param pkgname The name of the package being attached.
#'
#' @keywords internal
.onAttach <- function(libname, pkgname) {
  assign("engines", list(
    # Training
    train_lm = wrapper_train_lm,
    train_glm = wrapper_train_glm,
    
    # Split
    split_cv = wrapper_split_cv,
    split_random_stratified = wrapper_split_random_stratified,
    split_random = wrapper_split_random,
    split_userdefined = wrapper_split_userdefined,
    
    # Execution (basic)
    execution_basic_sequential = wrapper_execution_basic_sequential,
    execution_basic_slurm_array = wrapper_execution_basic_slurm_array,
    execution_basic_batchtools_local = wrapper_execution_basic_batchtools_local,
    execution_basic_batchtools_multicore = wrapper_execution_basic_batchtools_multicore,
    execution_basic_batchtools_slurm = wrapper_execution_basic_batchtools_slurm,
    
    # Execution (adaptive)
    execution_adaptive_sequential = wrapper_execution_adaptive_output_sequential,
    execution_adaptive_batchtools_multicore = wrapper_execution_adaptive_output_batchtools_multicore,
    execution_adaptive_batchtools_slurm = wrapper_execution_adaptive_output_batchtools_slurm,
    execution_adaptive_input_scalar_sequential = wrapper_execution_adaptive_input_scalar_sequential,
    
    # Fairness Pre
    fairness_pre_resampling = wrapper_fairness_pre_resampling,
    
    # Fairness In
    fairness_in_adversialdebiasing = wrapper_fairness_in_adversialdebiasing,
    
    # Fairness Post
    fairness_post_genresidual = wrapper_fairness_post_genresidual,
    
    # Evaluation
    eval_summarystats = wrapper_eval_summarystats,
    eval_mse = wrapper_eval_mse,
    eval_statisticalparity = wrapper_eval_statisticalparity,
    
    # Reportelement
    reportelement_text_msesummary = wrapper_reportelement_text_msesummary,
    reportelement_table_splitmetrics = wrapper_reportelement_table_splitmetrics,
    reportelement_boxplot_predictions = wrapper_reportelement_boxplot_predictions,
    
    # Report
    report_modelsummary = wrapper_report_modelsummary,
    
    # Publish
    publish_pdf_basis = wrapper_publish_pdf_basis,
    publish_excel_basis = wrapper_publish_excel_basis
    
  ), envir = .GlobalEnv)
}
#--------------------------------------------------------------------