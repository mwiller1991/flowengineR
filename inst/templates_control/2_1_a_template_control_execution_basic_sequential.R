# ============================================================
# Template for Execution Engine: execution_basic_sequential
# ============================================================

# 1. Engine Selection
control$engine_select$execution <- "execution_basic_sequential"

# 2. Execution Parameters (none required)
control$params$execution <- controller_execution(
  params = list()
)

# --- Available Parameters for execution_basic_sequential ---
# (none)
#
# Notes:
# - This engine runs all splits sequentially using run_workflow_single().
# - No parallelization, registry or batching is applied.
# - This template can be found at: inst/templates_control/2_1_a_template_control_execution_basic_sequential.R