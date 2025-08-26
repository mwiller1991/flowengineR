#' LLM Prompt Template for Split Engine
#'
#' Generates an engine-specific prompt for split engines.
#'
#' @param task_description Character. The user-facing description of the split logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_split <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
"You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_split_*() - core logic
2. wrapper_split_*() - input handling
3. default_params_split_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \\U0001F527 ENGINE TYPE
`split`

### \\U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \\U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_split_random.R`. It implements a simple random holdout split.
The core logic there is to randomly assign rows to training and test sets based on a given proportion.

Function names follow the convention:
- `engine_split_random()`
- `wrapper_split_random()`
- `default_params_split_random()`

Use this example as structural guidance for implementing your own method.

For a full explanation of split engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_split.Rmd`.

---

### \\U0001F4DD STANDARDIZED INPUT (via wrapper)
All inputs must be accessed via the standardized control object structure. The engine receives inputs from the wrapper; the wrapper is called by the framework with a `control` object:

- `control$data$full`: **data.frame**; full dataset to be split (**required**)
- `control$params$split$seed`: **integer**; random seed for reproducibility (**required**)
- `control$params$split$target_var`: **character**; target variable  (**required**)
- `control$params$split$params`: **list** of engine-specific parameters (optional), here:
  - `split_ratio` (**numeric**, default = 0.7): proportion of the dataset to use for **training**; must be in (0, 1)

The wrapper must merge user parameters with defaults via:
`params <- merge_with_defaults(control$params$split$params, default_params_split_custom())`

---

### \\U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using the function `initialize_output_split()`, with the following structure:

- `split_type`: character string describing the split method, e.g., \"random\"
- `splits`: a **named list** of split definitions; for this engine:
  - one element named `random`, containing a list with:
    - `train`: **data.frame** with the training subset
    - `test` : **data.frame** with the test subset
- `seed`: integer; the random seed used
- `params`: list of parameters used by the engine (merged defaults + user)
- `specific_output`: `NULL` or optional list with additional metadata (none required here)

---

### \\U0001F3F7 NAMING CONVENTION
The engine name (used in the function names) should reflect the method being implemented.
Use a clear and specific name in place of 'custom', such as 'random'.

---

### \\U0001F4E6 REQUIRED FILE STRUCTURE
The final output must be a single R **file** containing exactly these three functions:
- `engine_split_<method>()`
- `wrapper_split_<method>()`
- `default_params_split_<method>()`

Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
