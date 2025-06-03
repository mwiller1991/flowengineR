# ============================================================
# Template for Execution Engine: execution_basic_batchtools_slurm
# ============================================================

# 1. Engine Selection
control$engine_select$execution <- "execution_basic_batchtools_slurm"

# 2. Execution Parameters
control$params$execution <- controller_execution(
  params = list(
    registry_folder = "~/flowengineR/tests/BATCHTOOLS/bt_SLURM_basic/bt_registry_SLURM",  # Path to batchtools registry
    slurm_template = "~/flowengineR/tests/BATCHTOOLS/bt_SLURM_basic/default.tmpl",         # SLURM job template
    seed = 42,                        # Seed for reproducibility
    required_packages = character(0),# Required packages for each job
    resources = list(
      ncpus = 1,                      # Number of CPUs requested per SLURM job
      memory = 2048,                  # Memory per job in MB
      walltime = 3600                 # Maximum wall time per job in seconds
    )
  )
)

# --- Available Parameters for execution_basic_batchtools_slurm ---
# registry_folder: Path to the batchtools registry directory (string).
# slurm_template: Path to the SLURM template file (must be accessible from submission node).
# seed: Integer used for reproducibility across registry and job mapping.
# required_packages: Vector of package names required in each job (default: character(0)).
# resources: Named list specifying SLURM resource constraints (ncpus, memory, walltime).
#
# Notes:
# - This engine is designed for HPC clusters using the SLURM scheduler.
# - Each split is submitted as a separate job using the given SLURM template.
# - You can track job progress and errors using the batchtools registry at `registry_folder`.
# - Use `resume_workflow()` after completion to process outputs if run in deferred mode.