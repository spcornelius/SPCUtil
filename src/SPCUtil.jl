module SPCUtil

using Distributed
using Makie
using SlurmClusterManager

include("./makie.jl")
include("./slurm.jl")

# makie.jl
export align_xlabels!, align_ylabels!

# slurm.jl
export setup_workers

end # module SPCUtil
