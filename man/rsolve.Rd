\name{rsolve}
\alias{rsolve}
\title{Universal Solver Interface}
\usage{
rsolve(model, solver = "auto", control = list())
}
\arguments{
\item{model}{List containing problem specification with fields:
  \describe{
    \item{\code{obj}}{Numeric vector of objective coefficients}
    \item{\code{mat}}{Constraint matrix (numeric matrix)}
    \item{\code{dir}}{Character vector of constraint directions ("<=", ">=", "==")}
    \item{\code{rhs}}{Numeric vector of right-hand side values}
    \item{\code{types}}{Character vector of variable types ("C", "I", "B")}
    \item{\code{max}}{Logical, TRUE for maximization (default FALSE)}
    \item{\code{bounds}}{Optional list with \code{lower} and \code{upper} bounds}
    \item{\code{Q}}{Optional quadratic objective matrix}
    \item{\code{qc}}{Optional quadratic constraints}
    \item{\code{nl}}{Optional non-linear expressions}
    \item{\code{problem_type}}{Optional problem type (auto-detected if omitted)}
  }
}

\item{solver}{Character string specifying which solver to use.
  Default "auto" automatically selects the best available solver.
  Options: "auto", "cbc", "highs", "scip", "ipopt"}

\item{control}{List of solver control parameters:
  \describe{
    \item{\code{time_limit}}{Maximum time in seconds}
    \item{\code{mip_gap}}{MIP optimality gap tolerance}
    \item{\code{threads}}{Number of threads to use}
    \item{\code{verbose}}{Verbosity level}
  }
}
}
\value{
List with components:
\describe{
  \item{\code{solution}}{Numeric vector of optimal variable values}
  \item{\code{objval}}{Optimal objective value}
  \item{\code{status}}{Solution status ("optimal", "infeasible", etc.)}
  \item{\code{solver}}{Name of solver used}
}
}
\description{
Solve LP, MILP, QP, QCQP, NLP, and MINLP problems using the best available
open-source solver. Automatically detects problem type and selects appropriate
solver from CBC, HiGHS, SCIP, Ipopt, Bonmin, or Couenne.
}
\details{
The function automatically detects the problem type based on the model
specification and selects the most appropriate solver. Solver priority
(when multiple solvers can handle a problem type):

\enumerate{
  \item HiGHS - for LP, MILP, QP, QCQP
  \item CBC - for LP, MILP
  \item SCIP - for all problem types
  \item Ipopt - for NLP
  \item Bonmin - for MINLP
  \item Couenne - for MINLP
}

Problem types:
\itemize{
  \item LP: Linear Programming (continuous variables)
  \item MILP: Mixed Integer Linear Programming
  \item QP: Quadratic Programming
  \item QCQP: Quadratically Constrained Quadratic Programming
  \item NLP: Nonlinear Programming
  \item MINLP: Mixed Integer Nonlinear Programming
}
}
\examples{
# Linear program (continuous)
model <- list(
  obj = c(3, 5),
  mat = matrix(c(2, 1, 1, 2), nrow = 2, byrow = TRUE),
  dir = c("<=", "<="),
  rhs = c(4, 3),
  types = c("C", "C")
)
sol <- rsolve(model)
print(sol)

# Mixed integer program (binary variables)
model$types <- c("B", "B")
model$max <- TRUE
sol <- rsolve(model)
cat("Optimal solution:", sol$solution, "\n")
cat("Objective value:", sol$objval, "\n")

# Specify solver explicitly
\dontrun{
sol <- rsolve(model, solver = "cbc")
}

# With control parameters
\dontrun{
sol <- rsolve(model, control = list(time_limit = 60, mip_gap = 0.01))
}
}
\seealso{
\code{\link{list_solvers}}, \code{\link{RSolvers-package}}
}
\keyword{optimize}
