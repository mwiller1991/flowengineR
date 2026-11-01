# ============================================================
# Template for Publishing Engine: publish_excel_basis
# ============================================================

# 1. Engine Selection
control$engine_select$publish <- list(
  export_excel = "publish_excel_basis"
)

# 2. Publishing Parameters
control$params$publish <- controller_publish(
  params = list(
    export_excel = list(
      obj_type = "reportelement",  # or "report"
      obj_name = "split_table"     # alias of the exported reportelement (see 8_b template)
    )
  )
)

# Available Parameters:
# - obj_type (required): Must be one of "report" or "reportelement"
# - obj_name (required): Alias of the object to export, as used in
#   control$engine_select$report or control$engine_select$reportelement

# Notes:
# - file_path is set by the workflow controller at runtime
# - object must support "xlsx" in its compatible_formats