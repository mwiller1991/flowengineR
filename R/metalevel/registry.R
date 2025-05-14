#--------------------------------------------------------------------
### registry for engines ###
#--------------------------------------------------------------------
#--------------------------------------------------------------------
#' Register an Engine
#'
#' Registers an engine by sourcing its file, validating it, and adding it to the global registry.
#' The function dynamically derives wrapper, default hyperparameters, and validation functions based on the file name.
#'
#' @param engine_name The name of the engine (e.g., "train_lm").
#' @param file_path The file path to the engine definition.
#'
#' @return Registers the engine in the global registry if validation passes.
#' @export
#' 
engines <- list()

engine_name <- "split_userdefined"
file_path <- "~/fairness_toolbox/R/engines/1_split/engine_split_userdefined.R"

register_engine <- function(engine_name, file_path) {
  tryCatch({
    # Derive engine type from the engine name
    engine_type <- strsplit(engine_name, "_")[[1]]
    
    if (engine_type[1] == "fairness") {
      full_engine_type <- paste(engine_type[1], engine_type[2], sep = "_")  # Combine "fairness" with "post", "pre", or "in"
    } else {
      full_engine_type <- engine_type[1]  # For other types like "train", "split", "report"
    }
    
    # Source the engine file
    source(file_path, local = FALSE)
    
    # Dynamically construct function names
    wrapper_function_name <- paste0("wrapper_", engine_name)
    engine_function_name <- paste0("engine_", engine_name)
    default_params_function_name <- paste0("default_params_", engine_name)
    validate_function_name <- paste0("validate_engine_", full_engine_type)
    
    # Check if all required functions exist
    if (!exists(engine_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Engine function", engine_function_name, "not found in file:", file_path))
    }
    if (!exists(wrapper_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Wrapper function", wrapper_function_name, "not found in file:", file_path))
    }
    if (!exists(default_params_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Default params function", default_params_function_name, "not found in file:", file_path))
    }
    if (!exists(validate_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Validation function", validate_function_name, "not found for engine type:", full_engine_type))
    }
    
    # Get the functions
    wrapper_function <- get(wrapper_function_name, envir = .GlobalEnv)
    default_params_function <- get(default_params_function_name, envir = .GlobalEnv)
    validate_function <- get(validate_function_name, envir = .GlobalEnv)
    
    # Validate the engine
    validate_function(wrapper_function, default_params_function)
    
    # Register the engine
    .GlobalEnv$engines[[engine_name]] <- wrapper_function
    message(paste("[SUCCESS] Engine registered successfully:", engine_name, "as type:", full_engine_type))
    message("---------------------------------------------------------------------------------------------")
    
  }, error = function(e) {
    warning(paste("[WARNING] Failed to register engine from file:", file_path, "->", e$message))
  })
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### load validate_engines-functions ###
#--------------------------------------------------------------------
source("~/fairness_toolbox/R/metalevel/subregistry_validate_engines.R")
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### load preinstalled package-engines ###
#--------------------------------------------------------------------
# Load preinstalled Splitter-Engines (without validation)
#Sys.setenv(VALIDATE_MODE = "TRUE")
register_engine("split_userdefined", "~/fairness_toolbox/R/engines/1_split/engine_split_userdefined.R")
#Sys.unsetenv("VALIDATE_MODE")

# Load preinstalled Splitter-Engines
register_engine("split_random", "~/fairness_toolbox/R/engines/1_split/engine_split_random.R")
register_engine("split_cv", "~/fairness_toolbox/R/engines/1_split/engine_split_cv.R")

# Load preinstalled Train-Engines 
register_engine("train_lm", "~/fairness_toolbox/R/engines/2_training/engine_train_lm.R")
register_engine("train_glm", "~/fairness_toolbox/R/engines/2_training/engine_train_glm.R")

# Load preinstalled Fairness-Engines 
register_engine("fairness_pre_resampling", "~/fairness_toolbox/R/engines/3_fairness/3_1_pre-processing/engine_fairness_pre_resampling.R")
register_engine("fairness_in_adversialdebiasing", "~/fairness_toolbox/R/engines/3_fairness/3_2_in-processing/engine_fairness_in_adversialdebiasing.R")
register_engine("fairness_post_genresidual", "~/fairness_toolbox/R/engines/3_fairness/3_3_post-processing/engine_fairness_post_genresidual.R")

# Load preinstalled Evaluation-Engines
register_engine("eval_summarystats", "~/fairness_toolbox/R/engines/4_evaluation/4_1_general/engine_eval_summarystats.R")
register_engine("eval_mse", "~/fairness_toolbox/R/engines/4_evaluation/4_2_precision/engine_eval_mse.R")
register_engine("eval_statisticalparity", "~/fairness_toolbox/R/engines/4_evaluation/4_3_fairness/engine_eval_statisticalparity.R")

# Load preinstalled Reportelement-Engines
register_engine("reportelement_table_splitmetrics", "~/fairness_toolbox/R/engines/5_reporting/5_1_reportelement/engine_reportelement_table_splitmetrics.R")
register_engine("reportelement_boxplot_predictions", "~/fairness_toolbox/R/engines/5_reporting/5_1_reportelement/engine_reportelement_boxplot_predictions.R")
register_engine("reportelement_text_msesummary", "~/fairness_toolbox/R/engines/5_reporting/5_1_reportelement/engine_reportelement_text_msesummary.R")

# Load preinstalled Report-Engines
register_engine("report_modelsummary", "~/fairness_toolbox/R/engines/5_reporting/5_2_report/engine_report_modelsummary.R")

# Load preinstalled Publish-Engines
register_engine("publish_pdf_basis", "~/fairness_toolbox/R/engines/5_reporting/5_3_publish/engine_publish_pdf_basis.R")
register_engine("publish_excel_basis", "~/fairness_toolbox/R/engines/5_reporting/5_3_publish/engine_publish_excel_basis.R")

# Debugging: List registered engines
print(names(engines))
#--------------------------------------------------------------------