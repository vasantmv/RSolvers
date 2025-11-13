#include "solver_common.h"

#ifdef HAVE_HIGHS
#include <Highs.h>

Rcpp::List highs_solve(const Rcpp::List& model, const Rcpp::List& control) {
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

    // Initialize HiGHS
    Highs highs;

    // Set options
    if (control.containsElementNamed("time_limit")) {
      double timeLimit = Rcpp::as<double>(control["time_limit"]);
      highs.setOptionValue("time_limit", timeLimit);
    }
    if (control.containsElementNamed("mip_gap")) {
      double gap = Rcpp::as<double>(control["mip_gap"]);
      highs.setOptionValue("mip_rel_gap", gap);
    }

    // Set sense
    ObjSense sense = maximize ? ObjSense::kMaximize : ObjSense::kMinimize;

    // Build constraint matrix in compressed sparse column format
    std::vector<int> aStart;
    std::vector<int> aIndex;
    std::vector<double> aValue;

    aStart.push_back(0);
    for (int j = 0; j < numCols; j++) {
      for (int i = 0; i < numRows; i++) {
        if (mat(i, j) != 0) {
          aIndex.push_back(i);
          aValue.push_back(mat(i, j));
        }
      }
      aStart.push_back(aIndex.size());
    }

    // Set row bounds
    std::vector<double> rowLower(numRows);
    std::vector<double> rowUpper(numRows);
    for (int i = 0; i < numRows; i++) {
      std::string direction = Rcpp::as<std::string>(dir[i]);
      if (direction == "<=") {
        rowLower[i] = -kHighsInf;
        rowUpper[i] = rhs[i];
      } else if (direction == ">=") {
        rowLower[i] = rhs[i];
        rowUpper[i] = kHighsInf;
      } else {
        rowLower[i] = rhs[i];
        rowUpper[i] = rhs[i];
      }
    }

    // Set column bounds
    std::vector<double> colLower(numCols, 0.0);
    std::vector<double> colUpper(numCols, kHighsInf);

    // Set variable types
    std::vector<HighsVarType> varTypes(numCols);
    for (int i = 0; i < numCols; i++) {
      std::string type = Rcpp::as<std::string>(types[i]);
      if (type == "B") {
        varTypes[i] = HighsVarType::kInteger;
        colUpper[i] = 1.0;
      } else if (type == "I") {
        varTypes[i] = HighsVarType::kInteger;
      } else {
        varTypes[i] = HighsVarType::kContinuous;
      }
    }

    // Pass model to HiGHS
    std::vector<double> objCoeffs(obj.begin(), obj.end());

    HighsStatus status = highs.passModel(numCols, numRows, aStart.size() - 1,
                                        sense, 0.0, objCoeffs.data(),
                                        colLower.data(), colUpper.data(),
                                        rowLower.data(), rowUpper.data(),
                                        aStart.data(), aIndex.data(), aValue.data(),
                                        varTypes.data());

    if (status != HighsStatus::kOk) {
      Rcpp::stop("Failed to pass model to HiGHS");
    }

    // Solve
    status = highs.run();

    // Extract solution
    const HighsSolution& solution = highs.getSolution();
    const HighsInfo& info = highs.getInfo();

    Rcpp::NumericVector sol(solution.col_value.begin(), solution.col_value.end());
    double objval = info.objective_function_value;

    std::string statusStr;
    HighsModelStatus modelStatus = highs.getModelStatus();
    if (modelStatus == HighsModelStatus::kOptimal) {
      statusStr = "optimal";
    } else if (modelStatus == HighsModelStatus::kInfeasible) {
      statusStr = "infeasible";
    } else {
      statusStr = "other";
    }

    return Rcpp::List::create(
      Rcpp::Named("solution") = sol,
      Rcpp::Named("objval") = objval,
      Rcpp::Named("status") = statusStr,
      Rcpp::Named("solver") = "HiGHS"
    );

  } catch (std::exception& e) {
    Rcpp::stop("HiGHS solver error: %s", e.what());
  }

  return R_NilValue;
}

#else

Rcpp::List highs_solve(const Rcpp::List& model, const Rcpp::List& control) {
  Rcpp::stop("HiGHS not available at build time");
  return R_NilValue;
}

#endif
