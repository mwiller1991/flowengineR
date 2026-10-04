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
