function setup_workers(; kw...)
    sysimage_file = unsafe_string(Base.JLOptions().image_file)
    project =  unsafe_string(Base.JLOptions().project)
    exeflags = ["--project=$project", "--sysimage=$sysimage_file"]

    # if local, add all but one CPU core as workers
    total_procs = length(Sys.cpu_info())
    n = max(total_procs - 1 - nprocs(), 0)

    mgr = haskey(ENV, "SLURM_JOBID") ? SlurmManager() : 
        Distributed.LocalManager(n, true)
    addprocs(mgr, exeflags=exeflags, topology=:master_worker; kw...)
end