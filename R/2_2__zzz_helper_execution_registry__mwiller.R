#--------------------------------------------------------------------
### Helper: Prepare folder for a batchtools registry ###
#--------------------------------------------------------------------
#' Helper: Prepare a Folder for a New batchtools Registry
#'
#' `batchtools::makeRegistry()` requires that its folder does not exist yet.
#' This helper removes an existing folder only if that is safe, i.e. if it
#' is empty or contains a previous batchtools registry (recognized by the
#' file `registry.rds`). Any other existing folder is left untouched and an
#' error is raised, so that user files are never deleted. A missing parent
#' folder is created, as `batchtools::makeRegistry()` requires it to exist.
#'
#' @param path Character string. Folder intended for the registry.
#'
#' @return `path`, invisibly. Called for its side effect.
#' @noRd
prepare_registry_folder <- function(path) {
  if (is.null(path)) {
    stop("[EXECUTION] No 'registry_folder' set. Please provide it in ",
         "control$params$execution$params.", call. = FALSE)
  }
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("[EXECUTION] 'registry_folder' must be a single, non-empty path.",
         call. = FALSE)
  }
  
  if (dir.exists(path)) {
    is_registry <- file.exists(file.path(path, "registry.rds"))
    is_empty <- length(list.files(path, all.files = TRUE, no.. = TRUE)) == 0L
    if (!is_registry && !is_empty) {
      stop(sprintf(paste0(
        "[EXECUTION] Folder '%s' already exists and is not a batchtools ",
        "registry, so it is not deleted. Please choose a new or empty ",
        "folder as 'registry_folder'."), path), call. = FALSE)
    }
    unlink(path, recursive = TRUE)
  } else if (file.exists(path)) {
    stop(sprintf(
      "[EXECUTION] '%s' is a file, not a folder. Please choose another 'registry_folder'.",
      path), call. = FALSE)
  }
  
  # makeRegistry() requires the parent folder to exist, e.g. for the
  # 'iter_<i>' subfolders of the adaptive engines
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  
  invisible(path)
}