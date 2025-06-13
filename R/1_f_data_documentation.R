#--------------------------------------------------------------------
### Example Dataset: Insurance ###
#--------------------------------------------------------------------
#' Example Dataset: Insurance Claim Costs (Wide Format)
#'
#' This synthetic dataset simulates claim cost prediction based on demographic and financial features.
#' It includes pre-encoded dummy variables and is designed to illustrate regression models and fairness-aware workflows.
#' All values are randomly generated for illustrative purposes and do not reflect real-world individuals or institutions.
#'
#' @format A data frame with 1000 observations and 10 variables:
#' \describe{
#'   \item{professionEmployee, professionSelfemployed}{Binary dummies for profession categories}
#'   \item{income}{Annual income in USD (numeric)}
#'   \item{genderFemale, genderMale}{Binary dummies for gender (0/1)}
#'   \item{age}{Age in years (integer)}
#'   \item{damage}{Reported claim damage amount (numeric; target variable)}
#'   \item{age_group.<40, age_group.40-60, age_group.60+}{Binary age group indicators}
#' }
#'
#' @usage data(test_data_1_base_insurance_example)
#'
#' @examples
#' data(test_data_1_base_insurance_example)
#' head(test_data_1_base_insurance_example)
#'
#' # Example variable setup
#' vars <- controller_vars(
#'   target_var = "damage",
#'   protected_vars = c("genderFemale", "genderMale", "age"),
#'   feature_vars = c(
#'     "professionEmployee", "professionSelfemployed", "income"
#'   ),
#'   protected_vars_binary = c("genderFemale", "genderMale", "age_group.<40", 
#'     "age_group.40-60", "age_group.60+"
#'   )
#' )
"test_data_1_base_insurance_example"
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Example Dataset: Credit Default ###
#--------------------------------------------------------------------
#' Example Dataset: Credit Default Simulation (Wide Format)
#'
#' This synthetic dataset simulates the prediction of loan default risk based on demographic and financial indicators.
#' It includes preprocessed dummy variables suitable for fairness-aware model evaluation.
#' All values are artificially generated and do not represent real people or financial data.
#'
#' @format A data frame with 1000 observations and 16 variables:
#' \describe{
#'   \item{professionEmployee, professionSelfemployed, professionUnemployed}{Binary dummies for profession status}
#'   \item{income, loan_amount, credit_score}{Financial attributes (numeric)}
#'   \item{age}{Age in years (integer)}
#'   \item{genderFemale, genderMale}{Binary dummies for gender}
#'   \item{marital_statusDivorced, marital_statusMarried, marital_statusSingle}{Marital status dummies}
#'   \item{default}{Binary indicator for default (0 = no default, 1 = default; target variable)}
#'   \item{age_group.<30, age_group.30-50, age_group.50+}{Binary age group indicators}
#' }
#'
#' @usage data(test_data_2_base_credit_example)
#'
#' @examples
#' data(test_data_2_base_credit_example)
#' head(test_data_2_base_credit_example)
#'
#' # Example variable setup
#' vars <- controller_vars(
#'     feature_vars = c("income", "loan_amount", "credit_score", "professionEmployee",
#'       "professionSelfemployed", "professionUnemployed"),
#'     protected_vars = c("genderFemale", "genderMale", "age", "marital_statusDivorced", 
#'       "marital_statusMarried", "marital_statusSingle"
#'      ),
#'     target_var = "default",
#'     protected_vars_binary = c("genderFemale", "genderMale", "age_group.<30",
#'       "age_group.30-50", "age_group.50+", "marital_statusDivorced", 
#'       "marital_statusMarried", "marital_statusSingle"
#'      )
#' )
"test_data_2_base_credit_example"
#--------------------------------------------------------------------