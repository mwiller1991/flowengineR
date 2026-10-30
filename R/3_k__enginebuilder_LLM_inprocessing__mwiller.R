#' LLM Prompt Template for In-Processing Engine
#'
#' Generates an engine-specific prompt for in-processing engines.
#'
#' @param task_description Character. The user-facing description of the in-processing logic.
#' @return A character string representing the LLM-ready prompt.
build_llm_template_inprocessing <- function(task_description) {
  glue::glue(
    .open = '[[', .close = ']]',
    "You are assisting in the development of an R package called 'flowengineR'.
This package allows users to create plug-and-play engines for workflows (training, evaluation, fairness, etc.).
Your task is to generate a complete R script containing three functions in a single file:
1. engine_inprocessing_*() - core logic
2. wrapper_inprocessing_*() - input handling
3. default_params_inprocessing_*() - default parameters

All code must follow these conventions:
- Written in clean R, with inline comments.
- One R file, no external files.
- Use only base R and these packages: ggplot2, dplyr, caret, magrittr, etc.
- Engine must follow the standardized input/output interface described below.

---

### \U0001F527 ENGINE TYPE
`inprocessing`

### \U0001F4C4 FUNCTIONAL DESCRIPTION
[[task_description]]

---

### \U0001F4A1 EXAMPLE FOR ORIENTATION
For reference, see the included example file `engine_inprocessing_fairness_adversialdebiasing.R`.
It retrains the base model over several epochs and adjusts the observation weights based on an adversary
that tries to predict the protected attributes from the model predictions.

Function names follow the convention:
- `engine_inprocessing_fairness_adversialdebiasing()`
- `wrapper_inprocessing_fairness_adversialdebiasing()`
- `default_params_inprocessing_fairness_adversialdebiasing()`

Use this example as structural guidance for implementing your own method.

For a full explanation of in-processing engine inputs, outputs, and structure,
consult the included vignette file `detail_engines_inprocessing.Rmd`.

---

### \U0001F4DD STANDARDIZED INPUT (via wrapper)
The wrapper has the signature `wrapper_inprocessing_<method>(control, driver_train)`.
The framework calls it after the base model has been trained:

- `driver_train`: **function**; the wrapper of the selected training engine. `driver_train(control)` trains the base model with the training configuration in `control` and returns a list whose element `model` is the fitted model
- `control$params$train$data`: **list** with the training data as `original` and `normalized` **data.frame**; select the one in use with `select_training_data(control$params$train$norm_data, control$params$train$data)`
- `control$params$train$formula`: **formula** of the base model
- `control$params$train$params`: **list** of training hyperparameters
- `control$params$inprocessing$protected_attributes`: **character vector**; names of the protected attributes
  *(auto-filled from `control$data$vars$protected_vars`)*
- `control$params$inprocessing$target_var`: **character**; name of the target variable
  *(auto-filled from `control$data$vars$target_var`)*
- `control$params$inprocessing$params`: optional **list** of engine-specific parameters

Parameter merging in the wrapper must use:
`params <- merge_with_defaults(control$params$inprocessing$params, default_params_inprocessing_custom())`

To retrain the model with modified data or observation weights, change a local copy of `control` before calling `driver_train()`:
- modified training data: `control$params$train$data$original` and `control$params$train$data$normalized`
- observation weights: `control$params$train$params$sample_weight` (numeric vector with one weight per training row; used by `train_glm` and `train_gbm`, ignored by `train_lm`)

---

### \U0001F4C8 REQUIRED OUTPUT STRUCTURE
The wrapper must return the result using the function `initialize_output_inprocessing()`, with the following structure:

- `adjusted_model`: the fitted, fairness-adjusted model; the framework calls `predict(adjusted_model, newdata = ..., type = \"response\")` (or `type = \"prob\"`) on it, so it must support `predict()` in the same way as the base model
- `model_type`: **character**; identifier of the adjusted model (e.g., `\"Adversarial Debiasing\"`)
- `predictions`: leave `NULL`; the framework computes the test-set predictions from `adjusted_model`
- `params`: list of parameters used by the engine (merged defaults + user)
- `specific_output`: optional list with additional information (e.g., training time, loss per epoch)

**Important requirements:**
- Retrain on a local copy of `control`; the control object of the workflow must not be changed.
- Training time should be measured and stored in `specific_output$training_time`.
- Not every in-processing method works with every training engine; state in a comment which training engines the method supports.

---

### \U0001F3F7 NAMING CONVENTION
Choose a clear, specific name in place of 'custom', e.g., `fairness_adversialdebiasing`, `fairness_reweighting`, etc.
Required function names inside the single file:
- `engine_inprocessing_<method>()`
- `wrapper_inprocessing_<method>(control, driver_train)`
- `default_params_inprocessing_<method>()`

---

### \U0001F4E6 REQUIRED FILE STRUCTURE
Return a single R **file** containing exactly these three functions.
Do not return code snippets or Markdown blocks. Return the full code as a plain R script file content.

---

Once done, return the complete script content only - as a single R file."
  )
}
