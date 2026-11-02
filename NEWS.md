# flowengineR 1.1.0

First release on CRAN.

## 📦 CRAN preparation

- `DESCRIPTION`: title in title case, rewritten description with a
  reference to the accompanying paper, both authors listed as
  copyright holders, `URL` and `BugReports` added.
- Documentation: replaced the character `≥` with `>=`, so that the
  PDF reference manual builds.
- `flowengineR_start()` no longer writes objects into the global
  environment. The objects created in the menu are now returned
  invisibly as a list (e.g. `start <- flowengineR_start()`). Entering
  0 now leaves the menu, vignettes are opened from this package only,
  and the function returns immediately in non-interactive sessions.
- `%||%` is now defined internally, so the package works on R 4.1 to
  4.3 as stated in `Depends`.
- Default output locations no longer point to the home or working
  directory: `controller_publish()` now uses `tempdir()`, and the local
  and multicore batchtools engines create their registry in a subfolder
  of `tempdir()`. Set `output_folder` or `registry_folder` explicitly to
  keep the files.
- An existing registry folder is now only replaced if it is empty or
  holds a previous batchtools registry; any other folder is left
  untouched and an error is raised.
- The multicore engines now use `getOption("mc.cores", 2L)` cores by
  default instead of all available cores; `parallel` is no longer a
  dependency.
- The SLURM engines no longer default to local development folders:
  `registry_folder` and `slurm_template` (batchtools SLURM engines) and
  `output_folder` (`execution_basic_slurm_array`) must now be set
  explicitly; otherwise a clear error is raised before any work starts.
- Tests: the multicore workflow tests are skipped on Windows, PDF export
  is only checked where pandoc and LaTeX are available, and no test uses
  more than two cores.
- `register_engine()` now loads engine files into their own environment
  instead of the global environment, so the user's workspace is no
  longer modified. Registered engines see the same package functions as
  the built-in engines.
- All exported functions now have runnable examples; the example of
  `show_template()` no longer uses `\dontrun{}`.
- `create_dataset_bank()` and `run_workflow()` no longer change the
  random number generator state of the R session; results stay
  reproducible through the `seed` arguments. `withr` is now imported.

## 🔧 Fixes

- `log_msg()`: the log level now works as a threshold. With the default
  `"info"`, warnings and errors are shown and debug messages are hidden
  (previously the reverse); `"none"` hides all messages, and
  `abort = TRUE` now stops even when logging is switched off.
- `build_engine_with_llm_zip()` no longer prints the file list of the
  `zip` program.
- `show_template()`: corrected the file paths named in the split
  templates; the printed template now ends with a line break.
- Vignettes: fixed links to other vignettes and removed links to help
  pages that only exist on a pkgdown website.
- `build_engine_with_llm_zip()` now works for all ten engine types.
  Previously `inprocessing`, `postprocessing`, `reportelement`, `report`
  and `publish` failed: the prompt template for in-processing engines
  was missing, two reference file names were wrong, three prompt
  templates contained `[[...]]`, which `glue` read as placeholders, and
  the publishing type was registered as `"publishing"` instead of
  `"publish"`. `"evaluation"` and `"publishing"` are now accepted as
  aliases, and the prompt file is always written in UTF-8.
- LLM prompt templates: the headings of five templates showed escape
  codes such as `\U0001F527` instead of symbols, and the evaluation
  template now names the input columns `predictions` and `actuals` as
  used by the framework.
- The materials of the engine builder (`inst/example_enginebuild_LLM/`)
  now include the report and publish vignettes, and the copies of the
  other vignettes are up to date.
- `publish_pdf_basis`: the `alias` element of the output now holds the
  publish alias; previously it held an unrelated function.
- `execution_adaptive_output_sequential`: an incomplete result of a
  custom stability function now raises the intended error message
  instead of failing while the message is created.
- Tests: a new test builds the LLM package for every engine type.
- In-processing engine adversarial debiasing: the adjusted model was
  identical to the base model, because the updated observation weights
  were stored where the training engines do not read them. The weights
  are now passed on as `sample_weight`, so the model is retrained with
  them (`train_glm`, `train_gbm`). The expected warning about non-integer
  successes of weighted binomial GLMs is suppressed, and the engine warns
  when it is combined with `train_lm`, which does not use weights.
- Renamed the engine `inprocessing_fairness_adversialdebiasing` to
  `inprocessing_fairness_adversarialdebiasing` (spelling), together with
  its functions, control template and vignette. The old engine name
  still works and shows a message once per session.
- In-processing documentation: the inputs of the wrapper (`control`,
  `driver_train`), the output initializer `initialize_output_inprocessing()`,
  the engine parameters in the examples and the control template (which
  passed arguments that `controller_inprocessing()` does not have) are
  now correct.
- Documentation: corrected the file names of control templates named in
  vignettes and help pages (many pointed to files that do not exist),
  names of functions and engines in several vignettes and help pages
  (e.g. `initialize_output_postprocessing()`, `controller_training()`,
  `eval_mse`), and the outputs listed for reportelement engines.
- Control templates: the templates for `preprocessing_fairness_resampling`,
  `train_gbm`, `postprocessing_fairness_genresidual` and the three
  evaluation engines could not be run (unknown arguments or a trailing
  comma), the publishing templates lacked the required `obj_name`, and
  the boxplot template used a grouping variable that the example data
  does not contain and aliases that the report template does not use.
  New tests run all templates and a reporting workflow built from them.
- `reportelement_boxplot_predictions`: a missing grouping variable now
  gives a clear error message instead of "argument is of length zero".
- "Getting Started" vignette: the example now selects the evaluation
  engines via `evaluation` (previously `eval`, which was ignored), shows
  how to access the aggregated metrics and the model, and uses the
  correct structure for the log settings.
- The LLM demonstration vignette states with which version the archived
  demonstration was created.
- `controller_training()` no longer needs a global object `vars`: if no
  `formula` is given, `run_workflow()` builds `target ~ features +
  protected attributes` from `control$data$vars` when the workflow
  starts. An explicitly given formula is used unchanged.
- `settings$global_seed` was documented but had no effect. `run_workflow()`
  now sets this seed (default `1`) at the start, so that steps without a
  seed of their own are reproducible as well (e.g. a user-defined split
  followed by `train_gbm`). Results of workflows whose splitter sets a
  seed are unchanged, and the random number state of the session is
  still restored afterwards.
- `flowengineR_start()`: menu item 4 now lists the engines of each type
  (previously only the engine types).
- Report texts are now in English: `reportelement_text_msesummary` writes
  "The average MSE across all splits is ...", and the title of
  `report_modelsummary` is "Model Summary" (previously German).
- Documentation: explained that the training formula can be left out,
  and corrected code examples that used functions or engines that do not
  exist (`controller_eval()`, `controller_train()`,
  `run_workflow_variants()`, the engines `rf`, `gbm` and `evaluate_mse`).
- `register_engine()` no longer changes the random number state of the R
  session. The validation runs the engine on random dummy data, and the
  validation of splitter engines set a fixed seed.
  


# flowengineR 1.0.2

## 🔧 Fixes

- Declared `jsonlite` in `Suggests`; it is used by the vignette
  "LLM Demonstration: Eval Median". The vignette now also builds
  without `jsonlite` and then shows the manifest as plain text.
- The "Workflow Results" section of that vignette was empty because
  the archived results file was not found. The file is renamed to
  `provenance/workflow_results.rds` (contents and checksum unchanged),
  which also keeps all file paths within the 100-byte limit for
  portable tarballs.
- `.Rbuildignore`: fixed two patterns that did not match, and excluded
  `tools/` and `CITATION.cff` from the package build.
- `na.omit()` and `uniroot()` from stats are now called with an explicit
  namespace.
- `LICENSE` now uses the standard two-line R format for MIT; the full
  licence text moved to `LICENSE.md`.
  
  

# flowengineR 1.0.1

## 🔧 Fixes

- `build_engine_with_llm_zip()` now reports the archive location relative to
  `tempdir()` instead of the absolute path, making console output identical
  across machines.
- Shortened console messages in `build_engine_with_llm_zip()` and
  `register_engine()` so that output fits the text width of the accompanying
  manuscript.
  
  

# flowengineR 1.0.0

## 🚀 Initial release

This release introduces the foundational architecture of the `flowengineR` package, a modular R framework for defining, executing, and evaluating machine learning workflows.

### ✨ Core features
- Modular pipeline system with interchangeable "engines"
- Support for pre-, in-, and post-processing fairness methods
- Fully configurable via control objects (`controller_*`)
- Integrated evaluation and reporting structure
- Built-in compatibility with `batchtools` for adaptive and parallel execution

### 🧪 Testing & CI
- Full `testthat` support for internal functions and workflow logic
- GitHub Actions CI enabled (`devtools::check`)

### 📚 Documentation
- First vignettes included:
  - Getting started
  - End-to-end example
- Comprehensive `README` with installation and usage

### 🔧 Utilities
- Meta-level workflow logic based on control abstraction
- Standardized input/output contracts for engines

This version marks the stable foundation for further extension toward publishing and benchmarking.
