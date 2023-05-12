function setup_workers(; kw...)
    sysimage_file = unsafe_string(Base.JLOptions().image_file)
    project =  unsafe_string(Base.JLOptions().project)
    exeflags = ["--project=$project", "--sysimage=$sysimage_file"]

    mgr = if haskey(ENV, "SLURM_JOBID")
        # A kludge. Could use the SlurmManager from either ClusterManagers or
        # SlurmClusterManager, but the NEU discovery cluster disables srun 
        # from interactive jobs. This approach works on any SLURM cluster.

        # get list of all nodes (hostnames)
        cmd = `scontrol show hostnames $(ENV["SLURM_NODELIST"])`
        nodes = split(readchomp(cmd), "\n")

        # get CPUs assigned to each node
        cpus_per_node = [parse(Int64, x) for x in split(ENV["SLURM_TASKS_PER_NODE"], ",")]

        machines = collect(zip(nodes, cpus_per_node))
        SSHManager(machines)
    else
        # if local, add all CPU cores
        total_procs = length(Sys.cpu_info())
        n = max(total_procs - nprocs(), 0)
        LocalManager(n)
    end
    addprocs(mgr, exeflags=exeflags, topology=:master_worker; kw...)
end