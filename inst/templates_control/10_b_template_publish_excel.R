# ============================================================
# Template for Publishing Engine: publish_excel_basis
# ============================================================

# 1. Engine Selection
control$publish <- list(
  export_excel = "publish_excel_basis"
)

# 2. Publishing Parameters
control$params$publish <- controller_publish(
  params = list(
    export_excel = list(
      obj_type = "report"  # or "reportelement"
    )
  )
)

# Available Parameters:
# - obj_type (required): Must be one of "report" or "reportelement"

# Notes:
# - file_path is set by the workflow controller at runtime
# - object must support "xlsx" in its compatible_formats