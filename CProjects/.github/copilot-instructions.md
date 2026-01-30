# Copilot Instructions for CProjects C++ Codebase

## Architecture Overview

This is a **scientific computing library** focused on numerical optimization, statistical distributions, and time series analysis. Built on Eigen for linear algebra and Boost for utilities.

### Core Modules (in dependency order)

1. **EigenTools** (`EigenTools/`)
   - Linear algebra utilities wrapping Eigen
   - Matrix I/O (CSV writing), vector operations, sparse matrices
   - Used by all other modules

2. **Distributions** (`Distributions/`)
   - Statistical distributions (normal, student-t, etc.)
   - Depends on header-only libraries: GCEM, stats (from external dependencies)
   - Provides probability functions for modeling

3. **OptimizationTools** (`OptimizationTools/`)
   - **BFGS** unconstrained optimization with numerical differentiation
   - Line search methods (golden section, cubic interpolation, zoom algorithm)
   - Key classes: `Optimize`, `LineSearchRoutines`, `NumericalDifferentiation`
   - Simplex linear programming solver (incomplete)

4. **GnuPlotting** (`GnuPlotting/`)
   - Visualization via Gnuplot (`Plotter` class)
   - Depends on EigenTools

5. **TimeSeries** (`TimeSeries/`)
   - Time series modeling (VAR, AR models)
   - Depends on Distributions, EigenTools

6. **MultilevelModel** (`MultilevelModel/`)
   - Hierarchical/multilevel statistical models
   - Building block for higher-level applications

7. **MVProbit** (`MVProbit/`)
   - Multivariate probit models
   - Active executables: `fps` (factor probit simulations), `rp` (recession probability)
   - Integrates all lower-level modules

## Build System

**Tool**: CMake 3.20+, C++17 standard

### Build Steps
```bash
cd /home/dillon/CodeProjects/CProjects
mkdir build && cd build
cmake ..
cmake --build . --config Debug  # or Release
```

### Build Configuration
- **Output**: Binaries go to `build/` directory
- **Optimization flags** (Release): `-O3 -march=native -fopenmp -ffast-math`
- **Dependencies** (configured in `cmake/cmake_config.cmake`):
  - Eigen 3.4.0 (header-only linear algebra)
  - Boost 1.76+ (utilities)
  - GCEM (header-only math)
  - stats library (header-only distributions)
  - ccache (auto-detected for build acceleration)

### Library Targets
- `optlib` – optimization algorithms (static)
- `Dist` – statistical distributions (static)
- `ettools` – Eigen utilities (static)
- `plot` – Gnuplot interface (static)
- `fort` – table formatting (static)

### Running Tests
- `OptimizationTools/Test_Optimization.cpp` – BFGS convergence tests
- Tests are **manually selected**, not part of automated test suite

## Key Patterns & Conventions

### Header Organization
- Headers in `*/include/*.hpp`, implementations in `*/src/*.cpp`
- All headers use `#pragma once` + `#ifndef` guards
- Std namespace imported globally: `using namespace std; using namespace Eigen;`

### Function Signatures
Heavy use of **lambda functions** and `std::function`:
```cpp
// Optimization callbacks take const reference to Eigen vectors
std::function<double(const Ref<const VectorXd> &xstar)> F
```

### Numerical Methods
- **Eigen::Ref** used throughout to avoid copies (performance critical)
- Eigen::Map for zero-copy data wrapping
- Macro constants for floating-point thresholds:
  ```cpp
  #define EPS numeric_limits<long double>::epsilon()
  #define SEPS sqrt(EPS)  // step size for numerical differentiation
  #define GR (0.5 * (sqrt(5) + 1))  // golden ratio for line search
  ```

### Differentiation Strategy
Numerical differentiation (forward/central differences) instead of analytical – enables gradient-free optimization. Used by:
- `NumericalDifferentiation::ForwardDifferences()` 
- `NumericalDifferentiation::CentralDifferences()`
- `NumericalDifferentiation::ApproximateHessian()` (BFGS uses this)

## Editing Conventions

- **Formatting**: `.clang-format` configured (LLVM-based style)
- **Namespace**: No explicit namespaces; global std/Eigen used
- **File extensions**: `.hpp` for headers, `.cpp` for implementations

## Critical Development Workflows

### Adding New Optimization Algorithms
1. Inherit from `LineSearchRoutines` (provides line search + differentiation)
2. Define solver in `Optimize` class in `Optimization.hpp`
3. Add test case in `Test_Optimization.cpp` with lambda objective

### Adding New Distributions
1. Implement in `Distributions.cpp` 
2. Forward declarations in `Distributions.hpp`
3. Use external `stats` library for special functions

### Creating Executables
Always use `target_include_directories()` to include all module paths:
```cmake
target_include_directories(myexe PRIVATE
    ${EIGEN_INCLUDE_DIR}
    ${BOOST_INCLUDEDIR}
    ${CMAKE_SOURCE_DIR}/OptimizationTools/include
    ${CMAKE_SOURCE_DIR}/Distributions/include
)
```

## Common Debugging Points

- **Numerical stability**: Gradient-free optimization can be slow; use forward differences for debugging, central differences for accuracy
- **Convergence issues**: Check `grad_tol`, `F_tol`, `x_tol` thresholds in `Optimize` class
- **Eigen alignment**: If using fixed-size matrices/vectors in classes, mark `EIGEN_MAKE_ALIGNED_OPERATOR_NEW`
- **Include order**: Module-specific headers after standard library includes

## Active Development Areas

- `OptimizationTools/` – main focus (BFGS, line search)
- `MVProbit/` – statistical modeling applications
- `TimeSeries/` – time series analysis
- Many modules have commented-out executables; enable selectively as needed
