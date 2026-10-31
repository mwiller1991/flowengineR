# Tests for the in-processing engine inprocessing_fairness_adversarialdebiasing

make_inprocessing_control <- function(train = "train_glm", family = gaussian(),
                                      inprocessing = "inprocessing_fairness_adversarialdebiasing") {
  vars <- controller_vars(
    feature_vars = c("income", "loan_amount", "credit_score"),
    protected_vars = c("gender.Female", "age"),
    target_var = "default",
    protected_vars_binary = c("gender.Female", "gender.Male")
  )
  list(
    settings = list(log = list(log_show = FALSE)),
    data = list(
      vars = vars,
      full = create_dataset_bank(n = 500, seed = 42, onehot = TRUE, pos_rate = 0.1)
    ),
    engine_select = list(
      split = "split_random",
      train = train,
      inprocessing = inprocessing,
      evaluation = "eval_mse"
    ),
    params = list(
      split = controller_split(seed = 1),
      train = controller_training(
        formula = default ~ income + loan_amount + credit_score + gender.Female + age,
        norm_data = TRUE,
        params = if (train == "train_glm") list(family = family) else list()
      ),
      inprocessing = controller_inprocessing(params = list(num_epochs = 3)),
      evaluation = controller_evaluation()
    )
  )
}

test_that("adversarial debiasing changes the model (train_glm, gaussian)", {
  res <- run_workflow(make_inprocessing_control())
  wr <- res$execution_output$workflow_results[[1]]
  expect_false(isTRUE(all.equal(coef(wr$output_train$model),
                                coef(wr$output_inprocessing$adjusted_model))))
  expect_length(wr$output_inprocessing$specific_output$adversary_loss, 3)
})

test_that("adversarial debiasing with a binomial GLM runs without warnings", {
  expect_warning(
    res <- run_workflow(make_inprocessing_control(family = binomial())),
    NA
  )
  wr <- res$execution_output$workflow_results[[1]]
  expect_false(isTRUE(all.equal(coef(wr$output_train$model),
                                coef(wr$output_inprocessing$adjusted_model))))
})

test_that("adversarial debiasing warns for train_lm, which ignores weights", {
  expect_warning(
    run_workflow(make_inprocessing_control(train = "train_lm")),
    "does not use observation weights"
  )
})

test_that("the old name inprocessing_fairness_adversialdebiasing still works", {
  flowengineR_env$renamed_notified <- NULL
  expect_message(
    res <- run_workflow(make_inprocessing_control(
      inprocessing = "inprocessing_fairness_adversialdebiasing"
    )),
    "was renamed"
  )
  expect_s3_class(res$execution_output$workflow_results[[1]]$output_inprocessing$adjusted_model, "glm")
  expect_false("inprocessing_fairness_adversialdebiasing" %in%
                 names(list_registered_engines("inprocessing")))
  expect_identical(resolve_engine_name("train_glm"), "train_glm")
  expect_null(resolve_engine_name(NULL))
})
