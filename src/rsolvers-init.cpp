#include <Rcpp.h>
#include "solver_common.h"

// [[Rcpp::export]]
bool rsolvers_available(std::string solver) {
  #ifdef HAVE_CBC
  if (solver == "cbc") return true;
  #endif
  #ifdef HAVE_HIGHS
  if (solver == "highs") return true;
  #endif
  #ifdef HAVE_SCIP
  if (solver == "scip") return true;
  #endif
  #ifdef HAVE_IPOPT
  if (solver == "ipopt") return true;
  #endif
  return false;
}

// [[Rcpp::export]]
Rcpp::List rsolvers_solve(std::string solver,
                          const Rcpp::List& model,
                          const Rcpp::List& control) {
  #ifdef HAVE_CBC
  if (solver == "cbc") return cbc_solve(model, control);
  #endif
  #ifdef HAVE_HIGHS
  if (solver == "highs") return highs_solve(model, control);
  #endif
  #ifdef HAVE_SCIP
  if (solver == "scip") return scip_solve(model, control);
  #endif
  #ifdef HAVE_IPOPT
  if (solver == "ipopt") return ipopt_solve(model, control);
  #endif
  Rcpp::stop("Solver '%s' not built", solver.c_str());
  return R_NilValue;
}
