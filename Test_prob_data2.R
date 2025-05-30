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

# Load the data
source("~/fairness_toolbox/data/data_generation.R")

# Load the memory-size-logger
source("~/fairness_toolbox/tests/memory_logging_dev.R")

# Load the slurm-tester
source("~/fairness_toolbox/tests/SLURM/slurm_testinR/simulate_slurm_run.R")

# Generate the dataset
dataset <- create_dataset_2(seed = 1)

#Setting variables fitting to the dataset
vars = controller_vars(
  feature_vars = c("income", "loan_amount", "credit_score", "professionEmployee", "professionSelfemployed", "professionUnemployed"),  # All non-protected variables
  protected_vars = c("genderFemale", "genderMale", "age"),            # Protected variables
  target_var = "default",                            # Target variable
  protected_vars_binary = c("genderFemale", "genderMale", "age_group.<30", "age_group.30-50", "age_group.50+")            # Protected variables for evaluations (in groups)
)

# Control Object for Prototyping
control <- list(
  global_seed = 1,
  vars = vars,         # Include vars within control for consistency
  data = list(
    full = dataset,    # Optional, if splitter engine is used
    train = NULL,      # Training data
    test = NULL        # Test data
  ),
  split_method = "split_random_stratified",   # Method for splitting (e.g., "split_random" or "split_cv" or "split_random_stratified")
  execution = "execution_adaptive_output_batchtools_multicore", #execution_sequential #execution_adaptive_sequential_stability
  train_model = "train_lm",
  output_type = "response", # Add option for output type ("response" or "prob") depends on model (GLM/LM do not support prob)
  fairness_pre = NULL, #"fairness_pre_resampling",
  fairness_in = NULL, #"fairness_in_adversialdebiasing",
  fairness_post = "fairness_post_genresidual",
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
  ),
  params = list(
    split = controller_split(
      seed = 123,
      target_var = vars$target_var,
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
    fairness_pre = controller_fairness_pre(
      protected_attributes = vars$protected_vars,
      target_var = vars$target_var,
      params =   list(
        method = "undersampling"
      )
    ),
    train = controller_training(
      formula = as.formula(paste(vars$target_var, "~", paste(vars$feature_vars, collapse = "+"), "+", paste(vars$protected_vars, collapse = "+"))),
      norm_data = TRUE
    ),
    fairness_in = controller_fairness_in(
      protected_attributes = vars$protected_vars,
      target_var = vars$target_var,
      params =   list(
        learning_rate = 0.1,
        num_epochs = 1000,
        num_adversary_steps = 10
      )
    ),
    fairness_post = controller_fairness_post(
      protected_name = vars$protected_vars_binary
    ),
    eval = controller_evaluation(
      protected_name = vars$protected_vars_binary,
      params = list(
        eval_mse = list(weighting_factor = 0.5), #Example for Test
        eval_statisticalparity = list(threshold = 0.1) #Example for Test
      )
    ),
    reportelement = controller_reportelement(
      params = list(
        gender_box_raw = list(group_var = "genderMale", source = "train"),
        gender_box_adjusted = list(group_var = "genderMale", source = "post"),
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
      output_folder = "~/fairness_toolbox/tests/publish_exports", 
      params = list(
        pdf_basis_test_singleelement = list(obj_name = "text_mse_summary", obj_type = "reportelement"),
        pdf_basis_test_report = list(obj_name = "modelsummary", obj_type = "report"),
        excel_basis_test_singleelement = list(obj_name = "metrics_table", obj_type = "reportelement")
      )
    )
  )
)


# Run the Workflow
result <- fairness_workflow(control)

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
