test_that("NLP detection works", {
  skip_if(length(list_solvers()) == 0, "No solvers available")

  model <- list(
    obj = c(0, 0),
    nl = list(objective = "x1^2 + x2^2"),
    types = c("C", "C")
  )

  # Should detect as NLP
  detected_type <- RSolvers:::auto_detect(model)
  expect_equal(detected_type, "MINLP")  # Any NL is treated as MINLP initially
})

test_that("QP detection works", {
  model <- list(
    obj = c(1, 1),
    Q = matrix(c(1, 0, 0, 1), nrow = 2),
    types = c("C", "C")
  )

  detected_type <- RSolvers:::auto_detect(model)
  expect_equal(detected_type, "QP")
})

test_that("MIQP detection works", {
  model <- list(
    obj = c(1, 1),
    Q = matrix(c(1, 0, 0, 1), nrow = 2),
    types = c("I", "C")
  )

  detected_type <- RSolvers:::auto_detect(model)
  expect_equal(detected_type, "MIQP")
})

test_that("LP detection works", {
  model <- list(
    obj = c(1, 1),
    mat = matrix(c(1, 1), nrow = 1),
    dir = "<=",
    rhs = 2,
    types = c("C", "C")
  )

  detected_type <- RSolvers:::auto_detect(model)
  expect_equal(detected_type, "LP")
})

test_that("MILP detection works", {
  model <- list(
    obj = c(1, 1),
    mat = matrix(c(1, 1), nrow = 1),
    dir = "<=",
    rhs = 2,
    types = c("I", "I")
  )

  detected_type <- RSolvers:::auto_detect(model)
  expect_equal(detected_type, "MILP")
})

test_that("solver capabilities are correctly reported", {
  tbl <- RSolvers:::solver_table()

  expect_true("solvers" %in% names(tbl))

  # Check that key solvers are in the table
  expect_true("highs" %in% names(tbl$solvers))
  expect_true("cbc" %in% names(tbl$solvers))
  expect_true("scip" %in% names(tbl$solvers))
  expect_true("ipopt" %in% names(tbl$solvers))

  # Check that HiGHS supports LP and MILP
  expect_true("LP" %in% tbl$solvers$highs$types)
  expect_true("MILP" %in% tbl$solvers$highs$types)

  # Check that SCIP supports MINLP
  expect_true("MINLP" %in% tbl$solvers$scip$types)
})

test_that("list_solvers returns character vector", {
  solvers <- list_solvers()
  expect_type(solvers, "character")
})

test_that("unavailable solver for problem type gives error", {
  skip_if(length(list_solvers()) == 0, "No solvers available")

  # Try to use a solver that doesn't support the problem type
  model <- list(
    obj = c(0, 0),
    nl = list(objective = "x1^2 + x2^2"),
    types = c("C", "C"),
    problem_type = "MINLP"
  )

  # If CBC is available but SCIP/Ipopt is not, this should fail
  available <- list_solvers()
  if ("cbc" %in% available && !any(c("scip", "ipopt") %in% available)) {
    expect_error(rsolve(model, solver = "cbc"), "does not support")
  }
})
