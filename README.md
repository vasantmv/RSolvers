Package: RSolvers
Title: Universal Open-Source Solver Interface (LP/MILP/QP/QCQP/NLP/MINLP)

Version: 0.9-0

Authors: "Vasant Mugada", email = "vasantmv@outlook.com"

Description: An Alternative to Dirk Schumacher's repository for rcbc that automatically picks the
  best available solver (CBC, HiGHS, SCIP, Ipopt, Bonmin, Couenne …)
  and exposes linear, quadratic and general non-linear capabilities.

License: MIT + file LICENSE

SystemRequirements: C++17, COIN-OR Cbc (optional), HiGHS (optional),
  SCIP (optional), Ipopt (optional), pkg-config
LinkingTo: Rcpp
Imports: Rcpp, yaml
