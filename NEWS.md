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
