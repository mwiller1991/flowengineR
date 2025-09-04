# control_factories.R
# Define one or more control factories. Each returns a fully built control object.
# Signature must be: function(data, vars) -> control

# Create vars-object for all runs
vars_bank_classic <- controller_vars(
  feature_vars = c(
    # profession dummies
    "professionEmployee", "professionSelfemployed", "professionUnemployed",
    # marital_status dummies
    "marital_statusDivorced", "marital_statusMarried", "marital_statusSingle",
    # housing_status dummies
    "housing_statusOwn", "housing_statusRent", "housing_statusWithParents",
    # region dummies
    "regionRural", "regionSuburban", "regionUrban",
    # numerical
    "employment_length", "credit_history_length", "number_prior_loans",
    "income", "loan_amount", "credit_score", "loan_to_income"
  ),
  protected_vars = c(
    "genderMale", "genderFemale",
    "age"
  ),
  target_var = "default",
  protected_vars_binary = c(
    "genderMale", "genderFemale",
    "age_group.<30", "age_group.30-50", "age_group.50+"
  )
)


# Example A1: Base GLM, 5-fold CV
control_runtime_seq_glm_base <- function(data, execution_type){
  list(
    settings = list(
      log = list(
        log_show = TRUE,
        log_level = "warn"
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
        if (execution_type == "multicore"){"execution_basic_batchtools_multicore"}
        else {"execution_basic_sequential"}
      ,
      train = "train_glm"
      ),
    params = list(
      split = controller_split(
        seed = 42L,
        target_var = "default",
        params = list(cv_folds = 5)
        ),
      execution = 
        if (execution_type == "multicore"){controller_execution(
              params = list(
                registry_folder = "~/flowengineR/inst/runtime_benchmarks/2025-08-31_bank_runtime/outputs/BATCHTOOLS/bt_registry_basic_multicore/test_b2",
                seed = 42,
                ncpus = 4,
                required_packages = character(0)
              )
            )
          }
        else {controller_execution()}
      ,
      train = controller_training(
        formula = as.formula(paste(vars_bank_classic$target_var, "~", 
                                   paste(vars_bank_classic$feature_vars, collapse = "+"), "+", 
                                   paste(vars_bank_classic$protected_vars, collapse = "+")
                                   )
                             ),
        norm_data = TRUE,
        params = list(family = gaussian())
        )
      )
    )
}


# Example B1: Base GLM, 5-fold CV
control_runtime_mc_glm_base <- function(data){
  list(
    settings = list(
      log = list(
        log_show = TRUE,
        log_level = "warn"
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
      execution = "execution_basic_batchtools_multicore",
      train = "train_glm"
    ),
    params = list(
      split = controller_split(
        seed = 42L,
        target_var = "default",
        params = list(cv_folds = 5)
      ),
      execution = controller_execution(
        params = list(
          registry_folder = "~/flowengineR/inst/runtime_benchmarks/2025-08-31_bank_runtime/outputs/BATCHTOOLS/bt_registry_basic_multicore/test1", # Target registry folder
          seed = 42,                   # Seed for reproducibility
          ncpus = 4,                   # Number of CPU cores to use in parallel
          required_packages = character(0)  # Add required packages here, e.g., c("ggplot2", "caret")
        )
      ),
      train = controller_training(
        formula = as.formula(paste(vars_bank_classic$target_var, "~", 
                                   paste(vars_bank_classic$feature_vars, collapse = "+"), "+", 
                                   paste(vars_bank_classic$protected_vars, collapse = "+")
        )
        ),
        norm_data = TRUE,
        params = list(family = gaussian())
      )
    )
  )
}


# Register which factories to run (order matters)
CONTROL_FACTORIES <- list(
  lm_cv5 = control_lm_cv5, 
  rf_cv5 = control_rf_cv5
)
