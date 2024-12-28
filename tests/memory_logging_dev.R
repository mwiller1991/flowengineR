# Function to log memory usage of all objects in the specified environment
log_memory_usage <- function(env = parent.frame(), label = "Memory Log", log_dir = "~/fairness_toolbox/tests/memory_logs") {
  # Ensure the log directory exists
  log_dir <- path.expand(log_dir)
  if (!dir.exists(log_dir)) {
    dir.create(log_dir, recursive = TRUE)
  }
  
  # Generate the file name based on the label
  file <- file.path(log_dir, paste0(gsub(" ", "_", label), ".csv"))
  
  # Get all objects in the specified environment
  object_names <- ls(envir = env)
  
  # Calculate the size of each object
  object_sizes <- sapply(object_names, function(obj) {
    object.size(get(obj, envir = env)) / 1e6  # Size in MB
  })
  
  # Create a data frame for the log
  log_df <- data.frame(
    Object = object_names,
    Size_MB = round(object_sizes, 2),
    stringsAsFactors = FALSE
  )
  
  # Sort objects by size
  log_df <- log_df[order(-log_df$Size_MB), ]
  
  # Output to console (optional)
  #message(sprintf("[%s] Memory Usage Log:", label))
  #print(log_df)
  
  # Save the log to a file
  write.csv(log_df, file, row.names = FALSE)
  message(sprintf("Memory log saved to: %s", file))
  
  return(log_df)
}