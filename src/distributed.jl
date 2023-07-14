export setup_workers

# The SLURM_TASKS_PER_NODE environment variable may look like:
# 8,12(x2),5,4(x3)
# where each token is either a number or a number plus repetition.
# Handle both cases with this regexp.
const CPUS_PER_NODE_REGEXP = r"^(\d+)(\(x(\d+)\))?$"

function _get_slurm_cpus_per_node()
    tokens = split(ENV["SLURM_TASKS_PER_NODE"], ",")

    cpus_per_node = Int[]

    while !isempty(tokens)
        token = popfirst!(tokens)
        m = match(CPUS_PER_NODE_REGEXP, token)
        count = parse(Int, m[1])
        repetitions = isnothing(m[3]) ? 1 : parse(Int, m[3])
        append!(cpus_per_node, repeat([count], repetitions))
    end

    return cpus_per_node
end

_get_manager(::Val{:local}; n::Integer) =
    LocalManager(n, true)

function _get_manager(::Val{:slurm}; kw...)
    # get list of all nodes (hostnames) and associated CPU counts
    nodelist_cmd = `scontrol show hostnames $(ENV["SLURM_NODELIST"])`
    nodes = split(readchomp(nodelist_cmd), "\n")
    cpus_per_node = _get_slurm_cpus_per_node()

    machines = collect(zip(nodes, cpus_per_node))
    return SSHManager(machines)
end

function _get_manager(::Val{:auto}; kw...)
    mode = haskey(ENV, "SLURM_JOBID") ? :slurm : :local
    return _get_manager(mode; kw...)
end

_get_manager(mode::Symbol, args...; kw...) = _get_manager(Val(mode), args...; kw...)

function setup_workers(mode = :auto; 
                       n = length(Sys.cpu_info()),
                       exeflags::AbstractVector{<:AbstractString} = String[],
                       topology = :master_worker,
                       kw...)
    if nprocs() > 1
        rmprocs(workers())
    end

    sysimage_file = unsafe_string(Base.JLOptions().image_file)
    project =  unsafe_string(Base.JLOptions().project)
    exeflags_ = ["--project=$project", "--sysimage=$sysimage_file"]
    append!(exeflags_, exeflags)

    mgr = _get_manager(mode; n = n)

    addprocs(mgr, exeflags = exeflags_, topology = topology; kw...)
    nothing
end