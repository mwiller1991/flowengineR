#' LLM Prompt Template for Execution Engine
#'
#' Generates an engine-specific prompt for execution engines.
#'
#' @param task_description Character. The user-facing description of the execution logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_execution <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_execution_*() - core logic
2. wrapper_execution_*() - input handling
3. default_params_execution_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \U0001F527 ENGINE TYPE
`execution`

### \U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_execution_basic_sequential.R`.
It executes `run_workflow_singlesplitloop()` **once per split** in a simple sequential loop.

Function names follow the convention:
- `engine_execution_basic_sequential()`
- `wrapper_execution_basic_sequential()`
- `default_params_execution_basic_sequential()`

For a full explanation of execution engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_execution.Rmd`.

---

### \U0001F4DD STANDARDIZED INPUT (via wrapper)
The engine is called by the wrapper; the wrapper receives a standardized `control` object from the framework:

- `control`: full control object containing configuration and data
- `split_output`: result from the splitter engine with a **named list** of splits at `split_output$splits`
- `control$params$execution$params`: optional **list** with engine-specific parameters (this basic engine does not require any)

Parameter merging in the wrapper must use:
`params <- merge_with_defaults(control$params$execution$params, default_params_execution_custom())`

---

### \U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using `initialize_output_execution()` with the following structure:

- `execution_type`: character label of the engine (e.g., \"basic_sequential\")
- `workflow_results`: **named list** of results from `run_workflow_singlesplitloop()`;  
  the **names must exactly match** the identifiers in `split_output$splits`
- `params`: list of parameters used by the engine (merged defaults + user)
- `specific_output`: optional list with additional metadata (e.g., `n_splits`)
- `continue_workflow`: logical; `TRUE` if the main workflow should proceed automatically

**Important requirement:**
The names of `workflow_results` **must exactly match** the split identifiers in `split_output$splits` to allow correct mapping in `resume_workflow()`.

---

### \U0001F3F7 NAMING CONVENTION
Choose a clear, specific name in place of 'custom', such as 'basic_sequential', 'batchtools', or 'slurm_array'.
Required function names inside the single file:
- `engine_execution_<method>()`
- `wrapper_execution_<method>()`
- `default_params_execution_<method>()`

---

### \U0001F4E6 REQUIRED FILE STRUCTURE
Return a single R **file** containing exactly these three functions.
Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
