#include "solver_common.h"

#ifdef HAVE_IPOPT
#include <IpIpoptApplication.hpp>
#include <IpTNLP.hpp>

using namespace Ipopt;

// TNLP implementation for Ipopt
class RSolversNLP : public TNLP {
public:
  RSolversNLP(const Rcpp::List& model) : model_(model) {
    obj_ = Rcpp::as<Rcpp::NumericVector>(model["obj"]);
    n_ = obj_.size();
  }

  virtual bool get_nlp_info(Index& n, Index& m, Index& nnz_jac_g,
                           Index& nnz_h_lag, IndexStyleEnum& index_style) {
    n = n_;
    m = 0;  // Simplified: no constraints in this stub
    nnz_jac_g = 0;
    nnz_h_lag = 0;
    index_style = TNLP::C_STYLE;
    return true;
  }

  virtual bool get_bounds_info(Index n, Number* x_l, Number* x_u,
                              Index m, Number* g_l, Number* g_u) {
    for (Index i = 0; i < n; i++) {
      x_l[i] = 0.0;
      x_u[i] = 2e19;
    }
    return true;
  }

  virtual bool get_starting_point(Index n, bool init_x, Number* x,
                                 bool init_z, Number* z_L, Number* z_U,
                                 Index m, bool init_lambda, Number* lambda) {
    if (init_x) {
      for (Index i = 0; i < n; i++) {
        x[i] = 0.0;
      }
    }
    return true;
  }

  virtual bool eval_f(Index n, const Number* x, bool new_x, Number& obj_value) {
    obj_value = 0.0;
    for (Index i = 0; i < n; i++) {
      obj_value += obj_[i] * x[i];
    }
    return true;
  }

  virtual bool eval_grad_f(Index n, const Number* x, bool new_x, Number* grad_f) {
    for (Index i = 0; i < n; i++) {
      grad_f[i] = obj_[i];
    }
    return true;
  }

  virtual bool eval_g(Index n, const Number* x, bool new_x, Index m, Number* g) {
    return true;
  }

  virtual bool eval_jac_g(Index n, const Number* x, bool new_x,
                         Index m, Index nele_jac, Index* iRow, Index *jCol,
                         Number* values) {
    return true;
  }

  virtual void finalize_solution(SolverReturn status,
                                Index n, const Number* x, const Number* z_L, const Number* z_U,
                                Index m, const Number* g, const Number* lambda,
                                Number obj_value,
                                const IpoptData* ip_data,
                                IpoptCalculatedQuantities* ip_cq) {
    solution_.resize(n);
    for (Index i = 0; i < n; i++) {
      solution_[i] = x[i];
    }
    objval_ = obj_value;
    status_ = status;
  }

  std::vector<double> getSolution() const { return solution_; }
  double getObjval() const { return objval_; }
  SolverReturn getStatus() const { return status_; }

private:
  Rcpp::List model_;
  Rcpp::NumericVector obj_;
  Index n_;
  std::vector<double> solution_;
  double objval_;
  SolverReturn status_;
};

Rcpp::List ipopt_solve(const Rcpp::List& model, const Rcpp::List& control) {
  try {
    // Create Ipopt application
    SmartPtr<IpoptApplication> app = IpoptApplicationFactory();

    // Set options
    app->Options()->SetStringValue("hessian_approximation", "limited-memory");

    if (control.containsElementNamed("time_limit")) {
      double timeLimit = Rcpp::as<double>(control["time_limit"]);
      app->Options()->SetNumericValue("max_cpu_time", timeLimit);
    }

    // Initialize
    ApplicationReturnStatus status = app->Initialize();
    if (status != Solve_Succeeded) {
      Rcpp::stop("Ipopt initialization failed");
    }

    // Create NLP
    SmartPtr<RSolversNLP> nlp = new RSolversNLP(model);

    // Solve
    status = app->OptimizeTNLP(nlp);

    // Extract solution
    std::vector<double> sol_vec = nlp->getSolution();
    Rcpp::NumericVector solution(sol_vec.begin(), sol_vec.end());
    double objval = nlp->getObjval();

    std::string statusStr;
    if (status == Solve_Succeeded || status == Solved_To_Acceptable_Level) {
      statusStr = "optimal";
    } else if (status == Infeasible_Problem_Detected) {
      statusStr = "infeasible";
    } else {
      statusStr = "other";
    }

    return Rcpp::List::create(
      Rcpp::Named("solution") = solution,
      Rcpp::Named("objval") = objval,
      Rcpp::Named("status") = statusStr,
      Rcpp::Named("solver") = "Ipopt"
    );

  } catch (std::exception& e) {
    Rcpp::stop("Ipopt solver error: %s", e.what());
  }

  return R_NilValue;
}

#else

Rcpp::List ipopt_solve(const Rcpp::List& model, const Rcpp::List& control) {
  Rcpp::stop("Ipopt not available at build time");
  return R_NilValue;
}

#endif
