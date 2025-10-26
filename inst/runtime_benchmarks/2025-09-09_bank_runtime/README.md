---
title: "README"
output: html_document
---

# Runtime Benchmark: Bank Workflow

This folder archives the full runtime benchmarking of `flowengineR` using the realistic synthetic **bank dataset**.  
The benchmark evaluates **end-to-end workflow runtime** under different dataset sizes, cross-validation folds, and execution modes.

## Contents
- `provenance/` → benchmark script (`benchmark_runtime.R`), control factories, console log, session info  
- `outputs/` → benchmark results (`runtime_summary.csv`, `runtime_results.rds`), batchtools registries  
- `manifest.json` → metadata (dataset, sizes, CV folds, controls, execution types, hardware, seeds)  
- `README.md` → this documentation file

## Benchmark Design
- **Dataset:** generated with `create_dataset_bank(onehot = TRUE, pos_rate = 0.05)`  
- **Sizes:** `XS = 1e3L`, `S = 5e3L`, `M = 1e4L`, `L = 2e4L`, `XL = 5e4L`, `XXL = 1e5L` (configurable in the script)  
- **Cross-validation:** stratified, `S = 6`, `M = 12`, `L = 20` 
- **Controls (example set):** `lm_base`, `glm_base`, `gbm_base`, *multiple fairness variants*  
- **Execution:**  
  - `execution_basic_sequential`  
  - `execution_basic_batchtools_multicore`  
- **Metric:** median runtime (seconds) across repeated runs (`bench::mark`, iterations = 3)  
- **Memory profiling:** disabled for multicore runs due to `bench` limitations

## Reproduction
To reproduce the benchmark:

```r
source("inst/runtime_benchmarks/2025-09-09_bank_runtime/provenance/benchmark_runtime.R")

# Load summarized results
read.csv("inst/runtime_benchmarks/2025-09-09_bank_runtime/outputs/runtime_summary.csv")
```

## Outputs
- `runtime_summary.csv` → compact summary table (size, n, cv_folds, control, execution, median runtime)  
- `runtime_results.rds` → full `bench` objects for each case (optional deep analysis)

## Provenance
- `benchmark_runtime.R` → full benchmark script
- `operational_runs.R` → operational test script
- `control_factories.R` → control factory definitions for workflow setup  
- `sessionInfo.txt` → R session info (packages, versions, platform)  

## Hardware & Environment
- Example run: **MacBook Air M3 2024**, 16 GB Memory, 8‑Core CPU, 10‑Core GPU, 512 GB SSD, macOS 15.6.1  
- Seeds fixed for dataset generation and CV splits

---
