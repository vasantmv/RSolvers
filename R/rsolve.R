#' Solve optimization problems with automatic solver selection
#'
#' Universal interface to solve LP, MILP, QP, QCQP, NLP, and MINLP problems
#' using the best available solver (CBC, HiGHS, SCIP, Ipopt, etc.)
#'
#' @param model List containing problem specification with fields:
#'   \itemize{
#'     \item{\code{obj}}: Numeric vector of objective coefficients
#'     \item{\code{mat}}: Constraint matrix (numeric matrix)
#'     \item{\code{dir}}: Character vector of constraint directions ("<=", ">=", "==")
#'     \item{\code{rhs}}: Numeric vector of right-hand side values
#'     \item{\code{types}}: Character vector of variable types ("C", "I", "B")
#'     \item{\code{max}}: Logical, TRUE for maximization (default FALSE)
#'     \item{\code{bounds}}: Optional list with \code{lower} and \code{upper} bounds
#'     \item{\code{Q}}: Optional quadratic objective matrix
#'     \item{\code{qc}}: Optional quadratic constraints
#'     \item{\code{nl}}: Optional non-linear expressions
#'     \item{\code{problem_type}}: Optional problem type (auto-detected if omitted)
#'   }
#' @param solver Character string specifying which solver to use.
#'   Default "auto" automatically selects the best available solver.
#'   Options: "auto", "cbc", "highs", "scip", "ipopt"
#' @param control List of solver control parameters:
#'   \itemize{
#'     \item{\code{time_limit}}: Maximum time in seconds
#'     \item{\code{mip_gap}}: MIP optimality gap tolerance
#'     \item{\code{threads}}: Number of threads to use
#'     \item{\code{verbose}}: Verbosity level
#'   }
#'
#' @return List with components:
#'   \itemize{
#'     \item{\code{solution}}: Numeric vector of optimal variable values
#'     \item{\code{objval}}: Optimal objective value
#'     \item{\code{status}}: Solution status ("optimal", "infeasible", etc.)
#'     \item{\code{solver}}: Name of solver used
#'   }
#'
#' @examples
#' \dontrun{
#' # Simple linear program
#' model <- list(
#'   obj = c(3, 5),
#'   mat = matrix(c(2, 1, 1, 2), nrow = 2, byrow = TRUE),
#'   dir = c("<=", "<="),
#'   rhs = c(4, 3),
#'   types = c("C", "C")
#' )
#' sol <- rsolve(model)
#' print(sol$solution)
#'
#' # Mixed integer program
#' model$types <- c("B", "B")  # Binary variables
#' sol <- rsolve(model)
#' }
#'
#' @export
rsolve <- function(model, solver = "auto", control = list()) {
  # Validate model
  if (!is.list(model)) {
    stop("model must be a list")
  }
  if (is.null(model$obj)) {
    stop("model must contain 'obj' (objective coefficients)")
  }

  # Auto-detect problem type if not specified
  type <- model$problem_type %||% auto_detect(model)

  # Select solver
  solver_name <- solver_pick(solver, type)

  # Ensure problem_type is set in model
  model$problem_type <- type

  # Ensure types is set (default to continuous)
  if (is.null(model$types)) {
    model$types <- rep("C", length(model$obj))
  }

  # Call C++ solver interface
  result <- tryCatch({
    rsolvers_solve(solver_name, model, control)
  }, error = function(e) {
    stop("Solver error: ", e$message)
  })

  # Add class for pretty printing
  structure(result, class = "rsolve_solution")
}

#' Print method for rsolve solutions
#' @param x An rsolve_solution object
#' @param ... Additional arguments (ignored)
#' @export
print.rsolve_solution <- function(x, ...) {
  cat("RSolvers Solution\n")
  cat("=================\n")
  cat("Solver:   ", x$solver, "\n")
  cat("Status:   ", x$status, "\n")
  cat("Objective:", x$objval, "\n")
  cat("Solution: ", paste(round(x$solution, 4), collapse = ", "), "\n")
  invisible(x)
}
