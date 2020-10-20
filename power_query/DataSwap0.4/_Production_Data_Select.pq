let
    // #shared returns a record of all names in the global environment (Including other queries)
    global_objects = #shared,
    // Convert the records to table
    #"global_objects to Table" = Record.ToTable(global_objects),
    // Filter for data queries using common name and data_source parameter
    #"Filter for data_source" = Table.SelectRows(#"global_objects to Table", each 
        Text.Contains([Name], "_Production_Data")
    and Text.Contains([Name], data_source       )
    ),
    // Return just the result(Table) of the filtered record
    #"Retrun Objects Result" = #"Filter for data_source"{0}[Value],
     // Create a column extracting the year from file name to use in filter
    #"Add Column Year from File Name" = Table.AddColumn(#"Retrun Objects Result", "year_posted", each Text.Select([Name], {"0".."9"}), type number)
in
    #"Add Column Year from File Name"