#' Build LLM Prompt for Engine Creation
#'
#' Generates a ready-to-copy prompt for an LLM (e.g., ChatGPT) to generate a complete R engine implementation.
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
#' @param engine_type Character. The type of engine (e.g., "eval", "training", "fairness_pre", etc.)
#' @param task_description Character. A plain language description of what the engine should do.
#'
#' @return A character string to copy-paste into an LLM like ChatGPT.
#' @export
#'
#' @examples
#' cat(build_engine_with_llm("eval", "Calculate the mean absolute error between predictions and actuals"))
build_engine_with_llm <- function(engine_type, task_description) {
  engine_type <- tolower(engine_type)
  
  if (engine_type == "eval") {
    return(build_llm_template_eval(task_description))
  } else {
    stop(paste0("[build_engine_with_llm] Unsupported engine type: ", engine_type))
  }
}


#' Build LLM Prompt Package for Engine Creation
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
#'
#' @examples
#' build_engine_with_llm_zip("evaluation", "Calculate the median of predictions")
build_engine_with_llm_zip <- function(engine_type = "eval",
                                      task_description = "The Median of all predictions.",
                                      zip_path = NULL) {
  
  engine_type <- tolower(engine_type)
  prompt_text <- build_engine_with_llm(engine_type, task_description)
  
  # resolve files from installed package
  default_example <- switch(engine_type,
                            eval = system.file("example_enginebuild_LLM", "engine_eval_mse.R", package = "flowengineR"),
                            stop("No default example defined for engine type: ", engine_type)
  )
  
  default_vignette <- switch(engine_type,
                             eval = system.file("example_enginebuild_LLM", "detail_engines_evaluation.Rmd", package = "flowengineR"),
                             stop("No default vignette defined for engine type: ", engine_type)
  )
  
  if (default_example == "") stop("Example file not found in installed package.")
  if (default_vignette == "") stop("Vignette file not found in installed package.")
  
  tmp_dir <- file.path(tempdir(), paste0("llm_package_", engine_type, "_", format(Sys.time(), "%Y%m%d%H%M%S")))
  dir.create(tmp_dir, recursive = TRUE, showWarnings = FALSE)
  
  # 1. Write prompt
  prompt_file <- file.path(tmp_dir, paste0("llm_prompt_", engine_type, ".R"))
  writeLines(prompt_text, prompt_file)
  
  # 2. Add example file
  file.copy(default_example, file.path(tmp_dir, basename(default_example)), overwrite = TRUE)
  
  # 3. Add vignette file as-is (.Rmd)
  file.copy(default_vignette, file.path(tmp_dir, basename(default_vignette)), overwrite = TRUE)
  
  # 4. Zip everything
  if (is.null(zip_path)) {
    zip_path <- file.path(tempdir(), paste0("llm_package_", engine_type, ".zip"))
  }
  old_wd <- setwd(tmp_dir)
  on.exit(setwd(old_wd), add = TRUE)
  utils::zip(zipfile = zip_path, files = list.files(tmp_dir))
  
  message("LLM zip package created at: ", zip_path)
  invisible(zip_path)
}