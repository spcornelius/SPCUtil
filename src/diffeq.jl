function SciMLBase.solve_batch(prob::EnsembleProblem, alg, ensemblealg::EnsembleDistributed, 
                               II, pmap_batch_size; progress::Union{Bool, Progress}=false, 
                               kwargs...)
    
    wp = CachingPool(workers())

    progress = isa(progress, Progress) ? progress : Progress(length(II), enabled=progress)
    batch_data = progress_pmap(wp, II, progress=progress, 
                               batch_size = pmap_batch_size) do i
        batch_func(i, prob, alg; kwargs...)
    end
    tighten_container_eltype(batch_data)
end

function SciMLBase.solve_batch(prob, alg, ensemblealg::EnsembleThreads, II, pmap_batch_size;
                               progress::Union{Bool, Progress}=false, kwargs...)
    nthreads = min(Threads.nthreads(), length(II))
    if length(II) == 1 || nthreads == 1
        return solve_batch(prob, alg, EnsembleSerial(), II, pmap_batch_size; kwargs...)
    end

    progress = isa(progress, Progress) ? progress : Progress(length(II), enabled=progress)

    if typeof(prob.prob) <: AbstractJumpProblem && length(II) != 1
        probs = [deepcopy(prob.prob) for i in 1:nthreads]
    else
        probs = prob.prob
    end

    batch_data = SciMLBase.tmap(II) do i
        result = batch_func(i, prob, alg; kwargs...)
        next!(progress)
        result
    end

    tighten_container_eltype(batch_data)
end