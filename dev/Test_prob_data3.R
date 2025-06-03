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
  engine_select = list(
    split = "split_random_stratified",   # Method for splitting (e.g., "split_random" or "split_cv" or "split_random_stratified")
    execution = "execution_basic_sequential", #execution_sequential #execution_adaptive_sequential_stability
    preprocessing = NULL, #"preprocessing_fairness_resampling",
    train = "train_lm",
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

result <- run_workflow(control)

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