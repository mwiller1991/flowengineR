#--------------------------------------------------------------------
### Helper: Prepare Resume Object from SLURM Array Execution ###
#--------------------------------------------------------------------
#' Helper: Prepare Resume Object from SLURM Array Execution
#'
#' Collects control structure, split configuration, and individual result files 
#' from a SLURM array job and compiles a standardized resume object that can be 
#' passed directly to `resume_workflow()`.
#'
#' Wraps internal loading and file validation logic, and supports flexible file 
#' structure and metadata tagging.
#'
#' **Purpose:**
#' - Automates reconstruction of the execution state after external parallel computation.
#' - Enables full workflow continuation (e.g., aggregation, reporting) after SLURM execution.
#'
#' **Required Files:**
#' - Control object (`control_base.rds`) and split object (`split_output.rds`) 
#'   must be saved by the submission wrapper.
#' - Individual result files must follow the naming pattern `result_split_<id>.rds`
#'   and reside in the defined result directory.
#'
#' **Usage Example:**
#' ```r
#' resume_object <- prepare_resume_from_slurm_array(
#'   control_path = "slurm_inputs/control_base.rds",
#'   split_output_path = "slurm_inputs/split_output.rds",
#'   result_dir = "slurm_outputs/"
#' )
#'
#' result <- resume_workflow(resume_object)
#' ```
#'
#' @param control_path Path to the serialized control object (`.rds`). Default: `"slurm_inputs/control_base.rds"`.
#' @param split_output_path Path to the serialized split output (`.rds`). Default: `"slurm_inputs/split_output.rds"`.
#' @param result_dir Directory containing the result files `result_split_<id>.rds`. Default: `"slurm_outputs"`.
#' @param metadata Optional named list of metadata to include in the resume object (e.g., `engine`, `timestamp`).
#'
#' @return A validated resume object compatible with `resume_workflow()`.
#' @examples
#' data <- create_dataset_bank(n = 500, seed = 1)
#' vars <- controller_vars(
#'   feature_vars = c("income", "loan_amount", "credit_score"),
#'   protected_vars = "gender.Female",
#'   target_var = "default",
#'   protected_vars_binary = "gender.Female"
#' )
#' control <- list(
#'   settings = list(log = list(log_show = FALSE)),
#'   data = list(full = data, vars = vars)
#' )
#' dir <- file.path(tempdir(), "slurm_array_example")
#' control$engine_select <- list(execution = "execution_basic_slurm_array")
#' control$params <- list(execution = controller_execution(
#'   params = list(output_folder = file.path(dir, "inputs"))
#' ))
#'
#' # 1. Write the input files and stop before execution
#' prepared <- run_workflow(control)
#' prepared$execution_output$continue_workflow
#' list.files(file.path(dir, "inputs"))
#'
#' # 2. Usually one SLURM array task per split; here a simple loop
#' ctrl <- readRDS(file.path(dir, "inputs", "control_base.rds"))
#' splits <- readRDS(file.path(dir, "inputs", "split_output.rds"))$splits
#' dir.create(file.path(dir, "outputs"), showWarnings = FALSE)
#' for (id in names(splits)) {
#'   ctrl$data$train <- splits[[id]]$train
#'   ctrl$data$test <- splits[[id]]$test
#'   saveRDS(run_workflow_singlesplitloop(ctrl),
#'           file.path(dir, "outputs", paste0("result_split_", id, ".rds")))
#' }
#'
#' # 3. Collect the results and finish the workflow
#' resume_object <- prepare_resume_from_slurm_array(
#'   control_path = file.path(dir, "inputs", "control_base.rds"),
#'   split_output_path = file.path(dir, "inputs", "split_output.rds"),
#'   result_dir = file.path(dir, "outputs")
#' )
#' final <- resume_workflow(resume_object)
#' names(final$aggregated_results)
#' unlink(dir, recursive = TRUE)
#' @export
prepare_resume_from_slurm_array <- function(
    control_path = "slurm_inputs/control_base.rds",
    split_output_path = "slurm_inputs/split_output.rds",
    result_dir = "slurm_outputs",
    metadata = list(engine = "SLURM_ARRAY", timestamp = Sys.time())
) {
  # Load control and split definitions
  control <- readRDS(control_path)
  split_output <- readRDS(split_output_path)
  
  # Collect result files
  workflow_results <- list()
  for (i in names(split_output$splits)) {
    result_file <- file.path(result_dir, paste0("result_split_", i, ".rds"))
    if (!file.exists(result_file)) {
      warning(sprintf("[SLURM Resume] Missing result file: %s", result_file))
      next
    }
    workflow_results[[i]] <- readRDS(result_file)
  }
  
  # Build and validate resume object
  resume_object <- controller_resume_execution(
    control = control,
    split_output = split_output,
    workflow_results = workflow_results,
    metadata = metadata
  )
  
  validate_resume_object(resume_object)
  return(resume_object)
}
#--------------------------------------------------------------------