#!/usr/bin/env Rscript
# Example: Solving a simple linear programming problem with RSolvers

library(RSolvers)

# Define a simple LP problem:
# Maximize: 3*x1 + 5*x2
# Subject to:
#   2*x1 + x2 <= 4
#   x1 + 2*x2 <= 3
#   x1, x2 >= 0 (binary)

model <- list(
  obj = c(3, 5),
  mat = matrix(c(2, 1,    # First constraint coefficients
                 1, 2),   # Second constraint coefficients
               nrow = 2, byrow = TRUE),
  dir = c("<=", "<="),
  rhs = c(4, 3),
  types = c("B", "B"),  # Binary variables
  max = TRUE  # Maximization problem
)

cat("Solving linear programming problem...\n")
solution <- rsolve(model)

cat("\nResults:\n")
print(solution)

cat("\nOptimal values:\n")
cat("x1 =", solution$solution[1], "\n")
cat("x2 =", solution$solution[2], "\n")
cat("Objective value =", solution$objval, "\n")
cat("Solver used:", solution$solver, "\n")
