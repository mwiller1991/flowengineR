# ============================================================
# Template for Reportelement Engine: reportelement_boxplot_predictions
# ============================================================

# 1. Engine Selection
control$engine_select$reportelement <- list(
  pred_plot_gender = "reportelement_boxplot_predictions",
  pred_plot_age = "reportelement_boxplot_predictions"
)

# 2. Reportelement Parameters
control$params$reportelement <- controller_reportelement(
  params = list(
    pred_plot_gender = list(
      group_var = "gender.Female",  # Grouping variable in the test data
      source = "train"              # Options: "train", "post", "inproc"
    ),
    pred_plot_age = list(
      group_var = "age_group.<30",
      source = "train"
    )
  )
)

# --- Available Parameters for reportelement_boxplot_predictions ---
# group_var: Character, name of a variable in the test data used for grouping
#            (here: binary dummies of the example dataset)
# source: "train", "post", or "inproc"

# Notes:
# - Output is a ggplot2 boxplot of predictions grouped by `group_var` per split
# - Predictions and test data are pulled automatically from `workflow_results` and `split_output`
# - The aliases pred_plot_gender and pred_plot_age are used by the report template (9_a)
# - Compatible output formats: pdf, html
