#!/usr/bin/env Rscript
# Example: Solving a mixed-integer nonlinear programming problem with RSolvers

library(RSolvers)

# Define a simple MINLP problem
# This is an advanced example requiring SCIP, Bonmin, or Couenne

cat("MINLP Example\n")
cat("=============\n\n")

# Check available solvers
available <- list_solvers()
cat("Available solvers:", paste(available, collapse = ", "), "\n\n")

# Simple MINLP: Minimize x1^2 + x2^2 with x1 integer
model <- list(
  obj = c(0, 0),
  mat = matrix(c(1, 1), nrow = 1),  # x1 + x2 >= 2
  dir = c(">="),
  rhs = c(2),
  types = c("I", "C"),  # x1 integer, x2 continuous
  nl = list(
    objective = "x1^2 + x2^2"
  ),
  problem_type = "MINLP"
)

cat("Problem: Minimize x1^2 + x2^2\n")
cat("Subject to: x1 + x2 >= 2, x1 integer, x2 continuous\n\n")

# Try to solve
solution <- tryCatch({
  rsolve(model, solver = "auto")
}, error = function(e) {
  cat("Note: MINLP solver not available or not fully implemented yet.\n")
  cat("Install SCIP, Bonmin, or Couenne for MINLP support.\n")
  cat("Error:", e$message, "\n")
  return(NULL)
})

if (!is.null(solution)) {
  cat("\nResults:\n")
  print(solution)
  cat("\nSolver used:", solution$solver, "\n")
}
