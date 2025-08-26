#' LLM Prompt Template for Training Engine
#'
#' Generates an engine-specific prompt for training engines.
#'
#' @param task_description Character. The user-facing description of the training logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_train <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_train_*() - core logic
2. wrapper_train_*() - input handling
3. default_params_train_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \U0001F527 ENGINE TYPE
`train`

### \U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_train_glm.R`.  
It implements a training engine for Generalized Linear Models using `stats::glm()`.

Function names follow the convention:
- `engine_train_glm()`
- `wrapper_train_glm()`
- `default_params_train_glm()`

For a full explanation of training engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_train.Rmd`.

---

### \U0001F4DD STANDARDIZED INPUT (via wrapper)
The engine is called by the wrapper; the wrapper receives a standardized `control` object from the framework:

- `control$params$train$formula`: **formula** specifying the model structure (e.g., `target ~ .`)
- `control$params$train$data`: **list** containing training data:
  - `original`: full untransformed training data
  - `normalized`: normalized training data (if available)
- `control$params$train$norm_data`: **logical**; whether to use normalized data
- `control$params$train$params`: optional **list** with engine-specific hyperparameters, such as:
  - `family`: GLM family function (`gaussian()`, `binomial()`, `poisson()`, …)
  - `sample_weight`: numeric vector of observation weights

Parameter merging in the wrapper must use:
`hyperparameters <- merge_with_defaults(control$params$train$params, default_params_train_custom())`

---

### \U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using `initialize_output_train()` with the following structure:

- `model`: fitted model object returned by the engine
- `model_type`: short string identifying the model (e.g., \"glm\", \"rf\")
- `formula`: training formula used
- `hyperparameters`: list of parameters used by the engine (merged defaults + user)
- `specific_output`: optional list with additional information (e.g., training time, feature importance)

**Important requirements:**
- Engines must respect `sample_weight` if applicable.
- Normalized vs. original data selection is handled via the wrapper.
- Training time should be measured and stored in `specific_output$training_time`.

---

### \U0001F3F7 NAMING CONVENTION
Choose a clear, specific name in place of 'custom', e.g., `glm`, `rf`, `gbm`.  
Required function names inside the single file:
- `engine_train_<method>()`
- `wrapper_train_<method>()`
- `default_params_train_<method>()`

---

### \U0001F4E6 REQUIRED FILE STRUCTURE
Return a single R **file** containing exactly these three functions.
Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
