#pragma once
#include <Rcpp.h>

// Forward declarations for solver functions
Rcpp::List cbc_solve(const Rcpp::List& model, const Rcpp::List& control);
Rcpp::List highs_solve(const Rcpp::List& model, const Rcpp::List& control);
Rcpp::List scip_solve(const Rcpp::List& model, const Rcpp::List& control);
Rcpp::List ipopt_solve(const Rcpp::List& model, const Rcpp::List& control);
