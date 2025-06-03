# ============================================================
# Template for Report Engine: report_modelsummary
# ============================================================

# 1. Engine Selection
control$engine_select$report <- list(
  main_report = "report_modelsummary"
)

# 2. Report Parameters
control$params$report <- controller_report(
  params = list(
    main_report = list(
      mse_text = "mse_text",                  # Textblock with average MSE
      gender_box = "pred_plot_gender",        # Boxplot predictions by gender
      age_box = "pred_plot_age",              # Boxplot predictions by age
      metrics_table = "split_table"           # Evaluation metrics table
    )
  )
)

# --- Available Parameters for report_modelsummary ---
# mse_text: Alias of reportelement_text_msesummary
# gender_box: Alias of reportelement_boxplot_predictions
# age_box: Alias of reportelement_boxplot_predictions (different group_var)
# metrics_table: Alias of reportelement_table_splitmetrics
#
# Notes:
# - Output is a structured multi-section report object
# - Can be rendered by compatible publishing engines (e.g., PDF, HTML, JSON)
# - All referenced aliases must exist in reportelement output