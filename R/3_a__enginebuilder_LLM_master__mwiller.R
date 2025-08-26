#' Build LLM Prompt Package for Engine Creation
#'
#' This master function dispatches to engine-type-specific helpers that return an LLM prompt template.
#'
#' Supported engine types:
#' - "split"
#' - "execution"
#' - "train"
#' - "preprocessing"
#' - "inprocessing"
#' - "postprocessing"
#' - "eval"
#' - "reportelement"
#' - "report"
#' - "publishing"
#'
#' Creates a zip file containing:
#' - A structured prompt text for the LLM
#' - A reference example R file for this engine type
#' - A vignette (.Rmd) as reference
#'
#' @param engine_type Character. The engine type (e.g., "evaluation").
#' @param task_description Character. The plain-language goal the engine should achieve.
#' @param zip_path Optional output path for the final zip file.
#'
#' @return Path to the created zip file.
#' @export
build_engine_with_llm_zip <- function(engine_type,
                                      task_description,
                                      zip_path = NULL) {
  
  engine_type <- tolower(engine_type)
  
  # --- Engine registry -------------------------------------------------------
  # Central place to define example and vignette references per engine type.
  engine_registry <- list(
    split = list(
      example   = c("example_enginebuild_LLM", "engine_split_random.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_split.Rmd")
    ),
    execution = list(
      example   = c("example_enginebuild_LLM", "engine_execution_basic_sequential.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_execution.Rmd")
    ),
    train = list(
      example   = c("example_enginebuild_LLM", "engine_train_glm.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_train.Rmd")
    ),
    preprocessing = list(
      example   = c("example_enginebuild_LLM", "engine_preprocessing_fairness_resampling.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_preprocessing.Rmd")
    ),
    inprocessing = list(
      example   = c("example_enginebuild_LLM", "engine_inprocessing_adversarial.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_inprocessing.Rmd")
    ),
    postprocessing = list(
      example   = c("example_enginebuild_LLM", "engine_postprocessing_residual.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_postprocessing.Rmd")
    ),
    eval = list(
      example   = c("example_enginebuild_LLM", "engine_eval_mse.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_evaluation.Rmd")
    ),
    reportelement = list(
      example   = c("example_enginebuild_LLM", "engine_report_table_splitmetrics.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_reportelement.Rmd")
    ),
    report = list(
      example   = c("example_enginebuild_LLM", "engine_report_boxplot_predictions.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_report.Rmd")
    ),
    publishing = list(
      example   = c("example_enginebuild_LLM", "engine_publishing_quarto.R"),
      vignette  = c("example_enginebuild_LLM", "detail_engines_publishing.Rmd")
    )
  )
  
  if (!engine_type %in% names(engine_registry)) {
    stop("Unsupported engine type after normalization: ", engine_type,
         "\nSupported: ", paste(names(engine_registry), collapse = ", "))
  }
  
  # --- Resolve LLM prompt builder -------------------------------------------
  builder_name <- paste0("build_llm_template_", engine_type)
  if (!exists(builder_name, mode = "function")) {
    stop("No prompt template builder found for engine type '", engine_type, "'. ",
         "Please implement ", builder_name, "(task_description).")
  }
  prompt_text <- do.call(builder_name, list(task_description))
  
  # --- Resolve packaged example + vignette -----------------------------------
  reg <- engine_registry[[engine_type]]
  
  # Helper to safely resolve files from the installed package
  resolve_pkg_file <- function(path_vec) {
    # path_vec is c(subdir, filename) relative to inst/ in the installed package
    p <- system.file(path_vec[1], path_vec[2], package = "flowengineR")
    if (length(p) == 0 || p == "") {
      stop("Packaged file not found: inst/", file.path(path_vec[1], path_vec[2]),
           " (engine type: ", engine_type, ")")
    }
    p
  }
  
  default_example   <- resolve_pkg_file(reg$example)
  default_vignette  <- resolve_pkg_file(reg$vignette)
  
  # --- Build temp structure ---------------------------------------------------
  tmp_dir <- file.path(
    tempdir(),
    paste0("llm_package_", engine_type, "_", format(Sys.time(), "%Y%m%d%H%M%S"))
  )
  dir.create(tmp_dir, recursive = TRUE, showWarnings = FALSE)
  
  # 1) Write prompt as plain .R (so users can open/read directly)
  prompt_file <- file.path(tmp_dir, paste0("llm_prompt_", engine_type, ".R"))
  writeLines(prompt_text, prompt_file)
  
  # 2) Copy example R
  file.copy(default_example, file.path(tmp_dir, basename(default_example)), overwrite = TRUE)
  
  # 3) Copy vignette Rmd
  file.copy(default_vignette, file.path(tmp_dir, basename(default_vignette)), overwrite = TRUE)
  
  # 4) Zip all
  if (is.null(zip_path)) {
    zip_path <- file.path(tempdir(), paste0("llm_package_", engine_type, ".zip"))
  }
  old_wd <- setwd(tmp_dir)
  on.exit(setwd(old_wd), add = TRUE)
  utils::zip(zipfile = zip_path, files = list.files(tmp_dir))
  
  message("LLM zip package created at: ", zip_path)
  message("\nTo use this ZIP with an LLM (e.g., ChatGPT), follow these instructions:")
  message("\n1. Upload the ZIP file in your chat.")
  message("2. Paste the following instruction afterwards:")
  message("\n--- COPY INTO CHAT ---")
  message("I have uploaded a ZIP containing a prompt, a working example engine, and a vignette.")
  message("Please read the prompt first (llm_prompt_", engine_type, ".R). Then carefully review:")
  message("- ", basename(default_example), " as a concrete reference implementation")
  message("- ", basename(default_vignette), " as documentation of required structure")
  message("Be precise and complete.")
  message("Then generate a new engine as specified in the prompt.")
  message("---")
  
  invisible(zip_path)
}