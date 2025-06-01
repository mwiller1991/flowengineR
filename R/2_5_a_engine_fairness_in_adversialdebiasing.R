#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Fairness In-Processing Engine: Adversarial Debiasing
#'
#' Trains a main prediction model alongside an adversarial model to reduce bias with respect to protected attributes.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `driver_train`: The training engine function for the main model.
#' - `data`: Training data used for both the main model and adversarial component.
#' - `protected_attribute_names`: Character vector of protected attribute names.
#' - `learning_rate`: Learning rate for adversarial updates.
#' - `num_epochs`: Number of full training cycles.
#' - `num_adversary_steps`: Number of adversarial updates per epoch.
#' - `control_for_training`: Full control object for passing training-related configurations.
#'
#' **Output (returned to wrapper):**
#' - A list containing:
#'   - `adjusted_model`: The retrained main model.
#'   - `adversary_model`: Internally fitted adversary.
#'   - `adversary_loss`: Per-epoch tracking of adversarial loss.
#'
#' @seealso [wrapper_fairness_in_adversialdebiasing()]
#'
#' @param driver_train The training engine function for the main model.
#' @param data The training dataset.
#' @param protected_attribute_names Character vector specifying protected attributes.
#' @param learning_rate Learning rate for adversarial updates.
#' @param num_epochs Number of training epochs.
#' @param num_adversary_steps Number of adversarial update steps per epoch.
#' @param control_for_training A control object containing training configuration.
#'
#' @return A list containing the adjusted model and metadata.
#' @keywords internal
engine_fairness_in_adversialdebiasing <- function(driver_train, data, protected_attribute_names, learning_rate, num_epochs, num_adversary_steps, control_for_training) {
  # Initialize adversary
  adversary_model <- list(
    adversarial_weights = setNames(runif(length(protected_attribute_names)), protected_attribute_names),  # Example: Random initialization
    bias = 0
  )
  
  # Define helper functions within the engine to limit scope
    # helper-function 1: Training the adversial model
    train_adversary_model <- function(adversary_model, main_model_predictions, protected_attributes, learning_rate){
      # Compute adversarial model predictions
      adversary_predictions <- sapply(colnames(protected_attributes), function(attr) {
        main_model_predictions * adversary_model$adversarial_weights[attr] + adversary_model$bias
      })
      
      # Initialize gradients
      gradients <- numeric(length(adversary_model$adversarial_weights))
      gradient_bias <- 0
      
      # Update for each protected attribute
      for (attr in colnames(protected_attributes)) {
        # Select predictions for the current attribute
        adversary_predictions_attr <- adversary_predictions[, attr, drop = FALSE]
        
        # Distinguish between numeric and categorical attributes
        if (is.numeric(protected_attributes[[attr]])) {
          # Mean Squared Error (MSE) for numeric attributes
          error <- adversary_predictions_attr - as.matrix(protected_attributes[[attr]])
          gradients <- gradients + colMeans(error * as.matrix(main_model_predictions))
          gradient_bias <- gradient_bias + mean(error)
        } else {
          # Cross-Entropy Loss for categorical attributes
          probs <- exp(adversary_predictions_attr) / rowSums(exp(adversary_predictions_attr))  # Softmax
          true_probs <- model.matrix(~. - 1, data = protected_attributes[[attr]])  # One-Hot-Encoding
          error <- probs - true_probs
          gradients <- gradients + colMeans(error * as.matrix(main_model_predictions))
          gradient_bias <- gradient_bias + colMeans(error)
        }
      }
              
      # Normalize gradients over the number of attributes
      gradients <- gradients / length(colnames(protected_attributes))
      gradient_bias <- gradient_bias / length(colnames(protected_attributes))
      
      # Parameter update: Stochastic Gradient Descent (SGD)
      adversary_model$adversarial_weights <- adversary_model$adversarial_weights - learning_rate * gradients
      adversary_model$bias <- adversary_model$bias - learning_rate * gradient_bias
      adversary_model$adversary_predictions <- sapply(colnames(protected_attributes), function(attr) {
        main_model_predictions * adversary_model$adversarial_weights[attr] + adversary_model$bias
      })
      
      return(adversary_model)
    }
    # -----
  
    # helper-function 2: Computing the adversary loss for evaluation purposes
    # This function currently calculates the combined loss of the adversarial model,
    # but it does not directly influence the weight updates. It is primarily used as a monitoring
    # or diagnostic tool to evaluate the adversarial model's performance.
    compute_adversary_loss <- function(adversary_model, predictions, protected_attributes) {
      # Initialize lists for detailed metrics
      losses_per_attribute <- list()
      combined_loss <- 0  # Initialize combined loss
      
      # Calculate loss for each protected attribute
      for (attr in colnames(protected_attributes)) {
        if (is.numeric(protected_attributes[[attr]])) {
          # MSE for numeric attributes
          mse <- mean((adversary_model$adversary_predictions[, attr] - protected_attributes[[attr]])^2)
          losses_per_attribute[[attr]] <- list(mse = mse)
          combined_loss <- combined_loss + mse
        } else {
          # Cross-Entropy for categorical attributes
          probs <- exp(adversary_model$adversary_predictions[, attr]) / rowSums(exp(adversary_model$adversary_predictions[, attr]))  # Softmax
          true_probs <- model.matrix(~. - 1, data = protected_attributes[[attr]])
          cross_entropy <- -mean(rowSums(true_probs * log(probs)))
          losses_per_attribute[[attr]] <- list(cross_entropy = cross_entropy)
          combined_loss <- combined_loss + cross_entropy
        }
      }
      
      # Combine losses
      combined_loss <- combined_loss / length(colnames(protected_attributes))
      
      # Return detailed metrics
      return(list(
        combined_loss = combined_loss,
        losses_per_attribute = losses_per_attribute
      ))
    }
    adversary_loss <- list()
    # -----
    
    # helper-function 3: Modifying the main model using the adversary model
    modify_weights_with_adversary_loss <- function(data, adversary_model, protected_attributes, learning_rate) {
      adversary_predictions <- adversary_model$adversary_predictions
      
      # Adjust weights for each attribute
      weights_per_attribute <- lapply(colnames(protected_attributes), function(attr) {
        if (is.numeric(protected_attributes[[attr]])) {
          # Numeric attribute: Adjust weights using MSE
          learning_rate * abs(adversary_predictions[, attr] - protected_attributes[[attr]])
        } else {
          # Categorical attribute: Adjust weights using Cross-Entropy
          probs <- exp(adversary_predictions[, attr]) / rowSums(exp(adversary_predictions[, attr]))
          true_probs <- model.matrix(~. - 1, data = protected_attributes[[attr]])
          learning_rate * -rowSums(true_probs * log(probs))
        }
      })
      
      # Combine weights by taking the mean across attributes
      combined_weights <- 1 - rowMeans(do.call(cbind, weights_per_attribute))
      
      # Ensure weights remain positive
      combined_weights <- pmax(combined_weights, 0.001)  # Avoid zero or negative weights
      
      # Return adjusted data with updated weights
      data$weights <- combined_weights
      return(data)
    }
    # -----
  
  
  # Training loop
  for (epoch in seq_len(num_epochs)) {
    # Step 1: Train the main model using the driver_train function
    trained_main_model <- driver_train(
      control = control_for_training
    )
    
    # Step 2: Train the adversary model
    for (adversary_step in seq_len(num_adversary_steps)) {
      adversary_model <- train_adversary_model(
        adversary_model = adversary_model,
        main_model_predictions = predict(trained_main_model$model, data),
        protected_attributes = data[protected_attribute_names],
        learning_rate = learning_rate
      )
    }
    
    # Step 3: Compute adversarial loss and store it
    adversary_loss[[epoch]] <- compute_adversary_loss(
      adversary_model = adversary_model,
      predictions = predict(trained_main_model$model, data),
      protected_attributes = data[protected_attribute_names]
    )
    
    # Step 4: Update weights based on adversarial feedback
    data <- modify_weights_with_adversary_loss(
      data = data,
      adversary_model = adversary_model,
      protected_attributes = data[protected_attribute_names],
      learning_rate = learning_rate
    )
    
    # Step 5: Update training data and weights in control (normalized or original)
    # Adjusting weights in the hyperparameters to not risk falling back to default in training
    control_for_training$params$train$params$weights <- data$weights
    
    # Adjusting both datasets
    control_for_training$data$train$original <- control_for_training$data$train$normalized <- data
  }
  
  # Return standardized output
  list(
    adjusted_model = trained_main_model$model,
    adversary_model = adversary_model,
    adversary_loss = adversary_loss  # Include losses across epochs
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Fairness In-Processing Engine: Adversarial Debiasing
#'
#' Validates and prepares standardized inputs, merges default and user-defined parameters,
#' and invokes the adversarial debiasing engine. Wraps the result using `initialize_output_fairness_in()`.
#'
#' **Standardized Inputs:**
#' - `control$params$train$data`: Training dataset (original or normalized).
#' - `control$params$train$norm_data`: Logical flag indicating whether normalized data should be used.
#' - `control$params$fairness_in$protected_attributes`: Character vector of protected attributes.  
#'   → Auto-filled from `control$vars$protected_vars` via `autofill_controllers_from_vars()`.
#' - `control$params$fairness_in$params`: Named list of engine-specific parameters.
#' - `driver_train`: Training engine function for the main model (provided by the workflow).
#'
#' **Engine-Specific Parameters (`control$params$fairness_in$params`):**
#' - `learning_rate` *(numeric)*: Learning rate for adversarial updates (default: 0.01).
#' - `num_epochs` *(integer)*: Number of training epochs (default: 10).
#' - `num_adversary_steps` *(integer)*: Number of adversarial update steps per epoch (default: 3).
#'
#' **Variable Handling:**
#' - The wrapper assumes that `protected_attributes` and `target_var` are injected via `autofill_controllers_from_vars()`.
#' - These fields are **required** by the engine but should **not be set manually**.
#'
#' **Example Control Snippet:**
#' ```r
#' control$fairness_in <- "fairness_in_adversialdebiasing"
#' control$params$fairness_in <- controller_fairness_in(
#'   norm_data = TRUE,
#'   params = list(
#'     learning_rate = 0.01,
#'     num_epochs = 10,
#'     num_adversary_steps = 3
#'   )
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/5_a_template_fairness_in_adversialdebiasing.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_fairness_in()`:
#' - `adjusted_model`: The debiased main model.
#' - `model_type`: `"Adversarial Debiasing"`.
#' - `params`: Merged engine parameters.
#' - `specific_output`: Includes:
#'     - `training_time`: Duration of training (in seconds).
#'     - `adversary_model`: Internally trained adversarial component.
#'     - `adversary_loss`: Per-epoch loss history.
#'
#' @seealso 
#'   [engine_fairness_in_adversialdebiasing()],  
#'   [default_params_fairness_in_adversialdebiasing()],  
#'   [initialize_output_fairness_in()],  
#'   [controller_fairness_in()],  
#'   Template: `inst/templates_control/5_a_template_fairness_in_adversialdebiasing.R`
#'
#' @param control A standardized control object. Must include `control$vars` and a valid `control$params$fairness_in`.
#' @param driver_train A training engine function used to train the main model.
#' 
#' @return A standardized fairness in-processing output.
#' @keywords internal
wrapper_fairness_in_adversialdebiasing <- function(control, driver_train) {
  in_params <- control$params$fairness_in  # Access in-processing parameters
  train_params <- control$params$train  # Accessing the training parameters
  
  if (is.null(in_params)) {
    stop("Wrapper: Missing required in-processing parameters.")
  }
  
  # Choose normalized or original data
  train_data <- select_training_data(train_params$norm_data, train_params$data)
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(in_params$params, default_params_fairness_in_adversialdebiasing())
  
  # Logging start
  log_msg(sprintf(
    "[IN] Starting adversarial debiasing (%d epochs, %d steps/epoch, lr = %.4f)...",
    params$num_epochs, params$num_adversary_steps, params$learning_rate
  ), level = "info", control = control)
  
  # Track training time
  start_time <- Sys.time()
  
  # Call the specific in-processing engine
  engine_output <- engine_fairness_in_adversialdebiasing(
    driver_train = driver_train,
    data = train_data,
    protected_attribute_names = in_params$protected_attributes,
    learning_rate = params$learning_rate,
    num_epochs = params$num_epochs,
    num_adversary_steps = params$num_adversary_steps,
    control_for_training = control
  )
  
  training_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  log_msg(sprintf("[IN] Adversarial training complete (%.2fs)", training_time),
          level = "info", control = control)
  
  # Standardized output
  initialize_output_fairness_in(
    adjusted_model = engine_output$adjusted_model,
    model_type = "Adversarial Debiasing",
    params = params,
    specific_output = list(training_time = training_time,
                           adversary_model = engine_output$adversary_model,
                           adversary_loss = engine_output$adversary_loss  # Include losses across epochs
                      )
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for In-Processing Engines: Adversarial Debiasing
#'
#' Provides default parameters for adversarial debiasing in-processing engines.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_fairness_in` function**, which include:
#'   - `data`: The training dataset.
#'   - `protected_attributes`: Names of the protected attributes.
#'   - `target_var`: The target variable.
#' - **Additional Parameters:**
#'   - `main_model_params`: Parameters for the main model.
#'   - `adversary_params`: Parameters for the adversarial model.
#'   - `learning_rate`: Learning rate for adversarial optimization (default: 0.01).
#'   - `num_epochs`: Number of training epochs (default: 10).
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @seealso [wrapper_fairness_in_adversialdebiasing()]
#'
#' @return A list of default parameters for adversarial debiasing engines.
#' @keywords internal
default_params_fairness_in_adversialdebiasing <- function() {
  list(
    learning_rate = 0.01,
    num_epochs = 10,
    num_adversary_steps = 3
  )
}
#--------------------------------------------------------------------