#--------------------------------------------------------------------
### helper for Post-Processing Engines ###
#--------------------------------------------------------------------
#' Initialize Output for Splitter Engines
#'
#' Creates minimal standardized output for splitter engines.
#' Focuses solely on passing split definitions and optional metadata.
#'
#' **Standardized Output:**
#' - `split_type`: String describing the splitter method (e.g., "random", "cv").
#' - `splits`: List of generated splits (e.g., data.frames or indices).
#' - `params`: Parameters used by the engine, if any.
#' - `specific_output`: Optional metadata or engine-specific details.
#'
#' @param split_type Character string specifying the type of splitter.
#' @param splits List containing split definitions.
#' @param params Optional list of parameters used by the engine.
#' @param specific_output Optional list of engine-specific metadata.
#'
#' @return A standardized output list for splitter engines.
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