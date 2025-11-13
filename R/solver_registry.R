# Solver registry and selection functions

#' Load solver capability table
#' @return List containing solver information
#' @keywords internal
solver_table <- function() {
  yaml_file <- system.file("solver_table.yaml", package = "RSolvers")
  if (yaml_file == "") {
    # Fallback if yaml file not found
    return(list(
      solvers = list(
        highs = list(priority = 1, types = c("LP", "MILP", "QP", "QCQP")),
        cbc = list(priority = 2, types = c("LP", "MILP")),
        scip = list(priority = 3, types = c("LP", "MILP", "QP", "QCQP", "MINLP", "NLP")),
        ipopt = list(priority = 4, types = c("LP", "NLP"))
      )
    ))
  }
  yaml::read_yaml(yaml_file)
}

#' Pick best available solver for problem type
#' @param wanted Character string specifying requested solver ("auto" for automatic selection)
#' @param type Character string specifying problem type (LP, MILP, QP, etc.)
#' @return Character string with selected solver name
#' @keywords internal
solver_pick <- function(wanted = "auto", type = "LP") {
  tbl <- solver_table()
  solvers <- tbl$solvers

  # Check which solvers are available and support the problem type
  available <- vapply(names(solvers), function(s) {
    solver_available <- tryCatch(
      rsolvers_available(s),
      error = function(e) FALSE
    )
    solver_available && (type %in% solvers[[s]]$types)
  }, logical(1))

  if (wanted == "auto") {
    if (!any(available)) {
      stop("No solver available for problem type: ", type,
           "\nInstall one of: ", paste(names(solvers), collapse = ", "))
    }

    # Pick solver with lowest priority (higher priority value = lower priority)
    available_solvers <- names(available)[available]
    priorities <- vapply(available_solvers, function(s) {
      solvers[[s]]$priority
    }, numeric(1))

    return(available_solvers[which.min(priorities)])
  } else {
    # Specific solver requested
    if (!wanted %in% names(solvers)) {
      stop("Unknown solver: ", wanted)
    }
    if (!available[[wanted]]) {
      stop("Solver '", wanted, "' is not available or does not support problem type: ", type)
    }
    return(wanted)
  }
}

#' List available solvers
#' @return Character vector of available solver names
#' @export
list_solvers <- function() {
  tbl <- solver_table()
  solvers <- names(tbl$solvers)

  available <- vapply(solvers, function(s) {
    tryCatch(rsolvers_available(s), error = function(e) FALSE)
  }, logical(1))

  solvers[available]
}
