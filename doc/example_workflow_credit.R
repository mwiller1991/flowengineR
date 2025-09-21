## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(flowengineR)

## -----------------------------------------------------------------------------
data <- test_data_2_base_credit_example

vars <- controller_vars(
  feature_vars = c(
    "profession.Employee", "profession.Selfemployed", "profession.Unemployed",
    "marital_status.Divorced", "marital_status.Married", "marital_status.Single",
    "housing_status.Own", "housing_status.Rent", "housing_status.WithParents",
    "region.Rural", "region.Suburban", "region.Urban",
    "employment_length", "credit_history_length", "number_prior_loans",
    "income", "loan_amount", "credit_score", "loan_to_income"
  ),
  protected_vars = c(
    "gender.Male", "gender.Female",
    "age"
  ),
  target_var = "default",
  protected_vars_binary = c(
    "gender.Male", "gender.Female",
    "age_group.<30", "age_group.30-50", "age_group.50+"
  )
)

## -----------------------------------------------------------------------------
control <- list(
  settings = list(
    log = list(log_show = TRUE, log_level = "info"),
    global_seed = 1,
    output_type = "response"
  ),
  data = list(
    vars = vars,
    full = data,
    train = NULL,
    test = NULL
  ),
  engine_select = list(
    split = "split_random_stratified",
    execution = "execution_adaptive_output_sequential",
    preprocessing = NULL,
    train = "train_glm",
    inprocessing = NULL,
    postprocessing = "postprocessing_fairness_genresidual",
    evaluation = list("eval_mse", "eval_summarystats", "eval_statisticalparity"),
    reportelement = list(
      gender_box_raw = "reportelement_boxplot_predictions",
      gender_box_adjusted = "reportelement_boxplot_predictions",
      age_box = "reportelement_boxplot_predictions",
      metrics_table = "reportelement_table_splitmetrics",
      text_mse_summary = "reportelement_text_msesummary"
    ),
    report = list(modelsummary = "report_modelsummary"),
    publish = list(
      pdf_basis_test_report = "publish_pdf_basis",
      pdf_basis_test_singleelement = "publish_pdf_basis",
      excel_basis_test_singleelement = "publish_excel_basis"
    )
  ),
  params = list(
    split = controller_split(
      seed = 123,
      params = list(split_ratio = 0.6)
    ),
    execution = controller_execution(
      params = list(
        metric_name = "mse",
        metric_source = "eval_mse",
        stability_strategy = "cohen_absolute",
        threshold = 0.2,
        window = 3,
        min_splits = 5,
        max_splits = 10
      )
    ),
    train = controller_training(
      formula = as.formula(paste(vars$target_var, "~", paste(vars$feature_vars, collapse = "+"), "+", paste(vars$protected_vars, collapse = "+"))),
      norm_data = TRUE
    ),
    inprocessing = controller_preprocessing(
      params = list(learning_rate = 0.1, num_epochs = 1000, num_adversary_steps = 10)
    ),
    evaluation = controller_evaluation(
      params = list(
        eval_mse = list(),
        eval_statisticalparity = list()
      )
    ),
    reportelement = controller_reportelement(
      params = list(
        gender_box_raw = list(group_var = "gender.Male", source = "train"),
        gender_box_adjusted = list(group_var = "gender.Male", source = "train"),
        age_box = list(group_var = "age_group.50+"),
        metrics_table = list(metrics = c("mse", "statisticalparity", "summarystats")),
        text_mse_summary = list()
      )
    ),
    report = controller_report(
      params = list(modelsummary = list(
        mse_text = "text_mse_summary",
        gender_box = "gender_box_adjusted",
        age_box = "age_box",
        metrics_table = "metrics_table"
      ))
    ),
    publish = controller_publish(
      output_folder = "~/publish_exports",
      params = list(
        pdf_basis_test_singleelement = list(obj_name = "text_mse_summary", obj_type = "reportelement"),
        pdf_basis_test_report = list(obj_name = "modelsummary", obj_type = "report"),
        excel_basis_test_singleelement = list(obj_name = "metrics_table", obj_type = "reportelement")
      )
    )
  )
)

## -----------------------------------------------------------------------------
result <- run_workflow(control)

## -----------------------------------------------------------------------------
# Aggregated metrics across all splits
result$aggregated_results

# Reportelement outputs
result$reportelements$metrics_table

# Published report file info
result$publishing

