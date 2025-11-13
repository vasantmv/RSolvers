#!/usr/bin/env Rscript
# Example: Solving a nonlinear programming problem with RSolvers

library(RSolvers)

# Define a simple NLP problem:
# Minimize: x1^2 + (x2 - 1)^2
# This is a simple quadratic problem
# The optimal solution should be x1=0, x2=1

# Note: This is a simplified example.
# For real NLP problems, you would need to specify
# the nonlinear objective and constraints properly.

model <- list(
  obj = c(0, 0),  # Linear part of objective (none in this case)
  nl = list(
    objective = "x1^2 + (x2-1)^2"
  ),
  problem_type = "NLP",
  types = c("C", "C")  # Continuous variables
)

cat("Solving nonlinear programming problem...\n")
cat("Problem: Minimize x1^2 + (x2-1)^2\n\n")

# Try to solve with ipopt if available
solution <- tryCatch({
  rsolve(model, solver = "ipopt")
}, error = function(e) {
  cat("Note: Ipopt solver not available or NLP support not fully implemented yet.\n")
  cat("Error:", e$message, "\n")
  return(NULL)
})

if (!is.null(solution)) {
  cat("\nResults:\n")
  print(solution)

  cat("\nOptimal values:\n")
  cat("x1 =", solution$solution[1], "(expected: 0)\n")
  cat("x2 =", solution$solution[2], "(expected: 1)\n")
  cat("Objective value =", solution$objval, "(expected: 0)\n")
  cat("Solver used:", solution$solver, "\n")
}
