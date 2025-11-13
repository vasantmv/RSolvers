#include "solver_common.h"

#ifdef HAVE_SCIP
#include <scip/scip.h>
#include <scip/scipdefplugins.h>

Rcpp::List scip_solve(const Rcpp::List& model, const Rcpp::List& control) {
  SCIP* scip = NULL;

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

    // Initialize SCIP
    SCIP_CALL(SCIPcreate(&scip));
    SCIP_CALL(SCIPincludeDefaultPlugins(scip));
    SCIP_CALL(SCIPcreateProbBasic(scip, "rsolvers_problem"));

    // Set objective sense
    SCIP_CALL(SCIPsetObjsense(scip, maximize ? SCIP_OBJSENSE_MAXIMIZE : SCIP_OBJSENSE_MINIMIZE));

    // Create variables
    std::vector<SCIP_VAR*> vars(numCols);
    for (int j = 0; j < numCols; j++) {
      SCIP_VARTYPE vartype;
      double lb = 0.0;
      double ub = SCIPinfinity(scip);

      std::string type = Rcpp::as<std::string>(types[j]);
      if (type == "B") {
        vartype = SCIP_VARTYPE_BINARY;
        ub = 1.0;
      } else if (type == "I") {
        vartype = SCIP_VARTYPE_INTEGER;
      } else {
        vartype = SCIP_VARTYPE_CONTINUOUS;
      }

      char varName[50];
      snprintf(varName, sizeof(varName), "x%d", j);

      SCIP_CALL(SCIPcreateVarBasic(scip, &vars[j], varName, lb, ub, obj[j], vartype));
      SCIP_CALL(SCIPaddVar(scip, vars[j]));
    }

    // Add constraints
    for (int i = 0; i < numRows; i++) {
      SCIP_CONS* cons;
      char consName[50];
      snprintf(consName, sizeof(consName), "c%d", i);

      double lhs, rhs_val;
      std::string direction = Rcpp::as<std::string>(dir[i]);
      if (direction == "<=") {
        lhs = -SCIPinfinity(scip);
        rhs_val = rhs[i];
      } else if (direction == ">=") {
        lhs = rhs[i];
        rhs_val = SCIPinfinity(scip);
      } else {
        lhs = rhs[i];
        rhs_val = rhs[i];
      }

      SCIP_CALL(SCIPcreateConsBasicLinear(scip, &cons, consName, 0, NULL, NULL, lhs, rhs_val));

      // Add coefficients
      for (int j = 0; j < numCols; j++) {
        if (mat(i, j) != 0) {
          SCIP_CALL(SCIPaddCoefLinear(scip, cons, vars[j], mat(i, j)));
        }
      }

      SCIP_CALL(SCIPaddCons(scip, cons));
      SCIP_CALL(SCIPreleaseCons(scip, &cons));
    }

    // Set parameters
    if (control.containsElementNamed("time_limit")) {
      double timeLimit = Rcpp::as<double>(control["time_limit"]);
      SCIP_CALL(SCIPsetRealParam(scip, "limits/time", timeLimit));
    }
    if (control.containsElementNamed("mip_gap")) {
      double gap = Rcpp::as<double>(control["mip_gap"]);
      SCIP_CALL(SCIPsetRealParam(scip, "limits/gap", gap));
    }

    // Solve
    SCIP_CALL(SCIPsolve(scip));

    // Extract solution
    SCIP_SOL* sol = SCIPgetBestSol(scip);
    Rcpp::NumericVector solution(numCols);

    if (sol != NULL) {
      for (int j = 0; j < numCols; j++) {
        solution[j] = SCIPgetSolVal(scip, sol, vars[j]);
      }
    }

    double objval = SCIPgetPrimalbound(scip);

    std::string status;
    SCIP_STATUS scipStatus = SCIPgetStatus(scip);
    if (scipStatus == SCIP_STATUS_OPTIMAL) {
      status = "optimal";
    } else if (scipStatus == SCIP_STATUS_INFEASIBLE) {
      status = "infeasible";
    } else {
      status = "other";
    }

    // Release variables
    for (int j = 0; j < numCols; j++) {
      SCIP_CALL(SCIPreleaseVar(scip, &vars[j]));
    }

    SCIP_CALL(SCIPfree(&scip));

    return Rcpp::List::create(
      Rcpp::Named("solution") = solution,
      Rcpp::Named("objval") = objval,
      Rcpp::Named("status") = status,
      Rcpp::Named("solver") = "SCIP"
    );

  } catch (std::exception& e) {
    if (scip != NULL) SCIPfree(&scip);
    Rcpp::stop("SCIP solver error: %s", e.what());
  }

  return R_NilValue;
}

#else

Rcpp::List scip_solve(const Rcpp::List& model, const Rcpp::List& control) {
  Rcpp::stop("SCIP not available at build time");
  return R_NilValue;
}

#endif
