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
#' @return A named list to be stored in `control$vars`, compatible with all fairnessToolbox modules.
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
#' within the fairnessToolbox workflow. This controller ensures that the structure 
#' is compatible not only with built-in engines (e.g., random, stratified, CV) 
#' but also with any user-defined splitter engines.
#'
#' Designed for use in the construction of the `control` object. This function decouples 
#' engine-independent information (e.g., target variable, seed) from engine-specific parameters.
#'
#' **Purpose:**
#' - Provides a consistent and extensible input structure for all types of splitter engines.
#' - Facilitates modular extension of the framework by third-party or user-defined engines.
#'
#' **Standardized Structure:**
#' - `seed`: Random seed used for reproducibility across runs.
#' - `target_var`: The outcome variable, needed for stratified or CV-based splitting.
#' - `params`: A named list of additional splitter-specific hyperparameters (e.g., `split_ratio`, `cv_folds`).
#'
#' **Usage Example:**
#' ```r
#' control$params$split <- controller_split(
#'   seed = 42,
#'   target_var = "default",
#'   params = list(split_ratio = 0.7)
#' )
#' ```
#'
#' @param seed Optional integer for reproducibility. Default is `123`.
#' @param target_var Character. Name of the target variable used in splitting logic.
#' @param params Named list. Additional engine-specific parameters passed to the splitter.
#'
#' @return A named list to be stored under `control$split`, compatible with all splitter engines.
#' @export
#--------------------------------------------------------------------

controller_split <- function(seed = 123, target_var, params = list()) {
  list(
    seed = seed,
    target_var = target_var,
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
#' @param params Named list. Additional execution-specific parameters. Keys and values depend on the selected engine.
#'
#' @return A named list to be stored in `control$execution`, compatible with all execution engines.
#' @export
controller_execution <- function(method = "execution_sequential", params = list()) {
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
#' @param params Optional named list of training engine parameters (e.g., tuning values).
#'
#' @return A named list to be stored in `control$params$train`, compatible with all training engines.
#' @export
controller_training <- function(formula, norm_data = TRUE, params = NULL) {
  list(
    formula = formula,
    norm_data = norm_data,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Fairness Pre-Processing Configuration ###
#--------------------------------------------------------------------
#' Controller: Fairness Pre-Processing Specification
#'
#' Generates a standardized input structure for any fairness pre-processing engine 
#' used within the fairnessToolbox workflow. This controller ensures compatibility 
#' with built-in and user-defined engines for preprocessing protected attributes.
#'
#' Designed for use in the `control` object. Pre-processing can include bias mitigation 
#' steps such as reweighting, sampling, or transformation of features before model training.
#'
#' **Purpose:**
#' - Prepares all necessary inputs for fairness-aware preprocessing.
#' - Encapsulates relevant metadata such as protected attributes and outcome variables.
#'
#' **Standardized Structure:**
#' - `protected_attributes`: Character vector of protected attribute names.
#' - `target_var`: Character string. The target variable used in supervised learning.
#' - `params`: A named list of additional parameters passed to the pre-processing engine.
#'
#' **Usage Example:**
#' ```r
#' control$params$fairness_pre <- controller_fairness_pre(
#'   protected_attributes = c("gender"),
#'   target_var = "default",
#'   params = list(method = "DIR", repair_level = 0.5)
#' )
#' ```
#'
#' @param protected_attributes Character vector. Names of protected attributes to be considered.
#' @param target_var Character string. Name of the outcome variable.
#' @param params Optional named list of engine-specific parameters.
#'
#' @return A named list to be stored in `control$params$fairness_pre`, compatible with all pre-processing engines.
#' @export
controller_fairness_pre <- function(protected_attributes, target_var, params = NULL) {
  list(
    protected_attributes = protected_attributes,
    target_var = target_var,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Fairness In-Processing Configuration ###
#--------------------------------------------------------------------
#' Controller: Fairness In-Processing Specification
#'
#' Generates a standardized input structure for any fairness in-processing engine 
#' used within the fairnessToolbox workflow. This controller ensures compatibility 
#' with built-in and custom in-processing methods that modify models during training.
#'
#' Designed for use in the `control` object. In-processing methods can directly influence 
#' the learning algorithm, e.g., by adjusting loss functions, applying reweighting, or 
#' enforcing fairness constraints during optimization.
#'
#' **Purpose:**
#' - Prepares metadata and parameters required for in-processing engines.
#' - Supports optional normalization toggling at model level.
#'
#' **Standardized Structure:**
#' - `protected_attributes`: Character vector of protected attribute names.
#' - `target_var`: Character string. The outcome variable.
#' - `norm_data`: Logical. Whether normalized data should be used for model training.
#' - `params`: A named list of engine-specific parameters.
#'
#' **Usage Example:**
#' ```r
#' control$params$fairness_in <- controller_fairness_in(
#'   protected_attributes = c("gender"),
#'   target_var = "default",
#'   norm_data = TRUE,
#'   params = list(reweighting_method = "kamiran")
#' )
#' ```
#'
#' @param protected_attributes Character vector. Protected attributes used during in-processing.
#' @param target_var Character string. Target variable of the predictive task.
#' @param norm_data Logical. Use normalized data (`TRUE`) or raw data (`FALSE`) in training.
#' @param params Optional named list of engine-specific parameters.
#'
#' @return A named list to be stored in `control$params$fairness_in`, compatible with all in-processing engines.
#' @export
controller_fairness_in <- function(protected_attributes, target_var, norm_data = TRUE, params = NULL) {
  list(
    protected_attributes = protected_attributes,
    target_var = target_var,
    norm_data = norm_data,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Fairness Post-Processing Configuration ###
#--------------------------------------------------------------------
#' Controller: Fairness Post-Processing Specification
#'
#' Generates a standardized input structure for post-processing fairness methods 
#' used in the fairnessToolbox workflow. This controller supports any post-processing 
#' engine that adjusts predictions after model training (e.g., rejection options, thresholds).
#'
#' Designed for use in the `control` object. Post-processing techniques act on the 
#' model outputs and aim to correct unfairness without modifying the model itself.
#'
#' **Purpose:**
#' - Supplies protected group metadata and engine-specific configuration.
#' - Enables modular extension of fairness post-processing methods.
#'
#' **Standardized Structure:**
#' - `protected_name`: Character vector of protected attribute names (binary/grouped).
#' - `params`: Named list of additional engine-specific parameters.
#'
#' **Usage Example:**
#' ```r
#' control$params$fairness_post <- controller_fairness_post(
#'   protected_name = c("gender_male"),
#'   params = list(impact_reduction_factor = 0.5)
#' )
#' ```
#'
#' @param protected_name Character vector. Names of protected attributes in binary form used for evaluation and adjustment.
#' @param params Optional named list of engine-specific post-processing parameters.
#'
#' @return A named list to be stored in `control$params$fairness_post`, compatible with all post-processing engines.
#' @export
controller_fairness_post <- function(fairness_post_data, protected_name, params = NULL) {
  list(
    protected_name = protected_name,
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
#' - Specifies which protected attributes should be considered in fairness metrics.
#' - Defines engine-specific configurations for individual evaluation methods.
#'
#' **Standardized Structure:**
#' - `protected_name`: Character vector of protected attributes in binary/grouped form.
#' - `params`: Optional named list of parameter lists, each keyed by evaluation engine name.
#'
#' **Usage Example:**
#' ```r
#' control$params$eval <- controller_evaluation(
#'   protected_name = c("gender_male"),
#'   params = list(
#'     eval_mse = list(),
#'     eval_statisticalparity = list(group_reference = "female")
#'   )
#' )
#' ```
#'
#' @param protected_name Character vector. Names of protected attributes used in evaluation metrics.
#' @param params Optional named list. Each name corresponds to an evaluation engine; each value is a list of engine-specific parameters.
#'
#' @return A named list to be stored in `control$params$eval`, compatible with all evaluation engines.
#' @export
controller_evaluation <- function(protected_name, params = NULL) {
  list(
    protected_name = protected_name,
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
#'   in `control$reportelement`, which in turn maps to a specific reportelement engine.
#'
#' **Usage Example:**
#' ```r
#' # Alias definitions (e.g. assigned engines)
#' control$reportelement <- list(
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
#' @param params Optional named list. Each name corresponds to a reportelement alias, and each value is a list of engine-specific parameters.
#'
#' @return A named list to be stored in `control$params$reportelement`, compatible with all reportelement engines.
#' @export
controller_reportelement <- function(params = NULL) {
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
#'   `control$report`, which maps to a report engine.
#'
#' **Usage Example:**
#' ```r
#' # Alias definitions (e.g. assigned engines)
#' control$report <- list(
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
#' @param params Optional named list. Each name corresponds to a report alias, and each value is a list of engine-specific parameters.
#'
#' @return A named list to be stored in `control$params$report`, compatible with all report engines.
#' @export
controller_report <- function(params = NULL) {
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
#' - `params`: A named list of configuration lists, each matching an alias in `control$publish`.
#'
#' **Usage Example:**
#' ```r
#' # Alias definitions (mapped to export engines)
#' control$publish <- list(
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
#' @param params Named list. Each name should match a `control$publish` alias, and contain a list of export parameters (`obj_type`, `obj_name`, etc.).
#'
#' @return A named list to be stored in `control$params$publish`, compatible with all publishing engines.
#' @export
controller_publish <- function(output_folder = NULL, params = NULL) {
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
#' @return A standardized resume object for use in `resume_fairness_workflow()`.
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