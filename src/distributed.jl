_get_manager(::Val{:local}; n::Integer) =
    LocalManager(n, true)

function _get_manager(::Val{:slurm}; kw...)
    # get list of all nodes (hostnames)
    cmd = `scontrol show hostnames $(ENV["SLURM_NODELIST"])`
    nodes = split(readchomp(cmd), "\n")

    # get number of CPUs assigned to each node
    tokens = split(ENV["SLURM_TASKS_PER_NODE"], ",")
    regexp = r"^(\d+)(\(x(\d+)\))?$"

    cpus_per_node = Int[]

    while !isempty(tokens)
        token = popfirst!(tokens)
        m = match(regexp, token)
        count = parse(Int, m[1])
        repetitions = isnothing(m[3]) ? 1 : parse(Int, m[3])
        append!(cpus_per_node, repeat([count], repetitions))
    end

    machines = collect(zip(nodes, cpus_per_node))
    return SSHManager(machines)
end

function _get_manager(::Val{:auto}; kw...)
    mode = haskey(ENV, "SLURM_JOBID") ? :slurm : :local
    return _get_manager(mode; kw...)
end

_get_manager(mode::Symbol; kw...) = _get_manager(Val(mode); kw...)

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