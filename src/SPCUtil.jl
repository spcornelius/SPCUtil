module SPCUtil

using Distributed
using Distributed: SSHManager, LocalManager
using Makie

include("./makie.jl")
include("./distributed.jl")
include("./sysimage.jl")

# makie.jl
export align_xlabels!, align_ylabels!

# distributed.jl
export setup_workers

# sysimage.jl
export create_sysimage

end # module SPCUtil
