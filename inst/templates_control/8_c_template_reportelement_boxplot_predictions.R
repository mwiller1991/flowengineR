# ============================================================
# Template for Reportelement Engine: reportelement_boxplot_predictions
# ============================================================

# 1. Engine Selection
control$engine_select$reportelement <- list(
  pred_plot = "reportelement_boxplot_predictions"
)

# 2. Reportelement Parameters
control$params$reportelement <- controller_reportelement(
  params = list(
    pred_plot = list(
      group_var = "gender",     # Binary grouping variable
      source = "train"          # Options: "train", "post", "inproc"
    )
  )
)

# --- Available Parameters for reportelement_boxplot_predictions ---
# group_var: Character, name of binary variable in test data for grouping
# source: "train", "post", or "inproc"

# Notes:
# - Output is a ggplot2 boxplot of predictions grouped by `group_var` per split
# - Predictions and test data are pulled automatically from `workflow_results` and `split_output`
# - Compatible output formats: pdf, html