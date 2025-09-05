#' Create a realistic synthetic banking dataset
#'
#' @description
#' Generates a credit risk dataset with plausible dependencies between features:
#' income depends on profession/region/age; loan_amount depends on income;
#' credit_score depends on income/age/credit history; default is driven by
#' loan-to-income, credit_score, employment/housing stability, marital_status, etc.
#'
#' @param n Integer. Number of customers (rows).
#' @param seed Integer. RNG seed for reproducibility.
#' @param onehot Logical. If TRUE, returns one-hot encoded data via caret::dummyVars().
#' @param pos_rate Numeric in (0,1). Target base default rate (approximate).
#' @return data.frame with features, derived variables, and binary target `default` (0/1).
#' @examples d <- create_dataset_bank(n = 2000, seed = 1)
#' @importFrom stats rnorm rbinom runif plogis
#' @export
create_dataset_bank <- function(n = 10000, seed = 123, onehot = TRUE, pos_rate = 0.05){ 
set.seed(seed)
  
  # --- Categorical drivers (base distributions) ---
  profession <- sample(c("Employee", "Selfemployed", "Unemployed"), n, TRUE,
                       prob = c(0.7, 0.18, 0.12))
  gender <- sample(c("Male", "Female"), n, TRUE, prob = c(0.52, 0.48))
  marital_status <- sample(c("Single", "Married", "Divorced"), n, TRUE,
                           prob = c(0.4, 0.5, 0.1))
  housing_status <- sample(c("Own", "Rent", "WithParents"), n, TRUE,
                           prob = c(0.45, 0.45, 0.10))
  region <- sample(c("Urban", "Suburban", "Rural"), n, TRUE,
                   prob = c(0.45, 0.35, 0.20))
  
  # --- Age & employment length ---
  # Age: slightly skewed towards working ages; cap to 18..75
  age <- pmin(75, pmax(18, round(stats::rnorm(n, mean = 42, sd = 12))))
  # Employment length: bounded by age-16, depends on profession (self-employed: longer var)
  max_emp <- pmax(0, age - 16)
  employment_length <- pmax(
    0,
    round(
      0.35 * max_emp +
        ifelse(profession == "Employee", 3, ifelse(profession == "Selfemployed", 6, 1)) +
        stats::rnorm(n, 0, 3)
    )
  )
  employment_length <- pmin(employment_length, max_emp)
  
  # --- Credit history length & prior loans ---
  credit_history_length <- pmax(
    0,
    round(0.6 * max_emp + stats::rnorm(n, 0, 4))
  )
  number_prior_loans <- pmax(
    0,
    round(0.1 * credit_history_length + ifelse(region == "Urban", 1, 0) + stats::rnorm(n, 0, 1.2))
  )
  
  # --- Income: depends on profession, region, age ---
  base_income <-
    ifelse(profession == "Employee",     38000,
           ifelse(profession == "Selfemployed", 52000,
                  18000))
  reg_addon <- ifelse(region == "Urban",  4000,
                      ifelse(region == "Rural", -2000, 0))
  age_effect <- 350 * pmax(0, age - 22) / 20  # plateauing after ~42
  income <- stats::rnorm(n, mean = base_income + reg_addon + age_effect, sd = 9000)
  income <- pmax(6000, round(income))  # floor income at a realistic minimum
  
  # --- Loan amount: scales with income + noise; slightly higher for homeowners (bigger loans) ---
  loan_amount_mean <- 0.55 * income +
    ifelse(housing_status == "Own", 5000, ifelse(housing_status == "Rent", 0, -2000))
  loan_amount <- stats::rnorm(n, mean = loan_amount_mean, sd = 8000)
  loan_amount <- pmax(1000, round(loan_amount))
  
  # --- Credit score: higher with income/age/history; penalties for instability ---
  credit_score_mean <-
    600 +
    0.0022 * income +
    0.6 * age +
    0.8 * credit_history_length +
    ifelse(profession == "Unemployed", -60, 0) +
    ifelse(housing_status == "Own", 20, ifelse(housing_status == "WithParents", -10, 0)) +
    stats::rnorm(n, 0, 35)
  credit_score <- round(pmin(850, pmax(300, credit_score_mean)))
  
  # --- Derived ratios ---
  loan_to_income <- loan_amount / pmax(1, income)
  
  # --- Default probability (logistic): tune intercept to hit pos_rate approximately) ---
  # Drivers: high LTI, low score, unemployment, divorced, renters, short history, many prior loans
  linpred <-
    -7.5 +                                        # base intercept (adjusted below)
    2.2 * loan_to_income +
    (-0.012) * credit_score +
    (-0.00002) * income +
    0.03 * pmax(0, 10 - employment_length) +
    0.02 * pmax(0, 8 - credit_history_length) +
    0.08 * number_prior_loans +
    ifelse(profession == "Unemployed", 0.9, 0) +
    ifelse(marital_status == "Divorced", 0.35, 0) +
    ifelse(housing_status == "Rent", 0.25, 0) +
    stats::rnorm(n, 0, 0.25)
  
  # Calibrate intercept via simple shift to match target pos_rate
  eps <- 1e-9
  pos_rate <- max(eps, min(1 - eps, pos_rate))       # protect target

  cal_fun <- function(d) mean(stats::plogis(linpred + d)) - pos_rate
  delta   <- uniroot(cal_fun, lower = -60, upper = 60)$root
  
  p     <- stats::plogis(linpred + delta)
  
  default <- as.numeric(stats::rbinom(n, 1, p))
  
  # --- Age groups for fairness grouping ---
  age_group <- cut(
    age,
    breaks = c(-Inf, 30, 50, Inf),
    labels = c("<30", "30-50", "50+"),
    right = TRUE
  )
  
  # --- Assemble raw data ---
  df <- data.frame(
    profession, gender, marital_status, housing_status, region,
    age, employment_length, credit_history_length, number_prior_loans,
    income, loan_amount, credit_score, loan_to_income,
    age_group,
    default
  )
  
  # --- Optional: full one-hot encoding (numeric-only output) ---
  if (isTRUE(onehot)) {
    # English: guard against polluted CI/user environments; restore on exit
    old <- options(contrasts = c(unordered = "contr.treatment", ordered = "contr.poly"))
    on.exit(options(old), add = TRUE)
    
    # English: drop any per-column contrasts attributes that would break encoding
    bad_cols <- names(Filter(function(x) !is.null(attr(x, "contrasts")), df))
    for (nm in bad_cols) attr(df[[nm]], "contrasts") <- NULL
    
    dv <- caret::dummyVars(" ~ .", data = df, fullRank = FALSE)
    df <- as.data.frame(predict(dv, newdata = df))
  }
  
  df
}