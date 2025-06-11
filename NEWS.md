# flowengineR 0.1.0

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
