module SPCUtil

using Distributed
using Distributed: SSHManager, LocalManager
using Makie
using ProgressMeter
using SciMLBase
import SciMLBase: solve_batch
using SciMLBase: AbstractEnsembleSolution, AbstractTimeseriesSolution, 
                 AbstractJumpProblem, batch_func, tighten_container_eltype

include("./general.jl")
include("./diffeq.jl")
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
