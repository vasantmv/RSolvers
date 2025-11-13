\name{RSolvers-package}
\alias{RSolvers-package}
\alias{RSolvers}
\docType{package}
\title{
  Universal Open-Source Solver Interface
}
\description{
  RSolvers provides a unified interface to multiple open-source optimization solvers
  (CBC, HiGHS, SCIP, Ipopt, Bonmin, Couenne). It automatically selects the best
  available solver for your problem type (LP, MILP, QP, QCQP, NLP, MINLP).
}
\details{
  The package acts as a drop-in replacement for rcbc and other solver-specific
  packages, providing a single interface for all problem types.

  Key features:
  \itemize{
    \item Automatic solver selection based on problem type
    \item Support for LP, MILP, QP, QCQP, NLP, and MINLP problems
    \item Optional dependencies - only install the solvers you need
    \item Unified interface across all solver backends
  }

  Main functions:
  \itemize{
    \item \code{\link{rsolve}}: Main solver interface
    \item \code{\link{list_solvers}}: List available solvers
  }

  Supported solvers:
  \itemize{
    \item HiGHS: LP, MILP, QP, QCQP (priority 1)
    \item CBC: LP, MILP (priority 2)
    \item SCIP: LP, MILP, QP, QCQP, NLP, MINLP (priority 3)
    \item Ipopt: LP, NLP (priority 4)
    \item Bonmin: MINLP (priority 5)
    \item Couenne: MINLP (priority 6)
  }
}
\author{
Vasant Mugada

Maintainer: Vasant Mugada <vasantmv@outlook.com>
}
\references{
  CBC: https://github.com/coin-or/Cbc
  HiGHS: https://highs.dev/
  SCIP: https://www.scipopt.org/
  Ipopt: https://coin-or.github.io/Ipopt/
}
\keyword{package}
\keyword{optimize}
\seealso{
  \code{\link{rsolve}}
}
\examples{
\dontrun{
# Simple linear program
model <- list(
  obj = c(3, 5),
  mat = matrix(c(2, 1), nrow = 1),
  dir = "<=",
  rhs = 4,
  types = c("B", "B")
)
sol <- rsolve(model)
print(sol$solution)
}
}
