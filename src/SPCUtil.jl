module SPCUtil

using Distributed
using Distributed: SSHManager, LocalManager
using Makie

include("./general.jl")
include("./macros.jl")
include("./makie.jl")
include("./distributed.jl")
include("./sysimage.jl")

# general.jl
export is_logging

# macros.jl
export @once_then

# makie.jl
export align_xlabels!, align_ylabels!

# distributed.jl
export setup_workers

# sysimage.jl
export create_sysimage

end # module SPCUtil
