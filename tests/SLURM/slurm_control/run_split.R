#!/usr/bin/env Rscript

# Get SLURM_ARRAY_TASK_ID
args <- commandArgs(trailingOnly = TRUE)
split_id <- as.integer(args[1])

# Load inputs
control <- readRDS("~/fairness_toolbox/tests/SLURM/slurm_inputs/control_base.rds")
split_output <- readRDS("~/fairness_toolbox/tests/SLURM/slurm_inputs/split_output.rds")
split <- split_output$splits[[split_id]]

# Assign split to control
control$data$train <- split$train
control$data$test  <- split$test

# Optional: track split number
control$params$split <- list(split_id = split_id)

# Run single workflow
result <- run_workflow_single(control)

# Save result
dir.create("slurm_outputs", showWarnings = FALSE)
saveRDS(result, file = file.path("~/fairness_toolbox/tests/SLURM/slurm_outputs", paste0("result_split_", split_id, ".rds")))