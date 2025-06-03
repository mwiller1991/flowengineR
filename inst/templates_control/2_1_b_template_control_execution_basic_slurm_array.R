# ============================================================
# Template for Execution Engine: execution_basic_slurm_array
# ============================================================

# 1. Engine Selection
control$engine_select$execution <- "execution_basic_slurm_array"

# 2. Execution Parameters (where to write input files)
control$params$execution <- controller_execution(
  params = list(
    output_folder = "slurm_inputs"
  )
)

# --- Available Parameters for execution_basic_slurm_array ---
# output_folder: character, default = "slurm_inputs"
#   → path to directory where control and split files are stored
#
# Notes:
# - This engine does not perform any training itself.
# - Splits and the control object are serialized for external execution.
# - Resumption is done via `prepare_resume_from_slurm_array()`.
# - This template can be found at: inst/templates_control/2_1_b_template_control_execution_basic_slurm_array.R