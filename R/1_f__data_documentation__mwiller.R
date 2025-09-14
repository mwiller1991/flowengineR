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
#' This synthetic dataset simulates the prediction of loan default risk based on
#' demographic and financial indicators. It was generated with
#' [create_dataset_bank()], which encodes realistic dependencies between income,
#' profession, region, age, and credit history. The dataset includes preprocessed
#' dummy variables suitable for fairness-aware model evaluation.
#' All values are artificially generated and do not represent real people or
#' financial data.
#'
#' @format A data frame with 2000 observations and multiple variables:
#' \describe{
#'   \item{profession.Employee, profession.Selfemployed, profession.Unemployed}{Binary dummies for profession status}
#'   \item{marital_status.Divorced, marital_status.Married, marital_status.Single}{Marital status dummies}
#'   \item{housing_status.Own, housing_status.Rent, housing_status.WithParents}{Housing status dummies}
#'   \item{region.Rural, region.Suburban, region.Urban}{Region dummies}
#'   \item{gender.Male, gender.Female}{Binary dummies for gender}
#'   \item{age}{Age in years (integer)}
#'   \item{employment_length, credit_history_length, number_prior_loans}{Employment and credit history indicators}
#'   \item{income, loan_amount, credit_score, loan_to_income}{Financial attributes (numeric)}
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
#'   feature_vars = c(
#'     "profession.Employee", "profession.Selfemployed", "profession.Unemployed",
#'     "marital_status.Divorced", "marital_status.Married", "marital_status.Single",
#'     "housing_status.Own", "housing_status.Rent", "housing_status.WithParents",
#'     "region.Rural", "region.Suburban", "region.Urban",
#'     "employment_length", "credit_history_length", "number_prior_loans",
#'     "income", "loan_amount", "credit_score", "loan_to_income"
#'   ),
#'   protected_vars = c("gender.Male", "gender.Female", "age"),
#'   target_var = "default",
#'   protected_vars_binary = c(
#'     "gender.Male", "gender.Female",
#'     "age_group.<30", "age_group.30-50", "age_group.50+"
#'   )
#' )
"test_data_2_base_credit_example"
#--------------------------------------------------------------------