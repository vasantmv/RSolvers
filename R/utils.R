# Utility functions for RSolvers

#' Default value operator
#' @keywords internal
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Auto-detect problem type from model specification
#' @param model List containing model specification
#' @return Character string indicating problem type
#' @keywords internal
auto_detect <- function(model) {
  # Check for non-linear components
  if (!is.null(model$nl)) {
    return("MINLP")
  }

  # Check for quadratic objective or constraints
  if (!is.null(model$Q) || !is.null(model$qc)) {
    # Check if there are integer variables
    if (!is.null(model$types) && any(model$types %in% c("B", "I"))) {
      return("MIQP")
    }
    return("QP")
  }

  # Linear problem - check for integer variables
  if (!is.null(model$types) && any(model$types %in% c("B", "I"))) {
    return("MILP")
  }

  return("LP")
}
