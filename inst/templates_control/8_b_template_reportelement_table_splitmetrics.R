# ============================================================
# Template for Reportelement Engine: reportelement_table_splitmetrics
# ============================================================

# 1. Engine Selection
control$reportelement <- list(
  split_table = "reportelement_table_splitmetrics"
)

# 2. Reportelement Parameters
control$params$reportelement <- controller_reportelement(
  params = list(
    split_table = list(
      metrics = c("mse", "summarystats")  # Specify metrics to include in the table
    )
  )
)

# --- Available Parameters for reportelement_table_splitmetrics ---
# metrics: Character vector of metric types to extract, e.g.:
#   - "mse"
#   - "summarystats"
#   - "spd"
#   - (others, depending on which eval_* engines are registered)

# Notes:
# - The table includes one row per split and one column per selected metric
# - Supports output formats: pdf, html, xlsx, json
# - Alias name ("split_table") is used in the output object to identify this block