export create_sysimage

const SYSIMAGE_PREFIX = "JuliaSysimage"

using PackageCompiler
using PackageCompiler: get_extra_linker_flags, julia_libdir, julia_private_libdir, 
                       ldlibs, bitflag, march, run_compiler

# https://github.com/JuliaLang/PackageCompiler.jl/issues/738#issuecomment-1838901893
# Bad type piracy, but this override is necessary to get sysimages working on recent versions of
# Xcode. Without it, compiled packages fail consistency checks.
function PackageCompiler.create_sysimg_from_object_file(object_files::Vector{String},
                                        sysimage_path::String;
                                        version,
                                        compat_level::String,
                                        soname::Union{Nothing, String})

    if soname === nothing && (Sys.isunix() && !Sys.isapple())
        soname = basename(sysimage_path)
    end
    mkpath(dirname(sysimage_path))
    # Prevent compiler from stripping all symbols from the shared lib.
    o_file_flags = Sys.isapple() ? `-Wl,-all_load $object_files -Wl,-ld_classic` : `-Wl,--whole-archive $object_files -Wl,--no-whole-archive`
    extra = get_extra_linker_flags(version, compat_level, soname)
    cmd = `$(bitflag()) $(march()) -shared -L$(julia_libdir()) -L$(julia_private_libdir()) -o $sysimage_path $o_file_flags $(Base.shell_split(ldlibs())) $extra`
    run_compiler(cmd; cplusplus=true)
    return nothing
end

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