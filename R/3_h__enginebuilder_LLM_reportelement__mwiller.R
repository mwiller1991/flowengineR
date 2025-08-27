#' LLM Prompt Template for Reportelement Engine
#'
#' Generates an engine-specific prompt for reportelement engines.
#'
#' @param task_description Character. The user-facing description of the reportelement to generate.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_reportelement <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_reportelement_*() - core logic
2. wrapper_reportelement_*() - input handling
3. default_params_reportelement_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \\U0001F527 ENGINE TYPE
`reportelement`

### \\U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \\U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_reportelement_table_splitmetrics.R`.
It aggregates selected evaluation metrics per split into a data.frame.

Function names follow the convention:
- `engine_reportelement_table_splitmetrics()`
- `wrapper_reportelement_table_splitmetrics()`
- `default_params_reportelement_table_splitmetrics()`

For a full explanation of reportelement engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_reportelement.Rmd`.

---

### \\U0001F4DD STANDARDIZED INPUT (via wrapper)
All inputs must be accessed via the standardized control object structure. The engine receives inputs from the wrapper; the wrapper is called by the framework with:

- `control$params$reportelement$params[[alias]]`: **list** of engine-specific parameters for this element
- `workflow_results`: **named list** of workflow results per split (provided by the workflow)
- `split_output`: splitter output (may be unused depending on the element)
- `alias`: **character**; unique identifier for the reportelement instance

Parameter merging in the wrapper must use:
`params <- merge_with_defaults(control$params$reportelement$params[[alias]], default_params_reportelement_custom())`

---

### \\U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using `initialize_output_reportelement()` with the following structure:

- `type`: **character**; content type such as `\"table\"`, `\"plot\"`, or `\"text\"`
- `content`: the generated object (e.g., `data.frame`, `ggplot`, `character`)
- `compatible_formats`: **character vector** of export formats (e.g., `c(\"pdf\",\"html\",\"xlsx\",\"json\")`)
- `input_data`: optional raw inputs used (e.g., names of processed splits or aggregated results)
- `params`: list of parameters used by the engine (merged defaults + user)
- `specific_output`: optional list for diagnostics/metadata (e.g., `n_splits`, `alias`)

**Important requirements:**
- The engine must not assume a specific evaluation layout; use defensive checks when reading metrics from `workflow_results`.
- Keep heavy transformations inside the engine and return lightweight summaries for reporting.

---

### \\U0001F3F7 NAMING CONVENTION
Choose a clear, specific name in place of 'custom', e.g., `table_splitmetrics`, `plot_fairness_distribution`, etc.
Required function names inside the single file:
- `engine_reportelement_<method>()`
- `wrapper_reportelement_<method>()`
- `default_params_reportelement_<method>()`

---

### \\U0001F4E6 REQUIRED FILE STRUCTURE
Return a single R **file** containing exactly these three functions.
Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
