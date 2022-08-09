module Whitebox

import WhiteboxTools_jll as WBT_jll
using Downloads
using ZipFile
using OutputCollectors
using DefaultApplication

include("whitebox_tools.jl")
include("whitebox_convenience_functions.jl")

const wbt_info = WhiteboxTools()

end
