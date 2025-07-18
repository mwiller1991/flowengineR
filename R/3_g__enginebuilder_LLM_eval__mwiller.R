#' LLM Prompt Template for Evaluation Engine
#'
#' Generates an engine-specific prompt for evaluation engines.
#'
#' @param task_description Character. The user-facing description of the evaluation logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_eval <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_eval_*() - core logic
2. wrapper_eval_*() - input handling
3. default_params_eval_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \U0001F527 ENGINE TYPE
`eval`

### \U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_eval_mse.R`. It implements a simple Mean Squared Error (MSE) engine.
The core logic there is:

```r
mean((predictions - actuals)^2)
```

This engine returns:
```r
metrics = list(mse = ...)
```

Function names follow the convention:
- `engine_eval_mse()`
- `wrapper_eval_mse()`
- `default_params_eval_mse()`

Use this example as structural guidance for implementing your own method.

For a full explanation of evaluation engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_evaluation.Rmd`.

---

### \U0001F4DD STANDARDIZED INPUT (via wrapper)
All inputs must be accessed via the standardized control object structure. See the example engine for how predictions and actuals are passed via control.
The engine will receive inputs from the wrapper function, which are passed automatically by the framework through the control-object:

- `eval_data`: a `data.frame` with at least the columns:
  - `prediction`: numeric vector of predicted values
  - `actual`: numeric vector of actual (true) values
- `params`: a named list of engine-specific parameters (may be empty)
- `protected_attributes`: optional `data.frame` with additional columns (not required for this engine)

---

### \U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using the function `initialize_output_eval()`, with the following structure:

- `metrics`: named list with one or more numeric entries (e.g., `list(mse = ..., mae = ...)`)
- `eval_type`: character string describing the evaluation (e.g., 'custom_eval')
- `input_data`: the original `eval_data` data.frame
- `protected_attributes`: passed through unchanged
- `params`: list of parameters used by the engine (merged default + user)
- `specific_output`: NULL or optional list with additional elements

Parameters must be handled using the following helper function call:
`params <- merge_with_defaults(specific_params, default_params_eval_custom())`

---

### \U0001F3F7 NAMING CONVENTION
The engine name (used in the function names) should reflect the method being implemented.
Use a clear and specific name in place of 'custom', such as 'mse', 'mae', or 'medianerror'.

---

### \U0001F4E6 REQUIRED FILE STRUCTURE
The final output must be a single R **file** containing exactly these three functions:
- `engine_eval_<method>()`
- `wrapper_eval_<method>()`
- `default_params_eval_<method>()`

Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}