#include "solver_common.h"

#ifdef HAVE_CBC
#include <coin/CbcModel.hpp>
#include <coin/OsiClpSolverInterface.hpp>

Rcpp::List cbc_solve(const Rcpp::List& model, const Rcpp::List& control) {
  try {
    // Extract model components
    Rcpp::NumericVector obj = model["obj"];
    Rcpp::NumericMatrix mat = model["mat"];
    Rcpp::CharacterVector dir = model["dir"];
    Rcpp::NumericVector rhs = model["rhs"];
    Rcpp::CharacterVector types = model["types"];
    bool maximize = model.containsElementNamed("max") ? Rcpp::as<bool>(model["max"]) : false;

    int numCols = obj.size();
    int numRows = mat.nrow();

    // Initialize solver
    OsiClpSolverInterface solver;

    // Set objective
    std::vector<double> objective(numCols);
    for (int i = 0; i < numCols; i++) {
      objective[i] = maximize ? -obj[i] : obj[i];
    }

    // Build constraint matrix
    CoinPackedMatrix matrix(false, numRows, numCols);
    for (int i = 0; i < numRows; i++) {
      std::vector<int> cols;
      std::vector<double> vals;
      for (int j = 0; j < numCols; j++) {
        if (mat(i, j) != 0) {
          cols.push_back(j);
          vals.push_back(mat(i, j));
        }
      }
      matrix.appendRow(cols.size(), cols.data(), vals.data());
    }

    // Set row bounds
    std::vector<double> rowLower(numRows);
    std::vector<double> rowUpper(numRows);
    for (int i = 0; i < numRows; i++) {
      std::string direction = Rcpp::as<std::string>(dir[i]);
      if (direction == "<=") {
        rowLower[i] = -COIN_DBL_MAX;
        rowUpper[i] = rhs[i];
      } else if (direction == ">=") {
        rowLower[i] = rhs[i];
        rowUpper[i] = COIN_DBL_MAX;
      } else { // "=="
        rowLower[i] = rhs[i];
        rowUpper[i] = rhs[i];
      }
    }

    // Set column bounds (default 0 to infinity)
    std::vector<double> colLower(numCols, 0.0);
    std::vector<double> colUpper(numCols, COIN_DBL_MAX);

    // Load problem
    solver.loadProblem(matrix, colLower.data(), colUpper.data(),
                      objective.data(), rowLower.data(), rowUpper.data());

    // Set integer variables
    for (int i = 0; i < numCols; i++) {
      std::string type = Rcpp::as<std::string>(types[i]);
      if (type == "B") {
        solver.setInteger(i);
        solver.setColUpper(i, 1.0);
      } else if (type == "I") {
        solver.setInteger(i);
      }
    }

    // Create CBC model
    CbcModel cbcModel(solver);

    // Set control parameters
    if (control.containsElementNamed("time_limit")) {
      double timeLimit = Rcpp::as<double>(control["time_limit"]);
      cbcModel.setMaximumSeconds(timeLimit);
    }
    if (control.containsElementNamed("mip_gap")) {
      double gap = Rcpp::as<double>(control["mip_gap"]);
      cbcModel.setAllowableGap(gap);
    }

    // Solve
    cbcModel.branchAndBound();

    // Extract solution
    const double* solution = cbcModel.bestSolution();
    Rcpp::NumericVector sol(numCols);
    if (solution) {
      for (int i = 0; i < numCols; i++) {
        sol[i] = solution[i];
      }
    }

    double objval = cbcModel.getObjValue();
    if (maximize) objval = -objval;

    std::string status = cbcModel.isProvenOptimal() ? "optimal" :
                        cbcModel.isProvenInfeasible() ? "infeasible" : "other";

    return Rcpp::List::create(
      Rcpp::Named("solution") = sol,
      Rcpp::Named("objval") = objval,
      Rcpp::Named("status") = status,
      Rcpp::Named("solver") = "CBC"
    );

  } catch (std::exception& e) {
    Rcpp::stop("CBC solver error: %s", e.what());
  }

  return R_NilValue;
}

#else

Rcpp::List cbc_solve(const Rcpp::List& model, const Rcpp::List& control) {
  Rcpp::stop("CBC not available at build time");
  return R_NilValue;
}

#endif
