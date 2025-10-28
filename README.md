Package: RSolvers

Title: Universal Open-Source Solver Interface (LP/MILP/QP/QCQP/NLP/MINLP)

Version: 0.9-0

Authors@R: "Vasant Mugada", email = "vasantmv@outlook.com", role = c("aut", "cre"))

Description: An Alternative to Dirk Schumacher's repository for rcbc that automatically picks the
  best available solver (CBC, HiGHS, SCIP, Ipopt, Bonmin, Couenne …)
  and exposes linear, quadratic and general non-linear capabilities.

License: MIT + file LICENSE

Encoding: UTF-8

SystemRequirements: C++17, COIN-OR Cbc (optional), HiGHS (optional),
  SCIP (optional), Ipopt (optional), pkg-config
LinkingTo: Rcpp

Imports: Rcpp, yaml

Suggests: testthat (>= 3.0.0), tinytest

URL: https://github.com/vasantmv/RSolvers
BugReports: https://github.com/vasantmv/RSolvers/issues
RoxygenNote: 7.2.3
