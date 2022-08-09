import WhiteboxTools_jll as WBT_jll
using Downloads
using ZipFile
using OutputCollectors
using DefaultApplication

###############################################
####### Additional license information ########
###############################################

# The WhiteboxTools_jll.jl package was created by BinaryBuilder.jl (https://github.com/JuliaBinaryWrappers/WhiteboxTools_jll.jl)
# and wraps the MIT-licensed WhiteboxTools software by Dr. John Lindsay. The license information for WhiteboxTools is shown below
# and linked here: https://github.com/jblindsay/whitebox-tools/blob/master/LICENSE.txt.
#
# "The MIT License (MIT)

# Copyright (c) 2017-2021 John Lindsay

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE."


# Code in this file was adapted to Julia from the Python frontend for WhiteboxTools, and most
# function descriptions were copied directly (https://github.com/giswqs/whitebox-python). The
# license information for the Python frontend of WhiteboxTools is shown below and is linked 
# here: https://github.com/giswqs/whitebox-python/blob/master/LICENSE).
#
# "MIT License
#
# Copyright (c) 2018, Qiusheng Wu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE."

###########################
####### Julia code ########
###########################

"""
    default_callback(value)

A simple default callback that outputs using the print function. When
tools are called without providing a custom callback, this function
will be used to print to standard output.
"""
function default_callback(value)
    println(value)
end


Base.@kwdef mutable struct WhiteboxTools
    exe_name::String = "whitebox_tools"
    exe_path::String = WBT_jll.whitebox_tools_path
    work_dir::String = pwd()
    verbose::Bool = true
    cancel_op::Bool = false
    default_callback::Function = default_callback
    start_minimized::Bool = false
    __compress_rasters::Bool = false
end

"""
    to_camelcase(name::String)

Convert snake_case name to CamelCase name 
"""
function to_camelcase(name::String)
    return join([uppercasefirst(x) for x in split(name, '_')])
end


"""
    to_snakecase(name::String)

Convert CamelCase name to snake_case name 
"""
function to_snakecase(name::String)
    wordpat = r"
    ^[a-z]+ |                  #match initial lower case part
    [A-Z][a-z]+ |              #match Words Like This
    \d*([A-Z](?=[A-Z]|$))+ |   #match ABBREV 30MW 
    \d+                        #match 1234 (numbers without units)
    "x

    smartlower(x) = any(islowercase, x) ? lowercase(x) : x
    words = [smartlower(m.match) for m in eachmatch(wordpat, name)]


    return join(words, "_")
end


"""
    set_whitebox_dir(path_str::String, wbt_info::WhiteboxTools = wbt_info)

Sets the directory to the WhiteboxTools executable file.
"""
function set_whitebox_dir(path_str::String, wbt_info::WhiteboxTools = wbt_info)
    wbt_info.exe_path = path_str
end


"""
    set_working_dir(path_str::String, wbt_info::WhiteboxTools = wbt_info)

Sets the working directory, i.e. the directory in which
the data files are located. By setting the working 
directory, tool input parameters that are files need only
specify the file name rather than the complete file path.
"""
function set_working_dir(path_str::String, wbt_info::WhiteboxTools = wbt_info)
    wbt_info.work_dir = normpath(path_str)
end


"""
    set_whitebox_dir(path_str::String, wbt_info::WhiteboxTools = wbt_info)

Sets the directory to the WhiteboxTools executable file.
"""
function set_whitebox_dir(path_str::String, wbt_info::WhiteboxTools = wbt_info)
    wbt_info.exe_path = path_str
end


"""
    set_verbose_mode(val::Bool=true, wbt_info::WhiteboxTools = wbt_info)

Sets verbose mode. If verbose mode is False, tools will not
print output messages. Tools will frequently provide substantial
feedback while they are operating, e.g. updating progress for 
various sub-routines. When the user has scripted a workflow
that ties many tools in sequence, this level of tool output
can be problematic. By setting verbose mode to False, these
"""
function set_verbose_mode(val::Bool=true, wbt_info::WhiteboxTools = wbt_info)

    wbt_info.verbose = val

    args2 = []

    push!(args2, wbt_info.exe_path)

    if wbt_info.verbose === true
        push!(args2, "-v")
    else
        push!(args2, "-v=false")
    end

    wbt_info.default_callback(strip(join(args2, " ")))

    proc = nothing

    proc = run(`$args2`, wait=true)

    if success(proc) === true
        return 0
    else
        error("There was a problem.")
        return 1
    end
end


"""
    set_compress_rasters(compress_rasters::Bool, wbt_info::WhiteboxTools = wbt_info)
    
Sets the flag used by WhiteboxTools to determine whether to use compression for output rasters.
"""
function set_compress_rasters(compress_rasters::Bool, wbt_info::WhiteboxTools = wbt_info)
    wbt_info.__compress_rasters = compress_rasters
end

function get_compress_rasters(wbt_info::WhiteboxTools=wbt_info)
    return wbt_info.__compress_rasters
end


"""
    run_tool(tool_name::String, wbt_info::WhiteboxTools = wbt_info; callback=nothing, args::Union{Nothing, Vector{Any}}=nothing)

Runs a tool and specifies tool arguments.
Returns 0 if completes without error.
Returns 1 on error with details.
# Returns 2 if process is cancelled by user.
"""
function run_tool(tool_name::String, wbt_info::WhiteboxTools = wbt_info; callback=nothing, args::Union{Nothing,Vector{Any}}=nothing)
    if callback === nothing
        callback = wbt_info.default_callback
    end

    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "--run=" * to_camelcase(tool_name))

    if strip(wbt_info.work_dir) !== ""
        push!(args2, "--wd=" * wbt_info.work_dir)
    end

    if args !== nothing
        for x in args
            push!(args2, x)
        end
    end

    if wbt_info.__compress_rasters === true
        push!(args, "--compress_rasters")
    end

    if wbt_info.verbose === true
        cl = join(args2, " ")
        callback(strip(cl))
    end

    proc = nothing

    proc = run(`$args2`, wait=true)

    if success(proc) === true
        println("Success!")
        return 0
    else
        error("There was a problem.")
        return 1
    end
end

"""
    help(wbt_info::WhiteboxTools = wbt_info)

Retrieves the help description for WhiteboxTools.
"""
function help(wbt_info::WhiteboxTools = wbt_info)

    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "-h")

    proc = run(`$args2`, wait=true)

    if success(proc) === true
        return
    else
        error("There was a problem.")
    end
end


"""
    license(tool_name::Union{Nothing, String} = nothing, wbt_info::WhiteboxTools = wbt_info)

Retrieves the license information for WhiteboxTools.
"""
function license(tool_name::Union{Nothing,String}=nothing, wbt_info::WhiteboxTools = wbt_info)
    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "--license")

    if tool_name !== nothing
        push!(args, "f=" * to_camelcase(tool_name))
    end

    proc = run(`$args2`, wait=true)

    if success(proc) === true
        return
    else
        error("There was a problem.")
    end
end


"""
    version(wbt_info::WhiteboxTools = wbt_info)

Retrieves the version information for WhiteboxTools.
"""
function version(wbt_info::WhiteboxTools = wbt_info)
    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "--version")

    proc = run(`$args2`, wait=true)

    if success(proc) === true
        return
    else
        error("There was a problem.")
    end
end


"""
    tool_help(tool_name::String, wbt_info::WhiteboxTools = wbt_info)

Retrieves the help description for a specific tool.
"""
function tool_help(tool_name::String, wbt_info::WhiteboxTools = wbt_info)
    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "--toolhelp=" * to_camelcase(tool_name))

    proc = run(`$args2`, wait=true)

    if success(proc) === true
        return
    else
        error("There was a problem.")
    end
end


"""
    tool_parameters(tool_name::String, wbt_info::WhiteboxTools = wbt_info; return_obj::Bool = false)

Retrieves the tool parameter descriptions for a specific tool.
"""
function tool_parameters(tool_name::String, wbt_info::WhiteboxTools = wbt_info)
    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "--toolhelp=" * to_camelcase(tool_name))

    proc = run(`$args2`, wait=true)

    if success(proc) === true
        return
    else
        error("There was a problem.")
    end
end


"""
    toolbox(tool_name::String="", wbt_info::WhiteboxTools = wbt_info; return_obj::Bool=false)

Retrieves the toolbox for a specific tool.
"""
function toolbox(tool_name::String="", wbt_info::WhiteboxTools = wbt_info)
    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "--toolbox=" * to_camelcase(tool_name))

    proc = run(`$args2`, wait=true)

    if success(proc) === true
        return
    else
        error("There was a problem.")
    end
end


"""
    view_code(tool_name::String, wbt_info::WhiteboxTools = wbt_info)

Opens a web browser to view the source code for a specific tool
on the projects source code repository.
"""
function view_code(tool_name::String, wbt_info::WhiteboxTools = wbt_info)
    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "--viewcode=" * to_camelcase(tool_name))

    proc = OutputCollectors.OutputCollector(`$args2`, verbose=false);

    is_success = wait(proc)

    if is_success === true
        out = collect_stdout(proc)
        DefaultApplication.open(chomp(out))
        return 
    else
        error(collect_stderr(proc))
    end
end


"""
    list_tools(keywords::Vector{String}=[""], wbt_info::WhiteboxTools = wbt_info; return_obj::Bool = false)

Lists all available tools in WhiteboxTools.
"""
function list_tools(keywords::Vector{String}=[""], wbt_info::WhiteboxTools = wbt_info; return_obj::Bool = false)
    args2 = []

    push!(args2, wbt_info.exe_path)

    push!(args2, "--listtools=")

    if length(keywords) > 0
        for kw in keywords
            push!(args2, kw)
        end
    end

    proc = OutputCollectors.OutputCollector(`$args2`, verbose=false);

    is_success = wait(proc)

    if is_success === true
        out = collect_stdout(proc)

        if return_obj === false
            println(out)
            return nothing
        end

        tool_list = String.(reduce(vcat, split.(out, "\n")));
        popfirst!(tool_list);
        return tool_list[tool_list .!== ""]
    else
        error(collect_stderr(proc))
    end
end


"""
    unzip(file::String; exdir::String="")

Unzip a .zip folder and put contents in exdir. 

Modified from https://discourse.julialang.org/t/how-to-extract-a-file-in-a-zip-archive-without-using-os-specific-tools/34585
"""
function unzip(file::String; exdir::String="")
    fileFullPath = isabspath(file) ? file : joinpath(pwd(), file)
    basePath = dirname(fileFullPath)
    outPath = (exdir == "" ? basePath : (isabspath(exdir) ? exdir : joinpath(pwd(), exdir)))
    isdir(outPath) ? "" : mkdir(outPath)
    zarchive = ZipFile.Reader(fileFullPath)
    for f in zarchive.files
        fullFilePath = joinpath(outPath, f.name)
        if (endswith(f.name, "/") || endswith(f.name, "\\"))
            mkdir(fullFilePath)
        else
            write(fullFilePath, read(f))
        end
    end
    close(zarchive)
end


function activate_license()
    try
        if Sys.iswindows() === true
            run(`start ./plugins/register_license.exe`)
        else
            run(`run ./plugins/register_license`)
        end
    catch e
        error("Unexpected error:", e)
        println("Please contact support@whiteboxgeo.com if you continue to experience issues.")
    end
end


function install_wbt_extension(ext_name::String="", wbt_info::WhiteboxTools = wbt_info)
    try
        if length(ext_name) === 0
            printstyled("Which extension would you like to install? (gte/lidar/dem/agri)\n", color=:yellow)
            ext_name = readline();
        end

        # Figure out the appropriate URL to download the extension binary from.
        url = "https://www.whiteboxgeo.com/GTE_Windows/GeneralToolsetExtension_win.zip" # default
        unzipped_dir_name = "GeneralToolsetExtension"

        if occursin("agri", lowercase(ext_name)) === true
            if Sys.iswindows() === true
                url = "https://www.whiteboxgeo.com/AgricultureToolset/AgricultureToolset_win.zip"
            elseif Sys.isapple === true
                url = "https://www.whiteboxgeo.com/AgricultureToolset/AgricultureToolset_MacOS_Intel.zip"
            elseif Sys.islinux === true
                url = "https://www.whiteboxgeo.com/AgricultureToolset/AgricultureToolset_linux.zip"
            end

            unzipped_dir_name = "AgricultureToolset"

        elseif occursin("dem", lowercase(ext_name)) === true
            if Sys.iswindows() === true
                url = "https://www.whiteboxgeo.com/DemAndSpatialHydrologyToolset/DemAndSpatialHydrologyToolset_win.zip"
            elseif Sys.isapple() === true
                url = "https://www.whiteboxgeo.com/DemAndSpatialHydrologyToolset/DemAndSpatialHydrologyToolset_MacOS_Intel.zip"
            elseif Sys.islinux() === true
                url = "https://www.whiteboxgeo.com/DemAndSpatialHydrologyToolset/DemAndSpatialHydrologyToolset_linux.zip"
            end

            unzipped_dir_name = "DemAndSpatialHydrologyToolset"

        elseif occursin("lidar", lowercase(ext_name)) === true
            if Sys.iswindows() === true
                url = "https://www.whiteboxgeo.com/LidarAndRemoteSensingToolset/LidarAndRemoteSensingToolset_win.zip"
            elseif Sys.isapple() === true
                url = "https://www.whiteboxgeo.com/LidarAndRemoteSensingToolset/LidarAndRemoteSensingToolset_MacOS_Intel.zip"
            elseif Sys.islinux() === true
                url = "https://www.whiteboxgeo.com/LidarAndRemoteSensingToolset/LidarAndRemoteSensingToolset_linux.zip"
            end

            unzipped_dir_name = "LidarAndRemoteSensingToolset"

        else # default to the general toolset
            if occursin("gte", lowercase(ext_name)) === false
                println("Warning: Unrecognized extension ext_name '" * ext_name * "'. Installing the GTE instead...")
            end

            if Sys.isapple() === true
                url = "https://www.whiteboxgeo.com/GTE_Darwin/GeneralToolsetExtension_MacOS_Intel.zip"
            elseif Sys.islinux() === true
                url = "https://www.whiteboxgeo.com/GTE_Linux/GeneralToolsetExtension_linux.zip"
            end
        end

        # Download the extension binary
        println("Downloading extension plugins...")
        compressed_plugins_file = Downloads.download(url)

        # Save it to a zip then decompress it and move the files to the plugins folder.
        println("Installing extension plugins...")
        zipdir = ZipFile.Writer("./compressed_plugins.zip")

        f = open(compressed_plugins_file, "r+")
        content = read(f)
        close(f)

        zf = ZipFile.addfile(zipdir, unzipped_dir_name)
        write(zf, content)
        close(zipdir)

        if ispath("./plugins") === false
            mkdir("./plugins")
        end

        unzip("compressed_plugins.zip"; exdir="plugins")

        println(
            """
            You will need to activate a license before using this extension. If you do 
            not currently have a valid activation key, you may purchase one by visiting 
            https://www.whiteboxgeo.com/extension-pricing/""")

        # Does the user want to register an activation key for this extension?
        printstyled("Would you like to activate a license key for the extension now? (Y/n) \n", color=:yellow)
        reply = readline();

        if occursin("y", lowercase(reply))
            activate_license()
        else
            println(
                """
                Okay, that's it for now.
                """)
        end

    catch e
        error("Unexpected error:", e)
        println("Please contact support@whiteboxgeo.com if you continue to experience issues.")
    end
end