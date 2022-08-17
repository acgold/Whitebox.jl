# Whitebox.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://acgold.github.io/Whitebox.jl/dev/)
[![Build Status](https://github.com/acgold/Whitebox.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/acgold/Whitebox.jl/actions/workflows/CI.yml?query=branch%3Amain)
<!-- [![Coverage](https://codecov.io/gh/acgold/Whitebox.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/acgold/Whitebox.jl) -->

## A Julia frontend for WhiteboxTools

[WhiteboxTools](https://github.com/jblindsay/whitebox-tools) is an open-source command-line program for geospatial analysis created by [Dr. John Lindsay](https://jblindsay.github.io/ghrg/index.html).

**Whitebox.jl** installs **WhiteboxTools** (**v2.1.0**) and allows users to run any **WhiteboxTools** function from Julia.

### Notes

- **Whitebox.jl** is not affiliated with **WhiteboxTools**. 
- This package is in active development and testing.
- Report bugs [here](https://github.com/acgold/Whitebox.jl/issues).

# Installation

**Whitebox.jl** can be installed from the Pkg REPL (press `]` in the Julia REPL):

```julia
pkg> add Whitebox
```

Or directly from GitHub:

```julia
using Pkg
Pkg.add(url = "https://github.com/acgold/Whitebox.jl.git")
```
Installing **Whitebox.jl** will automatically install a version of **WhiteboxTools** within the **Whitebox.jl** package directory (see more about this in [How it works](https://acgold.github.io/Whitebox.jl/dev/how_it_works))

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

# Getting Started

## Load the package

Load **Whitebox.jl** into your project with:
```julia
import Whitebox as wbt
```

Loading the package automatically configures your **WhiteboxTools** session by: 
- Setting the working directory for **WhiteboxTools** to your current working directory (found with `pwd()`)
- Setting the the path to the **WhiteboxTools** version that was installed with **Whitebox.jl**
- Setting up miscellaneous defaults such as the printing of results

In other words, just load the package and you should be good to go! Read more about this in [How it works](@ref).

## Find tools

**WhiteboxTools** contains approximately [485 tools](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/index.html) that are organized into the following thematic toolboxes:
- [Data Tools](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/data_tools.html)
- [Geomorphometric Analysis](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/geomorphometric_analysis.html)
- [GIS Analysis](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/gis_analysis.html)
- [Hydrologic Analysis](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/hydrological_analysis.html)
- [Image Analysis](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/image_processing_tools.html)
- [LiDAR Analysis](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/lidar_tools.html)
- [Mathematical and Statistical Analysis](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/mathand_stats_tools.html)
- [Precision Agriculture](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/precision_agriculture.html)
- [Stream Network Analysis](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/stream_network_analysis.html)

**Whitebox.jl** provides a function to use each of the the tools provided by **WhiteboxTools**. Functions in **Whitebox.jl** use the snake_case convention for **WhiteboxTools** tool names. 

For example, to use the [`AbsoluteValue` tool](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/mathand_stats_tools.html?highlight=AbsoluteValue#absolutevalue), you would use `wbt.absolute_value()`. 

View the **Whitebox.jl** [Reference](https://acgold.github.io/Whitebox.jl/dev/reference) section for a full list of available functions and documentation. 

## Run tools

Function arguments for **Whitebox.jl** functions are [keyword arguments](https://docs.julialang.org/en/v1/manual/functions/#Keyword-Arguments), so the arguments must be included in the function call.

For example, use: 
```julia
wbt.absolute_value(i = "DEM.tif", output = "abs_val.tif") # This works! 💯 🎉
```
rather than:
```julia
wbt.absolute_value("DEM.tif", "abs_val.tif") # <- This won't work! 👎
```

## Function help
We have a few different ways to find the required arguments or documentation for a function:
- Visit the [WhiteboxTools user manual](https://www.whiteboxgeo.com/manual/wbt_book/available_tools/index.html) and look at the Python example for a function (those use snake_case too)
- Run `wbt.tool_parameters(tool_name::String)`, or
- Enter `help?>` mode in the Julia REPL (Press `?`), and search your function name


# How it works

## Getting **WhiteboxTools**

**Whitebox.jl** depends on the [**WhiteboxTools_jll.jl**](https://github.com/JuliaBinaryWrappers/WhiteboxTools_jll.jl) package to provide a build of **WhiteboxTools**.

The **WhiteboxTools_jll.jl** repo says: 

>"This is an autogenerated package constructed using [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl). The originating build_tarballs.jl script can be found on [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil/), the community build tree. If you have any issue, please report it to the Yggdrasil [bug tracker](https://github.com/JuliaPackaging/Yggdrasil/issues).
>
>For more details about JLL packages and how to use them, see BinaryBuilder.jl [documentation](https://juliapackaging.github.io/BinaryBuilder.jl/dev/jll/)."

## Setting defaults

Loading the **Whitebox.jl** package will automatically create an object containing info about default parameters, the working directory, and location of WhiteboxTools. 

This object is called `wbt_info`, and it is a struct of type **WhiteboxTools**.

Users can use `dump` to view all its info:
```julia 
dump(wbt.wbt_info)

# Whitebox.WhiteboxTools
#   exe_name: String "whitebox_tools"
#   exe_path: String "/Users/.../bin/whitebox_tools"
#   work_dir: String "/Users/...your_wd"
#   verbose: Bool true
#   cancel_op: Bool false
#   default_callback: default_callback (function of type typeof(Whitebox.default_callback))
#   start_minimized: Bool false
#   __compress_rasters: Bool false
```

Every function in the **Whitebox.jl** package requires an object of type **WhiteboxTools**, and every function uses the `wbt_info` object as the default.

To change the default settings of the **WhiteboxTools** program for your session, you should change them using the provided functions.

For example:
```julia
wbt.set_verbose_mode(false)
```

## Generating functions

Most of the functions in this package were generated using the included `whitebox_plugin_generator.py`. This file was adapted from the file of the same name in the **WhiteboxTools** [repo](https://github.com/jblindsay/whitebox-tools/blob/master/whitebox_plugin_generator.py)

Using a python script was intentional so that future updates or added functions could be generated from the Python package.

Some additional changes to the generated functions were required:
- `wbt.multiscale_topographic_position_image`: changed `local` input argument references to `localrast`. `local` is a reserved word for Julia.
- `wbt.conditional_evaluation`: `true` and `false` input arguments were changed to `True` and `False`. 
