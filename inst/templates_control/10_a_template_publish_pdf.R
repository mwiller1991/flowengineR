# ============================================================
# Template for Publishing Engine: publish_pdf_basis
# ============================================================

# 1. Engine Selection
control$engine_select$publish <- list(
  main_pdf = "publish_pdf_basis"
)

# 2. Publishing Parameters
control$params$publish <- controller_publish(
  params = list(
    main_pdf = list(
      obj_type = "report",       # or "reportelement"
      obj_name = "main_report"   # alias of the exported report (see 9_a template)
    )
  )
)

# Available Parameters:
# - obj_type (required): Must be one of "report" or "reportelement"
# - obj_name (required): Alias of the object to export, as used in
#   control$engine_select$report or control$engine_select$reportelement

# Notes:
# - file_path will be passed by the workflow controller at runtime
# - the object must support "pdf" in its compatible_formats