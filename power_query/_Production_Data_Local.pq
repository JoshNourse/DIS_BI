let
    Source = if data_source = "Local"
        then Folder.Files(data_path_local)
        else Table.FromRecords({
            [File = "data_source parameter is not local", Folder Path = data_path_local]
        }),
    #"Filtered Rows" = Table.SelectRows(Source, each ([Folder Path] = data_path_local))

in
    #"Filtered Rows"