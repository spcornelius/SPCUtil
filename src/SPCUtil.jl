module SPCUtil

using Distributed
using SlurmClusterManager

include("./slurm.jl")

export setup_workers

end # module SPCUtil
