#--------------------------------------------------------------------
### Controller: Input for Variable Definition ###
#--------------------------------------------------------------------
#' Controller: Variable Definition Specification
#'
#' Creates a standardized structure containing all variable names required across
#' the fairnessToolbox workflow, including input features, protected attributes, target variable,
#' and optionally grouped or binarized versions of protected attributes for evaluation.
#'
#' Designed for use in the construction of the `control` object. This controller ensures
#' that variable references are consistently named and available for engines handling
#' training, fairness adjustments, and evaluation.
#'
#' **Purpose:**
#' - Centralizes all variable references for modular engines.
#' - Ensures compatibility with pre-, in-, and post-processing fairness engines as well as evaluation components.
#'
#' **Standardized Structure:**
#' - `feature_vars`: Character vector of input features.
#' - `protected_vars`: Character vector of protected attributes (e.g., gender, age_group).
#' - `target_var`: Name of the target variable to be predicted.
#' - `protected_vars_binary`: Character vector of grouped or binary-coded protected attributes used in evaluation.
#'
#' **Usage Example:**
#' ```r
#' control$vars <- controller_vars(
#'   feature_vars = c("income", "loan_amount"),
#'   protected_vars = c("gender", "marital_status"),
#'   target_var = "default",
#'   protected_vars_binary = c("gender_Female", "marital_status_Married")
#' )
#' ```
#'
#' @param feature_vars Character vector. Input features used to train the predictive model.
#' @param protected_vars Character vector. Protected attributes used in fairness preprocessing or grouping.
#' @param target_var Character. Name of the target variable (dependent variable).
#' @param protected_vars_binary Character vector. Protected variables prepared for fairness evaluation (e.g., binary dummies).
#'
#' @return Named list. To be stored in \code{control$vars} and passed to all engines that require variable references. Compatible with all \code{fairnessToolbox} modules.
#' @export
#--------------------------------------------------------------------
controller_vars <- function(feature_vars, protected_vars, target_var, protected_vars_binary) {
  list(
    feature_vars = feature_vars,
    protected_vars = protected_vars,
    target_var = target_var,
    protected_vars_binary = protected_vars_binary
  )
}
#--------------------------------------------------------------------


#--------------------------------------------------------------------
### Controller: Split Inputs (supports multiple splitter engines)###
#--------------------------------------------------------------------
#' Controller: Split Input Specification
#'
#' Generates a standardized input configuration for any splitter engine used 
#' within the fairnessToolbox workflow. This controller ensures compatibility 
#' with built-in engines (e.g., random, stratified, CV) as well as user-defined
#' splitter engines by standardizing the required interface.
#'
#' Designed for use in the `control` object. This controller separates general information 
#' (e.g., target variable, seed) from engine-specific hyperparameters.
#'
#' **Purpose:**
#' - Provides a consistent and extensible input structure for all types of splitter engines.
#' - Facilitates modular extension of the framework.
#'
#' **Automated Variable Handling:**
#' - `target_var` is **optional** and will be automatically set via `control$vars$target_var`
#'   using `autofill_controllers_from_vars()` if not provided.
#' - This requires the prior use of `controller_vars()` when setting up the control object.
#'
#' **Standardized Structure:**
#' - `seed`: Integer seed for reproducibility.
#' - `target_var`: *(autofilled)* Character string used for stratified or CV-based splitting.
#' - `params`: Named list of engine-specific hyperparameters (e.g., `split_ratio`, `cv_folds`).
#'
#' **Usage Example:**
#' ```r
#' control$params$split <- controller_split(
#'   seed = 42,
#'   params = list(split_ratio = 0.7)
#' )
#' ```
#'
#' @param seed Optional integer for reproducibility. Default is `123`.
#' @param target_var Optional character. Name of the target variable (autofilled if not provided).
#' @param params Named list. Engine-specific configuration. Default is empty list.
#'
#' @return Named list. To be stored in \code{control$params$split} and passed to the splitter engine. Compatible with all \code{fairnessToolbox} modules.
#' @export
#--------------------------------------------------------------------

controller_split <- function(seed = 123, params = list()) {
  list(
    seed = seed,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Execution Engine Configuration ###
#--------------------------------------------------------------------
#' Controller: Execution Engine Specification
#'
#' Generates a standardized input structure for configuring any execution engine 
#' used within the fairnessToolbox workflow. This controller supports both sequential 
#' and parallel/adaptive execution strategies, including those relying on external resources 
#' like SLURM or batchtools.
#'
#' Designed for use in the construction of the `control` object. The structure is compatible 
#' with all built-in and user-defined execution engines and ensures extensibility.
#'
#' **Purpose:**
#' - Encapsulates all parameters needed for executing the training pipeline.
#' - Supports customization for parallelization, stability checks, and output persistence.
#'
#' **Standardized Structure:**
#' - `params`: A named list of engine-specific parameters (e.g., `ncpus`, `output_folder`, `max_splits`).
#'
#' **Usage Example:**
#' ```r
#' control$params$execution <- controller_execution(
#'   params = list(
#'     output_folder = "results/batch/",
#'     max_splits = 30,
#'     ncpus = 4
#'   )
#' )
#' ```
#'
#' @param params Named list. Engine-specific configuration. Default is empty list.
#'
#' @return Named list. To be stored in \code{control$params$execution} and passed to the execution engine. Compatible with all \code{fairnessToolbox} modules.
#' @export
controller_execution <- function(params = list()) {
  list(
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Preprocessing Configuration ###
#--------------------------------------------------------------------
#' Controller: Preprocessing Engine Configuration
#'
#' Generates a standardized input structure for any preprocessing engine 
#' used within the `flowengineR` workflow. This includes steps like feature transformation,
#' resampling, reweighting, or preparation of group-specific attributes prior to model training.
#'
#' Designed for use in the construction of the `control` object. Ensures compatibility 
#' with all built-in and user-defined preprocessing engines.
#'
#' **Purpose:**
#' - Supplies metadata and parameters for preprocessing steps before training.
#' - Enables flexible customization of the data pipeline (e.g., stratification, normalization helpers, resampling strategies).
#'
#' **Automated Variable Handling:**
#' - `protected_attributes` and `target_var` are **automatically filled** from `control$vars`
#'   if not manually specified.
#' - This requires the use of `controller_vars()` to define the necessary references.
#'
#' **Standardized Structure:**
#' - `protected_attributes`: *(autofilled)* Character vector of attribute names used for group-wise preprocessing (optional).
#' - `target_var`: *(autofilled)* Character string of the prediction target variable.
#' - `params`: A named list of engine-specific configuration options.
#'
#' **Usage Example:**
#' ```r
#' control$params$preprocessing <- controller_preprocessing(
#'   params = list(method = "resample_by_group", group_var = "gender")
#' )
#' ```
#'
#' @param params Named list. Engine-specific configuration. Default is empty list.
#'
#' @return Named list. To be stored in \code{control$params$preprocessing} and passed to a preprocessing engine.
#' @export
controller_preprocessing <- function(params = list()) {
  list(
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Training Engine Configuration ###
#--------------------------------------------------------------------
#' Controller: Training Engine Specification
#'
#' Generates a standardized input structure for any training engine used 
#' within the fairnessToolbox workflow. This includes the model formula, 
#' optional hyperparameters, and a flag indicating whether to normalize input data.
#'
#' Designed for use in the construction of the `control` object. Ensures compatibility 
#' with all built-in and user-defined training engines and allows flexible extension.
#'
#' **Purpose:**
#' - Specifies how the training model should be built and whether normalization is applied.
#' - Enables tuning through engine-specific hyperparameters.
#'
#' **Standardized Structure:**
#' - `formula`: A formula describing the model structure (e.g., `y ~ x1 + x2`).
#' - `norm_data`: Logical. Whether the input data should be normalized before training.
#' - `params`: A named list of hyperparameters passed to the training engine.
#'
#' **Usage Example:**
#' ```r
#' control$params$train <- controller_training(
#'   formula = default ~ age + income,
#'   norm_data = TRUE,
#'   params = list(n.trees = 100, interaction.depth = 3)
#' )
#' ```
#'
#' @param formula A model formula used to define the structure of the predictive model.
#' @param norm_data Logical. Whether to normalize the input data (default: `TRUE`).
#' @param params Named list. Engine-specific configuration. Default is empty list.
#'
#' @return Named list. To be stored in \code{control$params$train} and passed to the training engine. Compatible with all \code{fairnessToolbox} modules.
#' @export
controller_training <- function(formula = as.formula(paste(vars$target_var, "~", paste(vars$feature_vars, collapse = "+"), "+", paste(vars$protected_vars, collapse = "+"))),
                                norm_data = TRUE,
                                params = list()) {
  list(
    formula = formula,
    norm_data = norm_data,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: In-Processing Configuration ###
#--------------------------------------------------------------------
#' Controller: In-Processing Engine Configuration
#'
#' Generates a standardized input structure for any in-processing engine 
#' used within the `flowengineR` workflow. In-processing engines modify the model training process directly,
#' for example by applying constraints, reweighting, or custom optimization procedures.
#'
#' Designed for use in the construction of the `control` object. Ensures compatibility 
#' with built-in and user-defined in-processing strategies.
#'
#' **Purpose:**
#' - Passes relevant metadata and hyperparameters to in-processing methods.
#' - Enables direct influence on the model training logic (e.g., bias penalties, group-specific loss weights).
#'
#' **Automated Variable Handling:**
#' - `protected_attributes` and `target_var` are **automatically derived** from `control$vars`
#'   if not manually specified.
#' - This requires prior definition via `controller_vars()`.
#'
#' **Standardized Structure:**
#' - `protected_attributes`: *(autofilled)* Character vector of relevant attributes (e.g., grouping or constraint targets).
#' - `target_var`: *(autofilled)* Name of the target variable.
#' - `norm_data`: Logical. Whether to use normalized data (default: `TRUE`).
#' - `params`: A named list of engine-specific hyperparameters.
#'
#' **Usage Example:**
#' ```r
#' control$params$inprocessing <- controller_inprocessing(
#'   norm_data = TRUE,
#'   params = list(constraint = "equalized odds", lambda = 0.1)
#' )
#' ```
#'
#' @param norm_data Logical. Whether to use normalized data (default: TRUE).
#' @param params Named list. Engine-specific configuration. Default is empty list.
#'
#' @return Named list. To be stored in \code{control$params$inprocessing} and passed to an in-processing engine.
#' @export
controller_inprocessing <- function(norm_data = TRUE, params = list()) {
  list(
    norm_data = norm_data,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Post-Processing Configuration ###
#--------------------------------------------------------------------
#' Controller: Post-Processing Engine Configuration
#'
#' Generates a standardized input structure for any post-processing engine 
#' used within the `flowengineR` workflow. Post-processing engines adjust 
#' model predictions after training, without modifying the model itself.
#'
#' Typical use cases include: threshold correction, group-based adjustments, 
#' rule-based overlays, or compliance alignment.
#'
#' **Purpose:**
#' - Enables flexible prediction adjustment logic as a modular step.
#' - Supports group-specific postprocessing using binary attributes as conditions.
#'
#' **Binary Attribute Requirement:**
#' - The workflow expects binary/grouped versions of protected or grouping attributes.
#' - These must be defined in `control$vars$protected_vars_binary` using `controller_vars()`.
#' - Each variable listed must be strictly binary (e.g., 0/1 or TRUE/FALSE).
#'
#' **Workflow Injection:**
#' Before executing the engine, the workflow injects the following data frame:
#' ```r
#' postprocessing_data <- cbind(
#'   predictions = <numeric>,        # model predictions
#'   actuals     = <factor/numeric>, # true outcome
#'   ... group-specific binary attributes ...
#' )
#' ```
#' - Column names used in postprocessing must match those in `protected_vars_binary`.
#'
#' **Standardized Structure:**
#' - `protected_name`: *(autofilled)* Character vector of binary/grouping attributes.
#' - `params`: Named list of additional configuration passed to the engine.
#'
#' **Usage Example:**
#' ```r
#' control$params$postprocessing <- controller_postprocessing(
#'   params = list(method = "threshold_shift", delta = 0.05)
#' )
#' ```
#'
#' @param params Named list. Engine-specific configuration. Default is empty list.
#'
#' @return Named list. To be stored in \code{control$params$postprocessing} and passed to the post-processing engine.
#' @export
controller_postprocessing <- function(params = list()) {
  list(
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Evaluation Configuration ###
#--------------------------------------------------------------------
#' Controller: Evaluation Input Specification
#'
#' Generates a standardized input structure for evaluation engines used within the 
#' fairnessToolbox workflow. Supports both built-in and custom metrics that assess 
#' accuracy, fairness, or other user-defined aspects.
#'
#' Designed for use in the `control` object. This controller separates the protected 
#' attributes from metric-specific configuration, enabling flexible extensions.
#'
#' **Purpose:**
#' - Specifies which protected attributes should be considered in fairness evaluation.
#' - Defines engine-specific configurations for individual evaluation methods.
#'
#' **Automated Variable Handling:**
#' - `protected_name` is **automatically derived** from `control$vars$protected_vars_binary`.
#' - Users do **not need to set this manually**.
#' - This requires prior use of `controller_vars()` to define binary indicators for protected attributes.
#'
#' **Binary Attribute Requirement:**
#' - All attributes in `protected_name` must be **binary** (e.g., 0/1, TRUE/FALSE).
#' - Multi-class or continuous variables must be converted to binary before being passed into `protected_vars_binary`.
#' - Evaluation engines will throw an error or produce invalid results if this condition is not met.
#'
#' **Standardized Structure:**
#' - `protected_name`: *(autofilled)* Character vector of binary/grouped protected attributes.
#' - `params`: Named list of parameter lists, each keyed by evaluation engine name (e.g., `"eval_mse"`).
#'
#' **Usage Example:**
#' ```r
#' control$params$eval <- controller_evaluation(
#'   params = list(
#'     eval_mse = list(),
#'     eval_statisticalparity = list(threshold = 0.1)
#'   )
#' )
#' ```
#'
#' @param params Named list. Engine-specific configuration. Default is empty list. Each name corresponds to an evaluation engine; each value is a list of engine-specific parameters.
#'
#' @return Named list. To be stored in \code{control$params$eval} and passed to the evaluation engine(s). Compatible with all \code{fairnessToolbox} modules.
#' @export
controller_evaluation <- function(params = list()) {
  list(
    #protected_name = protected_name,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Reportelement Configuration (Multi-Instance Support) ###
#--------------------------------------------------------------------
#' Controller: Reportelement Input Specification
#'
#' Generates a standardized input structure for reportelement engines in the fairnessToolbox
#' workflow. Each element is independently configurable and mapped to a reporting alias.
#'
#' Designed for modular and extensible usage within the `control` object. Each alias allows
#' for distinct visualizations, tables, or summaries, depending on the reporting engine used.
#'
#' **Purpose:**
#' - Enables flexible configuration of multiple reportelements.
#' - Supports alias-based referencing to match user-specified reporting tasks.
#'
#' **Standardized Structure:**
#' - `params`: A named list of parameter lists. Each name must correspond to an alias specified
#'   in `control$engine_select$reportelement`, which in turn maps to a specific reportelement engine.
#'
#' **Usage Example:**
#' ```r
#' # Alias definitions (e.g. assigned engines)
#' control$engine_select$reportelement <- list(
#'   alias1 = "reportelement_table_splitmetrics",
#'   alias2 = "reportelement_boxplot_predictions"
#' )
#'
#' # Corresponding alias-specific parameter setup
#' control$params$reportelement <- controller_reportelement(
#'   params = list(
#'     alias1 = list(format = "wide"),
#'     alias2 = list(show_points = TRUE)
#'   )
#' )
#' ```
#'
#' @param params Named list. Engine-specific configuration. Default is empty list. Each name corresponds to a reportelement alias, and each value is a list of engine-specific parameters.
#'
#' @return Named list. To be stored in \code{control$params$reportelement} and passed to the reportelement engine(s). Compatible with all \code{fairnessToolbox} modules.
#' @export
controller_reportelement <- function(params = list()) {
  list(
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Report Configuration (Multi-Instance Support) ###
#--------------------------------------------------------------------
#' Controller: Report Input Specification
#'
#' Generates a standardized input structure for report engines in the fairnessToolbox
#' workflow. Each report is mapped to a reporting alias and can consist of one or more
#' reportelements.
#'
#' Designed to support multi-report generation, this structure allows distinct settings
#' for each report instance, enabling flexible and modular documentation or visualization
#' of results.
#'
#' **Purpose:**
#' - Supports the generation of multiple reports, each configurable via alias.
#' - Enables customized control of report layout, structure, and included content.
#'
#' **Standardized Structure:**
#' - `params`: A named list of parameter lists. Each name must match an alias specified in
#'   `control$engine_select$report`, which maps to a report engine.
#'
#' **Usage Example:**
#' ```r
#' # Alias definitions (e.g. assigned engines)
#' control$engine_select$report <- list(
#'   alias1 = "report_markdown",
#'   alias2 = "report_json_summary"
#' )
#'
#' # Corresponding alias-specific parameter setup
#' control$params$report <- controller_report(
#'   params = list(
#'     alias1 = list(title = "Model Summary", author = "Max"),
#'     alias2 = list(indent = 2)
#'   )
#' )
#' ```
#'
#' @param params Named list. Engine-specific configuration. Default is empty list. Each name corresponds to a report alias, and each value is a list of engine-specific parameters.
#'
#' @return Named list. To be stored in \code{control$params$report} and passed to the report engine(s). Compatible with all \code{fairnessToolbox} modules.
#' @export
controller_report <- function(params = list()) {
  list(
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Publishing Configuration (Multi-Instance Support) ###
#--------------------------------------------------------------------
#' Controller: Publish Input Specification
#'
#' Generates a standardized input structure for publishing engines in the fairnessToolbox
#' workflow. This includes both a global output folder and per-alias settings for how 
#' specific content (e.g., reports or reportelements) should be exported.
#'
#' Designed to support flexible export of results, including batch publishing of various
#' report formats (e.g., HTML, PDF, JSON) or custom targets (e.g., web endpoints, folders).
#'
#' **Purpose:**
#' - Enables modular export pipelines for reporting results.
#' - Decouples report/reportelement definitions from export configuration.
#'
#' **Standardized Structure:**
#' - `output_folder`: Root directory for all published files.
#' - `params`: A named list of configuration lists, each matching an alias in `control$engine_select$publish`.
#'
#' **Usage Example:**
#' ```r
#' # Alias definitions (mapped to export engines)
#' control$engine_select$publish <- list(
#'   html_summary = "publish_html",
#'   full_json = "publish_json"
#' )
#'
#' # Corresponding publishing configuration
#' control$params$publish <- controller_publish(
#'   output_folder = "results/exports/",
#'   params = list(
#'     html_summary = list(obj_type = "report", obj_name = "alias1"),
#'     full_json = list(obj_type = "reportelement", obj_name = "alias2")
#'   )
#' )
#' ```
#'
#' @param output_folder Character string. Global directory path to store all exports.
#' @param params Named list. Engine-specific configuration. Default is empty list. Each name should match a `control$engine_select$publish` alias, and contain a list of export parameters (`obj_type`, `obj_name`, etc.).
#'
#' @return Named list. To be stored in \code{control$params$publish} and passed to the publishing engine(s). Compatible with all \code{fairnessToolbox} modules.
#' @export
controller_publish <- function(output_folder = "~/publish_exports", 
                               params = list()) {
  list(
    output_folder = output_folder,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Resume Workflow After External Execution ###
#--------------------------------------------------------------------
#' Controller: Resume Input Specification
#'
#' Constructs a standardized resume object to re-enter the fairnessToolbox
#' workflow after external execution (e.g., SLURM-based batch processing).
#' The returned object is designed for direct use in `resume_fairness_workflow()`.
#'
#' **Purpose:**
#' - Allows decoupling of long-running execution from downstream workflow processing.
#' - Supports external infrastructures like HPC clusters or SLURM-based dispatch.
#'
#' **Standardized Structure:**
#' - `control`: The full original control object.
#' - `split_output`: The result object from the splitter engine.
#' - `execution_output`: Execution result, must contain `workflow_results`.
#'   This object is created via `initialize_output_execution()` inside this controller.
#'
#' **Usage Example:**
#' ```r
#' workflow_results <- readRDS("path/to/slurm_results.rds")
#' resume_object <- controller_resume_execution(
#'   control = control,
#'   split_output = split_output,
#'   workflow_results = workflow_results,
#'   metadata = list(slurm_job_id = "batch123")
#' )
#'
#' result <- resume_fairness_workflow(resume_object)
#' ```
#'
#' @param control The original control object used during the initial workflow configuration.
#' @param split_output A previously stored result object returned by the splitter engine.
#' @param workflow_results A named list of `run_workflow_single()` results, typically loaded from file.
#' @param metadata Optional. A named list of metadata to be stored in `specific_output` of the execution engine (e.g., runtime info, job ID).
#'
#' @return Named list. To be passed to \code{resume_fairness_workflow()} as input after external execution. Compatible with all \code{fairnessToolbox} modules.
#' @export
controller_resume_execution <- function(control, split_output, workflow_results, metadata = NULL) {
  list(
    control = control,
    split_output = split_output,
    execution_output = initialize_output_execution(
      execution_type = "external",
      workflow_results = workflow_results,
      params = NULL,
      specific_output = metadata,
      continue_workflow = TRUE
    )
  )
}
#--------------------------------------------------------------------