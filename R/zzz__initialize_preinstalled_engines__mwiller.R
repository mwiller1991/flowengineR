#--------------------------------------------------------------------
### Internal Environment and Engine Registration at Package Load ###
#--------------------------------------------------------------------

#' @title Internal Environment for flowengineR
#'
#' @description
#' `flowengineR_env` is a dedicated internal environment used to store
#' runtime objects such as engine wrappers. It is not exported and
#' should only be accessed internally within the package unless explicitly exposed.
#'
#' This environment is initialized at package load time and populated
#' via the `.onLoad()` hook using the `register_default_engines()` function.
#'
#' **Purpose:**
#' - Encapsulates engine wrapper definitions to avoid polluting the global environment.
#' - Enables fast and consistent internal access to all pre-registered engine wrappers.
#'
#' **Access pattern:**
#' - Internal functions may use `flowengineR_env$engines` to retrieve engine wrappers.
#'
#' @keywords internal
flowengineR_env <- new.env(parent = emptyenv())

#--------------------------------------------------------------------

#' @title Register Default Engine Wrappers
#'
#' @description
#' This function populates the internal environment `flowengineR_env` with all built-in
#' engine wrappers used by the flowengineR framework. It is intended for internal use
#' and automatically called when the package is loaded.
#'
#' **Purpose:**
#' - Ensures that all engine wrappers are available in a single, accessible object.
#' - Supports dynamic workflows using engine names (e.g., `"train_lm"`, `"eval_mse"`, etc.).
#' - Avoids runtime redefinition or reliance on the global environment.
#'
#' **Structure of `flowengineR_env$engines`:**
#' - A named list where each element is a wrapper function.
#' - Names follow the format `<type>_<name>`, e.g., `"train_lm"`, `"execution_basic_sequential"`.
#'
#' **Example (internal use only):**
#' ```r
#' flowengineR_env$engines[["train_rf"]]
#' flowengineR_env$engines[["eval_mse"]](input_data, params)
#' ```
#'
#' @keywords internal
register_default_engines <- function() {
  flowengineR_env$engines <- list(
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
    execution_adaptive_output_sequential = wrapper_execution_adaptive_output_sequential,
    execution_adaptive_output_batchtools_multicore = wrapper_execution_adaptive_output_batchtools_multicore,
    execution_adaptive_output_batchtools_slurm = wrapper_execution_adaptive_output_batchtools_slurm,
    execution_adaptive_input_scalar_sequential = wrapper_execution_adaptive_input_scalar_sequential,
    
    # Preprocessing
    preprocessing_fairness_resampling = wrapper_preprocessing_fairness_resampling,
    
    # Training
    train_lm = wrapper_train_lm,
    train_glm = wrapper_train_glm,
    train_rf = wrapper_train_rf,
    
    # Inprocessing
    inprocessing_fairness_adversialdebiasing = wrapper_inprocessing_fairness_adversialdebiasing,
    
    # Postprocessing
    postprocessing_fairness_genresidual = wrapper_postprocessing_fairness_genresidual,
    
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
  )
}

#--------------------------------------------------------------------

#' @title Package Load Hook (.onLoad)
#'
#' @description
#' This function is automatically called when the `flowengineR` package is loaded (not just attached).
#' It initializes the internal environment and registers all built-in engine wrappers.
#'
#' **Note:** This function runs silently and does not interact with the user.
#'
#' @param libname The library path.
#' @param pkgname The name of the package being loaded.
#'
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  register_default_engines()
}