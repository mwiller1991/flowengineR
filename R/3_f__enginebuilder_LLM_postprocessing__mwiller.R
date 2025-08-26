#' LLM Prompt Template for Post-Processing Engine
#'
#' Generates an engine-specific prompt for post-processing engines.
#'
#' @param task_description Character. The user-facing description of the post-processing logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_postprocessing <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_postprocessing_*() - core logic
2. wrapper_postprocessing_*() - input handling
3. default_params_postprocessing_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \\U0001F527 ENGINE TYPE
`postprocessing`

### \\U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \\U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_postprocessing_fairness_genresidual.R`.
It adjusts predictions by applying the mean residual between actuals and predictions.

Function names follow the convention:
- `engine_postprocessing_fairness_genresidual()`
- `wrapper_postprocessing_fairness_genresidual()`
- `default_params_postprocessing_fairness_genresidual()`

For a full explanation of post-processing engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_postprocessing.Rmd`.

---

### \\U0001F4DD STANDARDIZED INPUT (via wrapper)
All inputs must be accessed via the standardized control object structure. The engine receives inputs from the wrapper; the wrapper is called by the framework with a `control` object:

- `control$params$postprocessing$postprocessing_data$predictions`: **numeric vector**; model predictions (injected by workflow)
- `control$params$postprocessing$postprocessing_data$actuals`: **numeric vector**; true observed values (injected by workflow)
- `control$params$postprocessing$protected_name`: **character vector**; names of protected attributes (binary)  
  *(auto-filled from `control$data$vars$protected_vars_binary`)*
- `control$params$postprocessing$params`: optional **list** of engine-specific parameters (none required for this example)

Parameter merging in the wrapper must use:
`params <- merge_with_defaults(control$params$postprocessing$params, default_params_postprocessing_custom())`

---

### \\U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using `initialize_output_postprocessing()` with the following structure:

- `adjusted_predictions`: **numeric vector** of adjusted predictions
- `method`: **character**; identifier of the post-processing method (e.g., `\"general_residual\"`)
- `input_data`: **data.frame/list** containing inputs used for adjustment (typically `predictions`, `actuals`)
- `protected_attributes`: **character vector** of protected attribute names used
- `params`: list of parameters used by the engine (merged defaults + user)
- `specific_output`: optional list with diagnostics/metadata (e.g., residual statistics)

---

### \\U0001F3F7 NAMING CONVENTION
Choose a clear, specific name in place of 'custom', e.g., `fairness_genresidual`, `calibration_platt`, etc.
Required function names inside the single file:
- `engine_postprocessing_<method>()`
- `wrapper_postprocessing_<method>()`
- `default_params_postprocessing_<method>()`

---

### \\U0001F4E6 REQUIRED FILE STRUCTURE
Return a single R **file** containing exactly these three functions.
Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
