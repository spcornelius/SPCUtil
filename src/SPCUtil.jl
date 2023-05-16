module SPCUtil

using Distributed
using Distributed: SSHManager, LocalManager
using Makie

include("./makie.jl")
include("./slurm.jl")
include("./sysimage.jl")

# makie.jl
export align_xlabels!, align_ylabels!

# slurm.jl
export setup_workers

# sysimage.jl
export create_sysimage

end # module SPCUtil
