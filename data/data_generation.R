#--------------------------------------------------------------------
### insurance price calc ###
#--------------------------------------------------------------------
#' Create Example Dataset 1
#'
#' This function generates a synthetic dataset for testing fairness and machine learning workflows.
#'
#' @param seed An integer seed for random number generation.
#' @return A data frame containing the generated dataset.
#' @export
create_dataset_1 <- function(seed) {
  data_points_count <- 1000
  set.seed(seed)
  
  data_1 <- data.frame(
    profession = sample(c("Employee", "Selfemployed"), data_points_count, replace = TRUE),
    income = rnorm(data_points_count, mean = 50000, sd = 10000),
    gender = sample(c("Male", "Female"), data_points_count, replace = TRUE),
    age = sample(18:65, data_points_count, replace = TRUE),
    damage = rnorm(data_points_count, mean = 1000, sd = 500)
  )
  
  # Group age into categories for evaluation purposes
  data_1$age_group <- cut(
    data_1$age,
    breaks = c(-Inf, 40, 60, Inf),
    labels = c("<40", "40-60", "60+")
  )
  
  print(ggplot2::ggplot(data_1, ggplot2::aes(x = income, y = damage, color = gender)) +
          ggplot2::geom_point() +
          ggplot2::theme_minimal())
  
  data_1 <- caret::dummyVars(" ~ .", data = data_1) %>% predict(newdata = data_1) %>% as.data.frame()
  return(data_1)
}
#--------------------------------------------------------------------




#--------------------------------------------------------------------
### bank default prediction ###
#--------------------------------------------------------------------
#' Create Example Dataset for Bank Default Prediction
#'
#' This function generates a synthetic dataset for testing default prediction workflows.
#'
#' @param seed An integer seed for random number generation.
#' @return A data frame containing the generated dataset.
#' @export
create_dataset_2 <- function(seed) {
  data_points_count <- 1000
  set.seed(seed)
  
  data_1 <- data.frame(
    profession = sample(c("Employee", "Selfemployed", "Unemployed"), data_points_count, replace = TRUE),
    income = rnorm(data_points_count, mean = 40000, sd = 15000),
    loan_amount = rnorm(data_points_count, mean = 20000, sd = 10000),
    credit_score = rnorm(data_points_count, mean = 700, sd = 50),
    age = sample(18:75, data_points_count, replace = TRUE),
    gender = sample(c("Male", "Female"), data_points_count, replace = TRUE),
    marital_status = sample(c("Single", "Married", "Divorced"), data_points_count, replace = TRUE),
    default = sample(c(0, 1), data_points_count, replace = TRUE, prob = c(0.9, 0.1))
  )
  
  # Group age into categories for evaluation purposes
  data_1$age_group <- cut(
    data_1$age,
    breaks = c(-Inf, 30, 50, Inf),
    labels = c("<30", "30-50", "50+")
  )
  
  # Visualize the data distribution
  print(ggplot2::ggplot(data_1, ggplot2::aes(x = income, y = loan_amount, color = as.factor(default))) +
          ggplot2::geom_point() +
          ggplot2::labs(color = "Default") +
          ggplot2::theme_minimal())
  
  # One-hot encode categorical variables
  data_1 <- caret::dummyVars(" ~ .", data = data_1) %>% predict(newdata = data_1) %>% as.data.frame()
  return(data_1)
}
#--------------------------------------------------------------------