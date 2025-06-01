#--------------------------------------------------------------------
### Output Initializer: Splitter Engine ###
#--------------------------------------------------------------------
#' Output Initializer: Splitter Engine Results
#'
#' Creates a standardized output object for **splitter engines** within the fairnessToolbox.
#' This initializer ensures that all splitter engines return their results in a uniform format,
#' making them compatible with downstream execution engines.
#'
#' **Purpose:**
#' - Provides a consistent structure for data split definitions across all engines.
#' - Enables flexible use of custom or built-in split strategies (e.g., random, stratified, CV).
#'
#' **Standardized Output:**
#' - `split_type`: Character string describing the split method (e.g., `"random"`, `"cv"`).
#' - `splits`: A named list of split definitions (e.g., data indices or data.frames).
#' - `seed`: The random seed used for reproducibility.
#' - `params`: Optional named list of parameters used by the splitter engine.
#' - `specific_output`: Optional engine-specific metadata (e.g., fold summary, split ratios).
#'
#' **Usage Example (inside an engine):**
#' ```r
#' set.seed(control$split$seed)
#' n <- nrow(control$data)
#' idx <- sample(seq_len(n))
#' splits <- list("1" = list(train = idx[1:70], test = idx[71:100]))
#'
#' initialize_output_split(
#'   split_type = "random",
#'   splits = splits,
#'   seed = control$split$seed,
#'   params = control$split$params
#' )
#' ```
#'
#' @param split_type Character. Short descriptor of the split strategy (e.g., `"random"`, `"cv"`).
#' @param splits Named list. Split definitions (e.g., list of train/test indices).
#' @param seed Integer. The random seed used for reproducibility.
#' @param params Optional. Named list of parameters used to configure the split.
#' @param specific_output Optional. Additional engine-specific metadata or diagnostic information.
#'
#' @return A named list containing standardized split output.
#' @export
initialize_output_split <- function(split_type, splits, seed, params = NULL, specific_output = NULL) {
  output <- list(
    split_type = split_type,
    splits = splits,
    seed = seed
  )
  
  if (!is.null(params)) {
    output$params <- params
  }
  if (!is.null(specific_output)) {
    output$specific_output <- specific_output
  }
  
  return(output)
}
#--------------------------------------------------------------------