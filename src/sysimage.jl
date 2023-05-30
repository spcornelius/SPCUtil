import Pkg
import PackageCompiler

const SYSIMAGE_PREFIX = "JuliaSysimage"

function create_sysimage(; exclude = Set{String}(), kw...)
    project_root = dirname(Base.active_project())

    exclude = Set(string.(exclude))

    deps = Pkg.dependencies()

    # Only include direct dependencies of project. Also, only include
    # packages from a registry (i.e., exclude github, etc.)
    pkgs = [Symbol(v.name) for v in values(deps) if 
            v.is_tracking_registry && v.is_direct_dep && v.name ∉ exclude]

    sysimage_suffix = get(ENV, "JULIA_SYSIMAGE_SUFFIX", "")
    if !isempty(sysimage_suffix)
        sysimage_suffix = "_" * sysimage_suffix
    end
    sysimage_path = SYSIMAGE_PREFIX * sysimage_suffix * ".so"
    sysimage_path = joinpath(project_root, sysimage_path)
    @info "Creating julia sysimage at $sysimage_path..."
    PackageCompiler.create_sysimage(pkgs, sysimage_path=sysimage_path; kw...)
    nothing
end