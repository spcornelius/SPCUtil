module SPCUtil

using ArgParse
using Distributed
using Distributed: SSHManager, LocalManager
using Makie
using PackageCompiler
using Pkg
using ProgressMeter
using SciMLBase
import SciMLBase: solve_batch
using SciMLBase: AbstractEnsembleSolution, AbstractTimeseriesSolution, 
                 AbstractJumpProblem, batch_func, tighten_container_eltype

include("./argparse.jl")
include("./general.jl")
include("./diffeq.jl")
include("./macros.jl")
include("./makie.jl")
include("./distributed.jl")
include("./sysimage.jl")

end # module SPCUtil
