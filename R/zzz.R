# Package initialization

.onLoad <- function(libname, pkgname) {
  # Check which solvers are available
  available_solvers <- tryCatch({
    list_solvers()
  }, error = function(e) {
    character(0)
  })

  if (length(available_solvers) > 0) {
    msg <- paste0("RSolvers loaded with: ", paste(available_solvers, collapse = ", "))
    packageStartupMessage(msg)
  } else {
    packageStartupMessage("RSolvers loaded but no solvers available. Install CBC, HiGHS, SCIP, or Ipopt.")
  }
}

.onAttach <- function(libname, pkgname) {
  # Additional startup message if needed
}
