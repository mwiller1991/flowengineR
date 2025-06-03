# install required libraries
install.packages("tinytex")
tinytex::install_tinytex()

# Load required libraries
library(ggplot2)
library(caret)
library(magrittr)
library(moments)
library(dplyr)
library(rmarkdown)
library(openxlsx)
library(batchtools)
library(devtools)
library(utils)

# Load the Controller Functions
source("~/fairness_toolbox/R/metalevel/metalevel.R")

# Load the helper Functions
source("~/fairness_toolbox/R/metalevel/helper.R")
source("~/fairness_toolbox/R/engines/2_execution/helper_execution_resume.R")
source("~/fairness_toolbox/R/engines/2_execution/helper_execution_stability_checks.R")

# Load the initiate output Functions
source("~/fairness_toolbox/R/engines/1_split/initialize_output_split.R")
source("~/fairness_toolbox/R/engines/2_execution/initialize_output_execution.R")
source("~/fairness_toolbox/R/engines/3_training/initialize_output_train.R")
source("~/fairness_toolbox/R/engines/4_fairness/4_1_pre-processing/initialize_output_fairness_pre.R")
source("~/fairness_toolbox/R/engines/4_fairness/4_2_in-processing/initialize_output_fairness_in.R")
source("~/fairness_toolbox/R/engines/4_fairness/4_3_post-processing/initialize_output_fairness_post.R")
source("~/fairness_toolbox/R/engines/5_evaluation/initialize_output_eval.R")
source("~/fairness_toolbox/R/engines/6_reporting/6_1_reportelement/initialize_output_reportelement.R")
source("~/fairness_toolbox/R/engines/6_reporting/6_2_report/initialize_output_report.R")
source("~/fairness_toolbox/R/engines/6_reporting/6_3_publish/initialize_output_publish.R")

# Load the Controller Functions
source("~/fairness_toolbox/R/controller/controller_1_inputR.R")

# Load the Engine Registry
source("~/fairness_toolbox/R/metalevel/registry.R")
source("~/fairness_toolbox/R/metalevel/subregistry_validate_engines.R")

#--------------------------------------------------------------------
### load preinstalled package-engines ###
#--------------------------------------------------------------------

# Load preinstalled Splitter-Engines
register_engine("split_userdefined", "~/fairness_toolbox/R/engines/1_split/engine_split_userdefined.R")
register_engine("split_random", "~/fairness_toolbox/R/engines/1_split/engine_split_random.R")
register_engine("split_random_stratified", "~/fairness_toolbox/R/engines/1_split/engine_split_random_stratified.R")
register_engine("split_cv", "~/fairness_toolbox/R/engines/1_split/engine_split_cv.R")

# Load preinstalled execution-Engines
register_engine("execution_basic_sequential", "~/fairness_toolbox/R/engines/2_execution/2_1_basic/engine_execution_basic_sequential.R")
register_engine("execution_basic_slurm_array", "~/fairness_toolbox/R/engines/2_execution/2_1_basic/engine_execution_basic_slurm_array.R")
register_engine("execution_basic_batchtools_local", "~/fairness_toolbox/R/engines/2_execution/2_1_basic/engine_execution_basic_batchtools_local.R")
register_engine("execution_basic_batchtools_multicore", "~/fairness_toolbox/R/engines/2_execution/2_1_basic/engine_execution_basic_batchtools_multicore.R")
register_engine("execution_adaptive_output_sequential", "~/fairness_toolbox/R/engines/2_execution/2_2_adaptive_output/engine_execution_adaptive_output_sequential.R")
register_engine("execution_adaptive_output_batchtools_multicore", "~/fairness_toolbox/R/engines/2_execution/2_2_adaptive_output/engine_execution_adaptive_output_batchtools_multicore.R")
register_engine("execution_adaptive_output_batchtools_slurm", "~/fairness_toolbox/R/engines/2_execution/2_2_adaptive_output/engine_execution_adaptive_output_batchtools_slurm.R")
register_engine("execution_adaptive_input_scalar_sequential", "~/fairness_toolbox/R/engines/2_execution/2_3_adaptive_input/engine_execution_adaptive_input_scalar_sequential.R")

# Load preinstalled Train-Engines 
register_engine("train_lm", "~/fairness_toolbox/R/engines/3_training/engine_train_lm.R")
register_engine("train_glm", "~/fairness_toolbox/R/engines/3_training/engine_train_glm.R")

# Load preinstalled Fairness-Engines 
register_engine("fairness_pre_resampling", "~/fairness_toolbox/R/engines/4_fairness/4_1_pre-processing/engine_fairness_pre_resampling.R")
register_engine("fairness_in_adversialdebiasing", "~/fairness_toolbox/R/engines/4_fairness/4_2_in-processing/engine_fairness_in_adversialdebiasing.R")
register_engine("fairness_post_genresidual", "~/fairness_toolbox/R/engines/4_fairness/4_3_post-processing/engine_fairness_post_genresidual.R")

# Load preinstalled Evaluation-Engines
register_engine("eval_summarystats", "~/fairness_toolbox/R/engines/5_evaluation/5_1_general/engine_eval_summarystats.R")
register_engine("eval_mse", "~/fairness_toolbox/R/engines/5_evaluation/5_2_precision/engine_eval_mse.R")
register_engine("eval_statisticalparity", "~/fairness_toolbox/R/engines/5_evaluation/5_3_fairness/engine_eval_statisticalparity.R")

# Load preinstalled Reportelement-Engines
register_engine("reportelement_table_splitmetrics", "~/fairness_toolbox/R/engines/6_reporting/6_1_reportelement/engine_reportelement_table_splitmetrics.R")
register_engine("reportelement_boxplot_predictions", "~/fairness_toolbox/R/engines/6_reporting/6_1_reportelement/engine_reportelement_boxplot_predictions.R")
register_engine("reportelement_text_msesummary", "~/fairness_toolbox/R/engines/6_reporting/6_1_reportelement/engine_reportelement_text_msesummary.R")

# Load preinstalled Report-Engines
register_engine("report_modelsummary", "~/fairness_toolbox/R/engines/6_reporting/6_2_report/engine_report_modelsummary.R")

# Load preinstalled Publish-Engines
register_engine("publish_pdf_basis", "~/fairness_toolbox/R/engines/6_reporting/6_3_publish/engine_publish_pdf_basis.R")
register_engine("publish_excel_basis", "~/fairness_toolbox/R/engines/6_reporting/6_3_publish/engine_publish_excel_basis.R")

# Debugging: List registered engines
print(names(engines))
#--------------------------------------------------------------------

# Load the data
source("~/fairness_toolbox_dev/data_generation.R")

# Load the memory-size-logger
source("~/fairness_toolbox/dev/memory_logging_dev.R")

# Load the slurm-tester
source("~/fairness_toolbox/tests/SLURM/slurm_testinR/simulate_slurm_run.R")

# Generate the dataset
dataset <- fairnessToolbox::test_data_2_base_credit_example

#Setting variables fitting to the dataset
vars = controller_vars(
  feature_vars = c("income", "loan_amount", "credit_score", "professionEmployee", "professionSelfemployed", "professionUnemployed"),  # All non-protected variables
  protected_vars = c("genderFemale", "genderMale", "age"),            # Protected variables
  target_var = "default",                            # Target variable
  protected_vars_binary = c("genderFemale", "genderMale", "age_group.<30", "age_group.30-50", "age_group.50+")            # Protected variables for evaluations (in groups)
)

# Control Object for Prototyping
control <- list(
  settings = list(
    log = TRUE,
    log_level = "info"
  ),
  global_seed = 1,
  output_type = "response", # Add option for output type ("response" or "prob") depends on model (GLM/LM do not support prob)
  data = list(
    vars = controller_vars(
      feature_vars = c("income", "loan_amount", "credit_score", "professionEmployee", "professionSelfemployed", "professionUnemployed"),  # All non-protected variables
      protected_vars = c("genderFemale", "genderMale", "age"),            # Protected variables
      target_var = "default",                            # Target variable
      protected_vars_binary = c("genderFemale", "genderMale", "age_group.<30", "age_group.30-50", "age_group.50+")            # Protected variables for evaluations (in groups)
    ),
    full = fairnessToolbox::test_data_2_base_credit_example,    # Optional, if splitter engine is used
    train = NULL,      # Training data
    test = NULL        # Test data
  ),
  engines <-list(
    split = "split_random_stratified",   # Method for splitting (e.g., "split_random" or "split_cv" or "split_random_stratified")
    execution = "execution_basic_sequential", #execution_sequential #execution_adaptive_sequential_stability
    train = "train_lm",
    preprocessing = NULL, #"preprocessing_fairness_resampling",
    inprocessing = "inprocessing_fairness_adversialdebiasing",
    postprocessing = NULL, #"postprocessing_fairness_genresidual",
    evaluation = list("eval_mse", "eval_summarystats", "eval_statisticalparity"), #list("eval_summarystats", "eval_mse", "eval_statisticalparity")
    reportelement = list(
      gender_box_raw = "reportelement_boxplot_predictions",
      gender_box_adjusted = "reportelement_boxplot_predictions",
      age_box = "reportelement_boxplot_predictions",
      metrics_table = "reportelement_table_splitmetrics",
      text_mse_summary = "reportelement_text_msesummary"
    ),
    report = list(
      modelsummary = "report_modelsummary"
    ),
    publish = list(
      pdf_basis_test_report = "publish_pdf_basis",
      pdf_basis_test_singleelement = "publish_pdf_basis",
      excel_basis_test_singleelement = "publish_excel_basis"
    )
  ),
  params = list(
    split = controller_split(
      seed = 123,
      params =   list(split_ratio = 0.6,
                      cv_folds = 5
      )
    ),
    execution = controller_execution(
      params =   list(
        metric_name = "mse",
        metric_source = "eval_mse",
        stability_strategy = "cohen_absolute",
        threshold = 0.2,
        window = 3,
        min_splits = 5,
        max_splits = 50
      )
    ),
    preprocessing = controller_preprocessing(
      params =   list(
        method = "undersampling"
      )
    ),
    train = controller_training(
      formula = as.formula(paste(vars$target_var, "~", paste(vars$feature_vars, collapse = "+"), "+", paste(vars$protected_vars, collapse = "+"))),
      norm_data = TRUE
    ),
    inprocessing = controller_preprocessing(
      params =   list(
        learning_rate = 0.1,
        num_epochs = 1000,
        num_adversary_steps = 10
      )
    ),
    postprocessing = controller_postprocessing(
    ),
    eval = controller_evaluation(
      params = list(
        eval_mse = list(weighting_factor = 0.5), #Example for Test
        eval_statisticalparity = list(threshold = 0.1) #Example for Test
      )
    ),
    reportelement = controller_reportelement(
      params = list(
        gender_box_raw = list(group_var = "genderMale", source = "train"),
        gender_box_adjusted = list(group_var = "genderMale", source = "train"),
        age_box = list(group_var = "age_group.50+"),
        metrics_table = list(metrics = c("mse", "statisticalparity", "summarystats")),
        text_mse_summary = list()
      )
    ),
    report = controller_report(
      params = list(
        modelsummary = list(mse_text = "text_mse_summary", gender_box = "gender_box_adjusted", age_box = "age_box", metrics_table = "metrics_table")
      )
    ),
    publish = controller_publish(
      output_folder = "~/flowengineR/tests/publish_exports", 
      params = list(
        pdf_basis_test_singleelement = list(obj_name = "text_mse_summary", obj_type = "reportelement"),
        pdf_basis_test_report = list(obj_name = "modelsummary", obj_type = "report"),
        excel_basis_test_singleelement = list(obj_name = "metrics_table", obj_type = "reportelement")
      )
    )
  )
)


# Control Object for Prototyping
control <- list(
  settings = list(
    log = TRUE,
    log_level = "info"
  ),
  train = "train_lm",
  postprocessing = "postprecessing_fairness_genresidual",
  eval = c("eval_statisticalparity", "eval_mse"),
  params = list(
    train = controller_training(
      formula = default ~ income + loan_amount,
      norm_data = TRUE
    ),
    postprocessing = controller_postprocessing(),
    eval = controller_evaluation()
  )
)

# Control Object for Prototyping
control <- list(
  settings =list(
  log = TRUE,             # (optional) grober Schalter an/aus
  log_level = "info"      # "none", "info", "debug", "warn"
),
  global_seed = 1
)


# Run the Workflow
result <- run_workflow(control)

simulate_slurm_run(
  control_path = "~/fairness_toolbox/tests/SLURM/slurm_inputs/control_base.rds",
  split_output_path = "~/fairness_toolbox/tests/SLURM/slurm_inputs/split_output.rds",
  result_dir = "~/fairness_toolbox/tests/SLURM/slurm_outputs"
  )

resume_object <- prepare_resume_from_slurm_array(
                    control_path = "~/fairness_toolbox/tests/SLURM/slurm_inputs/control_base.rds",
                    split_output_path = "~/fairness_toolbox/tests/SLURM/slurm_inputs/split_output.rds",
                    result_dir = "~/fairness_toolbox/tests/SLURM/slurm_outputs",
                    metadata = list(engine = "SLURM_ARRAY", timestamp = Sys.time())
                  )
  
result <- resume_fairness_workflow(resume_object)


result$reportelements$metrics_table$content
result$reportelements$gender_box_raw$content
result$reportelements$mse_text$content
View(result$reportelements$metrics_table$content)

result_full <- fairness_workflow_variants(control)
