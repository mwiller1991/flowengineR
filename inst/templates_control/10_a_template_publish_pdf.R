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
      obj_type = "report"  # or "reportelement"
    )
  )
)

# Available Parameters:
# - obj_type (required): Must be one of "report" or "reportelement"

# Notes:
# - file_path will be passed by the workflow controller at runtime
# - the object must support "pdf" in its compatible_formats