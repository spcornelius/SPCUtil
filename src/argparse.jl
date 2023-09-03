function ArgParse.import_settings!(settings::ArgParseSettings,
                                   other::ArgParseSettings,
                                   names;
                                   args_only::Bool = true)
    other = deepcopy(other)
    ofields = other.args_table.fields
    to_delete = Int[]
    for (i, field) in enumerate(ofields)
        # fieldnames = chain(field.long_opt_name, field.short_opt_name)
        # any(name -> name ∈ names, fieldnames) && continue
        field.dest_name ∈ names || push!(to_delete, i)
    end
    deleteat!(ofields, to_delete)
    import_settings!(settings, other; args_only = args_only)
end