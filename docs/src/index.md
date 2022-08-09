```@meta
CurrentModule = Whitebox
```

# Whitebox.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://acgold.github.io/Whitebox.jl/dev/)
[![Build Status](https://github.com/acgold/Whitebox.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/acgold/Whitebox.jl/actions/workflows/CI.yml?query=branch%3Amain)
<!-- [![Coverage](https://codecov.io/gh/acgold/Whitebox.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/acgold/Whitebox.jl) -->

[Link to GitHub Repo](https://github.com/acgold/Whitebox.jl)

## A Julia frontend for WhiteboxTools

[WhiteboxTools](https://github.com/jblindsay/whitebox-tools) is an open-source command-line program for geospatial analysis created by [Dr. John Lindsay](https://jblindsay.github.io/ghrg/index.html).

**Whitebox.jl** installs **WhiteboxTools** and allows users to run any **WhiteboxTools** function from Julia.

### Notes

- **Whitebox.jl** is not affiliated with **WhiteboxTools**. 
- This package is in active development and testing.
- Report bugs [here](https://github.com/acgold/Whitebox.jl/issues).

# Installation

**Whitebox.jl** can be installed directly from GitHub:

```julia
using Pkg
Pkg.add(url = "https://github.com/acgold/Whitebox.jl.git")
```
Installing **Whitebox.jl** will automatically install a version of **WhiteboxTools** within the **Whitebox.jl** package directory (see more about this in [How it works](@ref))

# Quick Example

Adapted from the [Python frontend example](https://github.com/giswqs/whitebox-python#quick-example).

```julia
import Whitebox as wbt

# Some helper functions
wbt.version()
wbt.help()

# Set working directory to your data location. By default, it is your project's working directory (found via `pwd()`)
wbt.set_working_dir(joinpath(pwd(),"Data"))

# Set the verbose mode to `false` if you want less printing
wbt.set_verbose_mode(false)

# Run some hydrology tools!
wbt.feature_preserving_smoothing(dem = "DEM.tif", output = "smoothed.tif")
wbt.breach_depressions(dem = "smoothed.tif", output = "breached.tif")
wbt.d_inf_flow_accumulation(i = "breached.tif", output = "flow_accum.tif")

```