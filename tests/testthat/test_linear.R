test_that("simple LP works", {
  skip_if(length(list_solvers()) == 0, "No solvers available")

  model <- list(
    obj = c(3, 5),
    mat = matrix(c(2, 1), nrow = 1),
    dir = "<=",
    rhs = 4,
    types = c("C", "C")
  )

  sol <- rsolve(model)

  expect_type(sol, "list")
  expect_true("solution" %in% names(sol))
  expect_true("objval" %in% names(sol))
  expect_true("status" %in% names(sol))
  expect_true("solver" %in% names(sol))
  expect_length(sol$solution, 2)
})

test_that("MILP with binary variables works", {
  skip_if(length(list_solvers()) == 0, "No solvers available")

  model <- list(
    obj = c(3, 5),
    mat = matrix(c(2, 1), nrow = 1),
    dir = "<=",
    rhs = 4,
    types = c("B", "B"),
    max = TRUE
  )

  sol <- rsolve(model)

  expect_type(sol, "list")
  expect_equal(sol$status, "optimal", tolerance = 0.1)

  # Check that solution values are binary
  expect_true(all(sol$solution %in% c(0, 1)))
})

test_that("MILP with integer variables works", {
  skip_if(length(list_solvers()) == 0, "No solvers available")

  model <- list(
    obj = c(1, 1),
    mat = matrix(c(1, 1), nrow = 1),
    dir = ">=",
    rhs = 3,
    types = c("I", "I")
  )

  sol <- rsolve(model)

  expect_type(sol, "list")

  # Check that solution values are integers
  expect_equal(sol$solution, round(sol$solution))
})

test_that("maximization works", {
  skip_if(length(list_solvers()) == 0, "No solvers available")

  model <- list(
    obj = c(3, 5),
    mat = matrix(c(2, 1), nrow = 1),
    dir = "<=",
    rhs = 4,
    types = c("C", "C"),
    max = TRUE
  )

  sol <- rsolve(model)

  expect_type(sol, "list")
  # With maximization, objective should be higher
  expect_true(sol$objval >= 0)
})

test_that("multiple constraints work", {
  skip_if(length(list_solvers()) == 0, "No solvers available")

  model <- list(
    obj = c(3, 5),
    mat = matrix(c(2, 1,
                   1, 2), nrow = 2, byrow = TRUE),
    dir = c("<=", "<="),
    rhs = c(4, 3),
    types = c("C", "C")
  )

  sol <- rsolve(model)

  expect_type(sol, "list")
  expect_length(sol$solution, 2)
})

test_that("solver selection works", {
  available <- list_solvers()
  skip_if(length(available) == 0, "No solvers available")

  model <- list(
    obj = c(1, 1),
    mat = matrix(c(1, 1), nrow = 1),
    dir = "<=",
    rhs = 2,
    types = c("C", "C")
  )

  # Test auto selection
  sol_auto <- rsolve(model, solver = "auto")
  expect_true(sol_auto$solver %in% available)

  # Test explicit solver selection (if available)
  if ("highs" %in% available) {
    sol_highs <- rsolve(model, solver = "highs")
    expect_equal(sol_highs$solver, "HiGHS")
  }

  if ("cbc" %in% available) {
    sol_cbc <- rsolve(model, solver = "cbc")
    expect_equal(sol_cbc$solver, "CBC")
  }
})

test_that("invalid model raises error", {
  expect_error(rsolve(list()), "obj")
  expect_error(rsolve("not a list"), "must be a list")
})

test_that("invalid solver raises error", {
  skip_if(length(list_solvers()) == 0, "No solvers available")

  model <- list(
    obj = c(1, 1),
    mat = matrix(c(1, 1), nrow = 1),
    dir = "<=",
    rhs = 2,
    types = c("C", "C")
  )

  expect_error(rsolve(model, solver = "nonexistent"), "Unknown solver")
})
