# -------------------------------------------------------------------
# Workflow Demo: Eval Median Engine
# -------------------------------------------------------------------
# This script demonstrates how the new engine is created and 
# how the newly created engine_eval_median can be registered 
# and executed within a minimal workflow.
#
# Folder: inst/llm_demonstrations/2025-08-29_eval_median/
# -------------------------------------------------------------------

# 1) Load package
library(flowengineR)


# 2) Use the LLM Builder
build_engine_with_llm_zip("eval","The Median of all predictions.", zip_path = NULL)


# 3) Register the engine (already validated)
engine_file <- system.file(
  "llm_demonstrations", 
  "2025-08-27_eval_median", 
  "outputs", 
  "engine_eval_median.R", 
  package = "flowengineR"
)
register_engine("eval_median", engine_file)


# 4) Prepare base control set
vars = controller_vars(
  feature_vars = c("income", "loan_amount", "credit_score", "professionEmployee", "professionSelfemployed", "professionUnemployed"),
  protected_vars = c("genderFemale", "genderMale", "age"),
  target_var = "default",                 
  protected_vars_binary = c("genderFemale", "genderMale", "age_group.<30", "age_group.30-50", "age_group.50+")      
)

control <- list(
  settings = list(
    log = list(
      log_show = TRUE,
      log_level = "info"
    ),
    global_seed = 1  ),
  data = list(
    vars = controller_vars(
      feature_vars = c("income", "loan_amount", "credit_score", "professionEmployee", "professionSelfemployed", "professionUnemployed"), 
      protected_vars = c("genderFemale", "genderMale", "age"),       
      target_var = "default",                        
      protected_vars_binary = c("genderFemale", "genderMale", "age_group.<30", "age_group.30-50", "age_group.50+")     
    ),
    full = flowengineR::test_data_2_base_credit_example,
    train = NULL,
    test = NULL
  ),
  engine_select = list(
    evaluation = list("eval_median")
  ),
  params = list(
    evaluation = controller_evaluation()
  )
)


# 5) Run Workflow
results <- run_workflow(control)

# 6) Evaluate Results
median_calculated_by_engine <- results$execution_output$workflow_results$random_stratified$output_eval$eval_median$metrics$median_prediction
median_calculated_by_engine


# 7) Check for plausibility
predictions <- results$execution_output$workflow_results$random_stratified$output_train$predictions
median_calculated_manually <- stats::median(predictions)
median_calculated_manually

identical(median_calculated_by_engine, median_calculated_manually)

