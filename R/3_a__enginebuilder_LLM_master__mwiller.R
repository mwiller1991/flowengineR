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
  
  # Inline switch-based prompt builder
  prompt_text <- switch(engine_type,
                        eval = build_llm_template_eval(task_description),
                        stop("No prompt template defined for engine type: ", engine_type)
  )
  
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
  message("\nTo use this ZIP with an LLM (e.g., ChatGPT), follow these instructions:")
  message("\n1. Upload the ZIP file in your chat.")
  message("2. Paste the following instruction afterwards:")
  message("\n--- COPY INTO CHAT ---")
  message("I have uploaded a ZIP containing a prompt, a working example engine, and a vignette.")
  message("Please read the prompt first (llm_prompt_", engine_type, ".R). Then carefully review:")
  message("- engine_", engine_type, "_mse.R as a concrete reference implementation")
  message("- detail_engines_", engine_type, ".Rmd as documentation of required structure")
  message("Be precise and complete.")
  message("Then generate a new engine as specified in the prompt.")
  message("---")
  
  invisible(zip_path)
}