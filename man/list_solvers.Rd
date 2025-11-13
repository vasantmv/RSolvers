\name{list_solvers}
\alias{list_solvers}
\title{List Available Solvers}
\usage{
list_solvers()
}
\value{
Character vector of available solver names
}
\description{
Returns a character vector of solvers that are currently available
(i.e., were successfully compiled and linked with the package).
}
\details{
This function checks which solvers were available at build time and
returns their names. Solvers must be installed on the system before
building the RSolvers package.

To install solvers:
\itemize{
  \item Ubuntu/Debian: \code{sudo apt-get install coinor-libcbc-dev coinor-libipopt-dev}
  \item macOS: \code{brew install cbc ipopt scip}
  \item Windows: Install via Rtools42 pacman
}
}
\examples{
# Check which solvers are available
available <- list_solvers()
print(available)

if ("highs" \%in\% available) {
  cat("HiGHS solver is available\n")
}

if (length(available) == 0) {
  cat("No solvers available. Please install CBC, HiGHS, SCIP, or Ipopt.\n")
}
}
\seealso{
\code{\link{rsolve}}
}
\keyword{utilities}
