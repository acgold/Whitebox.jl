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

View the **Whitebox.jl** [Reference](@ref) section for a full list of available functions and documentation. 

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
