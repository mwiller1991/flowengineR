# ============================================================
# Template for Execution Engine: execution_basic_batchtools_local
# ============================================================

# 1. Engine Selection
control$execution <- "execution_basic_batchtools_local"

# 2. Execution Parameters
control$params$execution <- controller_execution(
  params = list(
    registry_folder = "~/fairness_toolbox/tests/BATCHTOOLS/bt_registry_basic",
    seed = 123,
    required_packages = c("fairnessToolbox"),
    resources = list(
      ncpus = 1,
      memory = 2048,
      walltime = 3600
    )
  )
)

# --- Available Parameters for execution_basic_batchtools_local ---
# registry_folder: path to batchtools registry
# seed: integer (registry seed)
# required_packages: character vector (e.g., c("fairnessToolbox"))
# resources:
#   - ncpus: integer (default: 1)
#   - memory: MB per job (default: 2048)
#   - walltime: seconds per job (default: 3600)
#
# Notes:
# - Each job runs run_workflow_single() on a single split.
# - This engine uses the local backend of batchtools.
# - This template can be found at: inst/templates_control/2_1_c_template_control_execution_basic_batchtools_local.R