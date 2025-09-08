# control_factories.R
# Define one or more control factories. Each returns a fully built control object.
# Signature must be: function(data, execution_type) -> control
# Only works for execution 'execution_basic_batchtools_multicore' and 'execution_basic_sequential'

#--------------------------------------------------------------------

# Create vars-object for all runs
vars_bank_classic <- controller_vars(
  feature_vars = c(
    # profession dummies
    "profession.Employee", "profession.Selfemployed", "profession.Unemployed",
    # marital_status dummies
    "marital_status.Divorced", "marital_status.Married", "marital_status.Single",
    # housing_status dummies
    "housing_status.Own", "housing_status.Rent", "housing_status.WithParents",
    # region dummies
    "region.Rural", "region.Suburban", "region.Urban",
    # numerical
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

#--------------------------------------------------------------------

control_runtime<- function(data, cv_folds = 5, execution_type = "execution_basic_sequential", train_type = "train_lm", 
                           preprocessing_switch = FALSE, inprocessing_switch = FALSE, postprocessing_switch = FALSE){
  list(
    settings = list(
      log = list(
        log_show = FALSE
      ),
      global_seed = 42L
    ),
    data = list(
      vars  = vars_bank_classic,
      full  = data,
      train = NULL,
      test  = NULL
    ),
    engine_select = list(
      split = "split_cv",
      execution = 
        if (execution_type == "execution_basic_batchtools_multicore"){"execution_basic_batchtools_multicore"}
      else {"execution_basic_sequential"}
      ,
      preprocessing =         
        if (preprocessing_switch == TRUE){"preprocessing_fairness_resampling"}
        else {NULL}
      ,
      train =
        if (train_type == "train_rf"){"train_rf"}
        else if (train_type == "train_glm"){"train_glm"}
        else {"train_lm"}
      ,
      inprocessing =         
        if (inprocessing_switch == TRUE & train_type == "train_glm"){"inprocessing_fairness_adversialdebiasing"}
      else {NULL}
      ,
      postprocessing =         
        if (postprocessing_switch == TRUE){"postprocessing_fairness_genresidual"}
      else {NULL}
    ),
    params = list(
      split = controller_split(
        seed = 42L,
        target_var = "default",
        params = list(cv_folds = cv_folds)
      ),
      execution = 
        if (execution_type == "execution_basic_batchtools_multicore"){controller_execution(
          params = list(
            registry_folder = "~/flowengineR/inst/runtime_benchmarks/2025-08-31_bank_runtime/outputs/BATCHTOOLS/bt_registry_basic_multicore",
            seed = 42,
            ncpus = parallel::detectCores(),
            required_packages = character(0)
          )
        )
        }
      else {controller_execution()}
      ,
      train = controller_training(
        formula = as.formula(paste(vars_bank_classic$target_var, "~ -1 +", 
                                   paste(vars_bank_classic$feature_vars, collapse = "+"), "+", 
                                   paste(vars_bank_classic$protected_vars, collapse = "+")
        )
        ),
        norm_data = TRUE,
        params = 
          if (train_type == "train_rf"){list(ntree = 100, mtry = 3)}
          else if (train_type == "train_glm"){list(family = binomial())}
          else {NULL}
      )
    )
  )
}

#--------------------------------------------------------------------
