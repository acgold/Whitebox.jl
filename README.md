# Whitebox.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://acgold.github.io/Whitebox.jl/dev/)
[![Build Status](https://github.com/acgold/Whitebox.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/acgold/Whitebox.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/acgold/Whitebox.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/acgold/Whitebox.jl)

## WhiteboxTools Julia frontend

[WhiteboxTools](https://github.com/jblindsay/whitebox-tools) is an open-source command-line program for geospatial analysis created by [Dr. John Lindsay](https://jblindsay.github.io/ghrg/index.html).

This package is a work-in-progress and is not affiliated with WhiteboxTools.

Modeled after the [Python frontend](https://github.com/giswqs/whitebox-python).

# Example
All functions can be performed using the`run_tools` function.

```julia
wbt = WhiteboxTools()
tool_name = "centroid_vector"
args = ["-i=Data/polygons.shp", "-o=Data/centroids.shp"]

z = run_tool(wbt, "intersect"; args=["-i=Data/polygons.shp", "--overlay=Data/buff_centroid.shp", "-o=Data/int_test.shp"])
```
```julia
****************************
* Welcome to Intersect     *
* Powered by WhiteboxTools *
* www.whiteboxgeo.com      *
****************************
Reading data...
Progress: 62%
Progress: 75%
Progress: 87%
Progress: 100%
Saving data...
Output file written
Elapsed Time: 0.10s
Success!
0
```