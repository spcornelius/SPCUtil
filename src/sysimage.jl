import Pkg
import PackageCompiler

function create_sysimage(; kw...)
    project_root = dirname(dirname(@__FILE__))

    deps = Pkg.dependencies()

    # Only include direct dependencies of project. Also, only include
    # packages from a registry (i.e., exclude github, etc.)
    pkgs = [Symbol(v.name) for v in values(deps) if v.is_tracking_registry && v.is_direct_dep]

    sysimage_prefix = "JuliaSysimage"
    sysimage_suffix = get(ENV, "JULIA_SYSIMAGE_SUFFIX", "")
    if !isempty(sysimage_suffix)
        sysimage_suffix = "_" * sysimage_suffix
    end
    sysimage_path = sysimage_prefix * sysimage_suffix * ".so"
    sysimage_path = joinpath(project_root, sysimage_path)
    @info "Creating julia sysimage at $sysimage_path..."
    PackageCompiler.create_sysimage(pkgs, sysimage_path=sysimage_path; kw...)
    nothing
end