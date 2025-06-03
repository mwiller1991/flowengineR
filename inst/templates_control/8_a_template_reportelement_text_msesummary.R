# ============================================================
# Template for Reportelement Engine: reportelement_text_msesummary
# ============================================================

# 1. Engine Selection
control$engine_select$reportelement <- list(
  mse_text = "reportelement_text_msesummary"
)

# 2. Reportelement Parameters
control$params$reportelement <- controller_reportelement(
  params = list(
    mse_text = list()  # No parameters required
  )
)

# --- Available Parameters for reportelement_text_msesummary ---
# None. The engine summarizes the MSE across splits internally.
# alias: "mse_text" used to identify this reportelement in the output

# Notes:
# - Requires that eval_mse was run and its output is present under each split
# - Output is a character summary like: "Der durchschnittliche MSE über alle Splits beträgt 0.0385."
# - Compatible with: pdf, html, json, markdown