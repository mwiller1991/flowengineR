#' LLM Prompt Template for Report Engine
#'
#' Generates an engine-specific prompt for report engines.
#'
#' @param task_description Character. The user-facing description of the report logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_report <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_report_*() - core logic
2. wrapper_report_*() - input handling
3. default_params_report_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \\U0001F527 ENGINE TYPE
`report`

### \\U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \\U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_report_modelsummary.R`.
It combines selected reportelements into a structured multi-section model summary.

Function names follow the convention:
- `engine_report_modelsummary()`
- `wrapper_report_modelsummary()`
- `default_params_report_modelsummary()`

For a full explanation of report engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_report.Rmd`.

---

### \\U0001F4DD STANDARDIZED INPUT (via wrapper)
All inputs must be accessed via the standardized control object structure. The engine receives inputs from the wrapper; the wrapper is called by the framework with:

- `control$params$report$params[[alias_report]]`: **list** mapping reportelement aliases to sections
- `reportelements`: **named list** of reportelement outputs available in the workflow
- `alias_report`: **character**; unique identifier for the report instance

Parameter merging in the wrapper must use:
`params <- merge_with_defaults(control$params$report$params[[alias_report]], default_params_report_custom())`

---

### \\U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using `initialize_output_report()` with the following structure:

- `report_title`: **character**; display title of the report
- `report_type`: **character**; identifier such as `\"modelsummary\"`, `\"diagnostics\"`
- `compatible_formats`: **character vector** of supported export formats (e.g., `c(\"pdf\",\"html\",\"json\")`)
- `sections`: **list**; each section is a list with:
  - `heading`: section heading (character)
  - `content`: list of reportelements assigned to that section
- `params`: parameter list used by the engine
- `specific_output`: optional list with additional metadata (e.g., number of sections, rendering diagnostics)

**Important requirements:**
- The wrapper must pass through all reportelements referenced in `params`.
- Each section must contain both a `heading` and a `content` list.
- Engines should log section count and report alias for traceability.

---

### \\U0001F3F7 NAMING CONVENTION
Choose a clear, specific name in place of 'custom', e.g., `modelsummary`, `diagnostics`, etc.
Required function names inside the single file:
- `engine_report_<method>()`
- `wrapper_report_<method>()`
- `default_params_report_<method>()`

---

### \\U0001F4E6 REQUIRED FILE STRUCTURE
Return a single R **file** containing exactly these three functions.
Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
