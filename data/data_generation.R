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
    profession = sample(c("Employee", "Self-employed"), data_points_count, replace = TRUE),
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