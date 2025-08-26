#' LLM Prompt Template for Preprocessing Engine
#'
#' Generates an engine-specific prompt for preprocessing engines.
#'
#' @param task_description Character. The user-facing description of the preprocessing logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_preprocessing <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_preprocessing_*() - core logic
2. wrapper_preprocessing_*() - input handling
3. default_params_preprocessing_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \U0001F527 ENGINE TYPE
`preprocessing`

### \U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_preprocessing_fairness_resampling.R`. It balances class distribution via over-/undersampling.

Function names follow the convention:
- `engine_preprocessing_fairness_resampling()`
- `wrapper_preprocessing_fairness_resampling()`
- `default_params_preprocessing_fairness_resampling()`

For a full explanation of preprocessing engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_preprocessing.Rmd`.

---

### \U0001F4DD STANDARDIZED INPUT (via wrapper)
All inputs must be accessed via the standardized control object structure. The engine receives inputs from the wrapper; the wrapper is called by the framework with a `control` object:

- `control$params$preprocessing$data`: **data.frame**; input data to transform (typically `control$data$train`)
- `control$params$preprocessing$target_var`: **character**; name of the target variable  
  *(auto-filled from `control$data$vars$target_var`; present for consistency)*
- `control$params$preprocessing$protected_attributes`: optional; passed through for consistency
- `control$params$preprocessing$params`: **list** of engine-specific parameters, e.g.  
  - `method` (**character**): one of `\"oversampling\"`, `\"undersampling\"`
  - `target_ratio` (**numeric**, default = 1): reserved/optional

Parameter merging in the wrapper must use:
`params <- merge_with_defaults(control$params$preprocessing$params, default_params_preprocessing_custom())`

---

### \U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using the function `initialize_output_preprocessing()`, with the following structure:

- `preprocessed_data`: **data.frame** with transformed dataset
- `method`: **character**; name of the preprocessing method (e.g., `\"resampling\"`)
- `params`: list of parameters used by the engine (merged defaults + user)
- `specific_output`: optional list for engine-specific diagnostics (e.g., original/new class counts)

**Important requirements:**
- The engine must operate on the provided `data` and respect `target_var` semantics when required by the method.
- Do not mutate the `control` object in-place; return transformed data via the standardized output.
- Keep any additional artifacts (e.g., transformation maps) in `specific_output`.

---

### \U0001F3F7 NAMING CONVENTION
Choose a clear, specific name in place of 'custom', e.g., `fairness_resampling`, `scaler_standardize`, etc.
Required function names inside the single file:
- `engine_preprocessing_<method>()`
- `wrapper_preprocessing_<method>()`
- `default_params_preprocessing_<method>()`

---

### \U0001F4E6 REQUIRED FILE STRUCTURE
Return a single R **file** containing exactly these three functions.
Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
