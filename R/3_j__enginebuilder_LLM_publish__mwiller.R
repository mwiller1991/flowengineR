#' LLM Prompt Template for Publishing Engine
#'
#' Generates an engine-specific prompt for publishing engines.
#'
#' @param task_description Character. The user-facing description of the publishing logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_publishing <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_publish_*() - core logic
2. wrapper_publish_*() - input handling
3. default_params_publish_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \\U0001F527 ENGINE TYPE
`publishing`

### \\U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \\U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_publish_pdf_basis.R`.
It renders a structured report object to a PDF using R Markdown.

Function names follow the convention:
- `engine_publish_pdf_basis()`
- `wrapper_publish_pdf_basis()`
- `default_params_publish_pdf_basis()`

For a full explanation of publishing engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_publish.Rmd`.

---

### \\U0001F4DD STANDARDIZED INPUT (via wrapper)
All inputs must be accessed via the standardized control object structure. The engine receives inputs from the wrapper; the wrapper is called by the framework with:

- `control$params$publish$params[[alias_publish]]`: **list** of engine-specific parameters (optional)
- `object`: a structured **report** or **reportelement** object
- `file_path`: **character**; target path for the exported file (wrapper may add extension)
- `alias_publish`: **character**; unique identifier for the publishing instance

Parameter merging in the wrapper must use:
`params <- merge_with_defaults(control$params$publish$params[[alias_publish]], default_params_publish_custom())`

---

### \\U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using `initialize_output_publish()` with the following structure:

- `alias`: **character**; the publish alias
- `type`: **character**; either `\"report\"` or `\"reportelement\"`
- `engine`: **character**; publishing engine name (e.g., `\"publish_pdf_basis\"`)
- `path`: **character**; full path to the exported file
- `success`: **logical**; whether the operation succeeded
- `params`: list of parameters used by the engine (merged defaults + user)
- `specific_output`: optional list with additional metadata (e.g., render time, file size, error message)

**Important requirements:**
- Validate that the requested output format is supported by `object$compatible_formats`.
- Log success/failure and include a helpful message in `specific_output$error` on failure.

---

### \\U0001F3F7 NAMING CONVENTION
Choose a clear, specific name in place of 'custom', e.g., `pdf_basis`, `html_quarto`, etc.
Required function names inside the single file:
- `engine_publish_<method>()`
- `wrapper_publish_<method>()`
- `default_params_publish_<method>()`

---

### \\U0001F4E6 REQUIRED FILE STRUCTURE
Return a single R **file** containing exactly these three functions.
Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
