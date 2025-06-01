simulate_slurm_run <- function(
    control_path = "~/fairness_toolbox/tests/SLURM/slurm_inputs/control_base.rds",
    split_output_path = "~/fairness_toolbox/tests/SLURM/slurm_inputs/split_output.rds",
    result_dir = "~/fairness_toolbox/tests/SLURM/slurm_outputs"
) {
  control <- readRDS(control_path)
  split_output <- readRDS(split_output_path)
  n_splits <- length(split_output$splits)
  
  dir.create(result_dir, showWarnings = FALSE)
  
  for (i in names(split_output$splits)) {
    message(sprintf("[SIMULATION] Processing split %s", i))
    
    control$data$train <- split_output$splits[[i]]$train
    control$data$test  <- split_output$splits[[i]]$test
    control$params$split <- list(split_id = i)
    
    result <- run_workflow_single(control)
    
    saveRDS(result, file = file.path(result_dir, paste0("result_split_", i, ".rds")))
  }
}
