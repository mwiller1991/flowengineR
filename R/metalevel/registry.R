#--------------------------------------------------------------------
### registry for engines ###
#--------------------------------------------------------------------
# Registry for Engines

#' Register and load engines for the fairness toolbox
#'
#' This function registers all available engines by dynamically sourcing the relevant files.
#'
#' @export
engines <- list()

#' Helper function to load and register engines from files
#'
#' @param engine_name The name of the engine to register.
#' @param file_path The file path to the engine definition.
#' @return Updates the global `engines` list with the registered engine.
#' @export
register_engine <- function(engine_name, file_path) {
  tryCatch({
    # Load the file
    source(file_path, local = FALSE)  # Load functions into the global environment
    
    # Check if the wrapper exists
    wrapper_name <- paste0("wrapper_", engine_name)
    if (exists(wrapper_name, envir = .GlobalEnv)) {
      .GlobalEnv$engines[[engine_name]] <- get(wrapper_name, envir = .GlobalEnv)  # Update in the global environment
      message(paste("Registered engine:", engine_name))
    } else {
      stop(paste("Function", wrapper_name, "not found in file:", file_path))
    }
  }, error = function(e) {
    warning(paste("Failed to register engine:", engine_name, "->", e$message))
  })
}

# Load preinstalled Train-Engines 
register_engine("train_lm", "~/fairness_toolbox/R/engines/training/engine_train_lm.R")

# Load preinstalled Fairness-Engines 
register_engine("fairness_pre_method1", "~/fairness_toolbox/R/engines/fairness/pre-processing/engine_fairness_pre_method1.R")
register_engine("fairness_post_genresidual", "~/fairness_toolbox/R/engines/fairness/post-processing/engine_fairness_post_genresidual.R")

# Load preinstalled Evaluation-Engines
register_engine("eval_summarystats", "~/fairness_toolbox/R/engines/evaluation/general/engine_eval_summarystats.R")
register_engine("eval_mse", "~/fairness_toolbox/R/engines/evaluation/precision/engine_eval_mse.R")
register_engine("eval_statisticalparity", "~/fairness_toolbox/R/engines/evaluation/fairness/engine_eval_statisticalparity.R")

# Load new Splitter-Engines
register_engine("split_random", "~/fairness_toolbox/R/engines/split/engine_split_random.R")
register_engine("split_cv", "~/fairness_toolbox/R/engines/split/engine_split_cv.R")

# Debugging: List registered engines
print(names(engines))
#--------------------------------------------------------------------