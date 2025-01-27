#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' In-Processing Engine: Adversarial Debiasing
#'
#' Implements adversarial debiasing by coordinating the training of a main model
#' with adversarial feedback to minimize bias while predicting the target variable.
#'
#' **Inputs:**
#' - `driver_train`: The training engine function for the main model.
#' - `data`: The training dataset.
#' - `protected_attributes`: A character vector specifying the names of protected attributes.
#' - `params`: A list of parameters, including:
#'   - `learning_rate`: Learning rate for adversarial updates.
#'   - `num_epochs`: Number of training epochs.
#'   - `control_for_training`: Control object for flexibility in accessing additional parameters.
#'
#' **Outputs (passed to wrapper):**
#' - `adjusted_model`: The adjusted main model after adversarial debiasing.
#' - `specific_output`: Additional method-specific outputs, such as adversarial performance metrics.
#'
#' @param driver_train The training engine function for the main model.
#' @param data The training dataset.
#' @param protected_attributes A character vector specifying protected attributes.
#' @param target_var The target variable to predict.
#' @param params A list of additional parameters for the engine.
#' @param control_for_training A control object containing workflow details.
#' @return A standardized list containing the adjusted model and metadata.
#' @export
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
#' Wrapper for In-Processing Adversarial Debiasing
#'
#' Coordinates the main model training with adversarial debiasing using the specified engine.
#'
#' @param control A list containing workflow control parameters.
#' @param driver_train The training engine function for the main model.
#' @return A list containing the adjusted model and additional outputs.
#' @export
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
#' @return A list of default parameters for adversarial debiasing engines.
#' @export
default_params_fairness_in_adversialdebiasing <- function() {
  list(
    learning_rate = 0.01,
    num_epochs = 10,
    num_adversary_steps = 3
  )
}
#--------------------------------------------------------------------