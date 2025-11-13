# RSolvers

> **Universal Open-Source Solver Interface for R**
> One package, every open-source solver (CBC, HiGHS, SCIP, Ipopt, Bonmin, Couenne)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Overview

**RSolvers** is a universal optimization interface for R that automatically selects the best available solver for your problem. It provides seamless support for:

- **LP** (Linear Programming)
- **MILP** (Mixed Integer Linear Programming)
- **QP** (Quadratic Programming)
- **QCQP** (Quadratically Constrained Quadratic Programming)
- **NLP** (Nonlinear Programming)
- **MINLP** (Mixed Integer Nonlinear Programming)

### Key Features

- **Automatic solver selection** - Picks the best solver for your problem type
- **Unified interface** - One function call for all problem types
- **Optional dependencies** - Install only the solvers you need
- **Drop-in replacement** - Compatible with rcbc and similar packages
- **Comprehensive support** - From simple LPs to complex MINLPs

## Installation

### Prerequisites

RSolvers requires a C++17 compiler and optionally one or more of the following solvers:

#### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install coinor-libcbc-dev coinor-libipopt-dev
```

#### macOS

```bash
brew install cbc ipopt scip
```

#### Windows

Using Rtools42:

```bash
pacman -S mingw-w64-x86_64-cbc
pacman -S mingw-w64-x86_64-coin-or-cbc
```

### Install from GitHub

```r
# Install devtools if needed
install.packages("devtools")

# Install RSolvers
devtools::install_github("vasantmv/RSolvers")
```

### Build from Source

```bash
git clone https://github.com/vasantmv/RSolvers.git
cd RSolvers
R CMD INSTALL .
```

## Quick Start

```r
library(RSolvers)

# Define a simple optimization problem
# Maximize: 3*x1 + 5*x2
# Subject to: 2*x1 + x2 <= 4
#            x1, x2 are binary

model <- list(
  obj = c(3, 5),
  mat = matrix(c(2, 1), nrow = 1),
  dir = "<=",
  rhs = 4,
  types = c("B", "B"),
  max = TRUE
)

# Solve with automatic solver selection
solution <- rsolve(model)

print(solution)
# Output:
# RSolvers Solution
# =================
# Solver:    HiGHS
# Status:    optimal
# Objective: 12
# Solution:  1, 1
```

## Usage

### Basic Linear Program

```r
model <- list(
  obj = c(3, 5),              # Objective coefficients
  mat = matrix(c(2, 1,        # Constraint matrix
                 1, 2),
               nrow = 2, byrow = TRUE),
  dir = c("<=", "<="),        # Constraint directions
  rhs = c(4, 3),              # Right-hand side
  types = c("C", "C")         # Variable types (Continuous)
)

sol <- rsolve(model)
```

### Mixed Integer Program

```r
model <- list(
  obj = c(3, 5),
  mat = matrix(c(2, 1), nrow = 1),
  dir = "<=",
  rhs = 4,
  types = c("I", "B"),        # Integer and Binary variables
  max = TRUE                  # Maximization
)

sol <- rsolve(model, solver = "cbc")  # Specify solver explicitly
```

### With Control Parameters

```r
sol <- rsolve(model,
              solver = "auto",
              control = list(
                time_limit = 60,      # Time limit in seconds
                mip_gap = 0.01,       # MIP gap tolerance
                threads = 4           # Number of threads
              ))
```

### Check Available Solvers

```r
# List all available solvers
list_solvers()
# [1] "highs" "cbc" "scip"
```

## Model Specification

The `model` list can contain:

| Field | Type | Description |
|-------|------|-------------|
| `obj` | numeric vector | Objective function coefficients (required) |
| `mat` | matrix | Constraint matrix |
| `dir` | character vector | Constraint directions ("<=", ">=", "==") |
| `rhs` | numeric vector | Right-hand side values |
| `types` | character vector | Variable types ("C", "I", "B") |
| `max` | logical | TRUE for maximization (default: FALSE) |
| `bounds` | list | Variable bounds (lower, upper) |
| `Q` | matrix | Quadratic objective matrix |
| `qc` | list | Quadratic constraints |
| `nl` | list | Nonlinear expressions |
| `problem_type` | character | Problem type (auto-detected if omitted) |

## Supported Solvers

| Solver | Problem Types | Priority | Description |
|--------|--------------|----------|-------------|
| **HiGHS** | LP, MILP, QP, QCQP | 1 | High-performance linear/quadratic solver |
| **CBC** | LP, MILP | 2 | COIN-OR branch-and-cut |
| **SCIP** | LP, MILP, QP, QCQP, NLP, MINLP | 3 | Comprehensive optimization suite |
| **Ipopt** | LP, NLP | 4 | Interior point optimizer |
| **Bonmin** | MINLP | 5 | Basic open-source MINLP |
| **Couenne** | MINLP | 6 | Convex MINLP solver |

*Lower priority number = preferred solver for that problem type*

## Examples

See the `inst/examples/` directory for complete examples:

- `linear.R` - Simple linear programming
- `nlp.R` - Nonlinear programming
- `minlp.R` - Mixed integer nonlinear programming

Run an example:

```r
system.file("examples", "linear.R", package = "RSolvers") |> source()
```

## Comparison with Other Packages

| Feature | RSolvers | rcbc | ROI |
|---------|----------|------|-----|
| Automatic solver selection | ✓ | ✗ | Limited |
| Multiple solver backends | ✓ | ✗ | ✓ |
| MINLP support | ✓ | ✗ | Limited |
| Optional dependencies | ✓ | ✗ | ✓ |
| Single unified interface | ✓ | ✓ | ✗ |

## Development

### Building with Specific Solvers

```bash
# Configure with specific solvers
./configure
make

# Or use R CMD INSTALL
R CMD INSTALL .
```

The configure script will automatically detect available solvers using `pkg-config`.

### Running Tests

```r
devtools::test()
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

**Vasant Mugada** - [vasantmv@outlook.com](mailto:vasantmv@outlook.com)

## Acknowledgments

- COIN-OR project for CBC and Ipopt
- HiGHS development team
- SCIP optimization suite team
- R community for inspiration and support

## References

- [CBC](https://github.com/coin-or/Cbc) - COIN-OR Branch and Cut
- [HiGHS](https://highs.dev/) - High-performance optimization software
- [SCIP](https://www.scipopt.org/) - Solving Constraint Integer Programs
- [Ipopt](https://coin-or.github.io/Ipopt/) - Interior Point Optimizer

## Citation

If you use RSolvers in your research, please cite:

```bibtex
@software{rsolvers2025,
  author = {Mugada, Vasant},
  title = {RSolvers: Universal Open-Source Solver Interface for R},
  year = {2025},
  url = {https://github.com/vasantmv/RSolvers}
}
```

---

**Questions or Issues?** Please open an issue on [GitHub](https://github.com/vasantmv/RSolvers/issues).
