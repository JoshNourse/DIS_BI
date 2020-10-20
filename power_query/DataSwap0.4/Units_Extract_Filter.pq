let
     Source = _Production_Data_Select,
    // Filter the files to include in the correct data source
    #"Filtered Files" = 
        Table.Buffer(
            Table.SelectRows(Source, each 
                Text.Contains([Name], "Unit_Inventory_Master_Information") 
            // or Text.Contains([Name], "Detail_Posted") 
            // and Text.Contains([Name], "csv") // Need to ignore the "Detail_Posted*.xls until legacy workbooks retired and these files removed
            // and Number.FromText([year_posted]) >= date_year_posted_start // Dont want to touch these big old files if we dont need to
            )
        ),
    // Conditionally create table(and promote headers) from each file based upon file type
    #"Extract Table From File" = Table.AddColumn(#"Filtered Files", "Data", each 
        if Text.Contains([Extension], "xls") 
        then Table.PromoteHeaders(
                Excel.Workbook([Content]){[Item="Sheet1",Kind="Sheet"]}[Data]
            , [PromoteAllScalars=true])
        else if Text.Contains([Extension], "csv") 
        then Table.PromoteHeaders(
                Csv.Document([Content],[Delimiter=",", Encoding=1252, QuoteStyle=QuoteStyle.None])
            , [PromoteAllScalars=true])
        else "Need to specify extraction method"),
    // expand the extracted table of each file into single table
    #"Expanded Data" = Table.ExpandTableColumn(#"Extract Table From File", 
        "Data", 
        // Column name to extract were hard coded, changed below to read columns from first table in file selections
        Table.ColumnNames(#"Extract Table From File"[#"Data"]{0})
        ),
    // Make the Unit Number the key
    #"Make Unit Number Key" = Table.AddKey(
        #"Expanded Data",
        {"Unit Number"},
        true),
   
    //__________FILTERS____Filter Customer Table by Sales Data
   // create a list of "Unit Numbers" to fitler table by
   #"Create Filter List" = 
        if unit_include = "In Sales"
        // TODO: creats list from POS_Summary, should include equipment sales too
        then List.Buffer(List.Sort(List.Distinct(POS_Summary_Extract_Filter[#"Address#/Stock#"])))
        else if unit_include = "Custom"
        then {} //define a custom list here
        else {},
   //Apply filter using the filter list if customer_include parameter is not "All"
   #"Filter Customers" = 
        if unit_include = "All"
        then #"Make Unit Number Key"
        else if unit_include = "None"
        then Table.FirstN(#"Make Unit Number Key", 1)
        else Table.SelectRows(#"Make Unit Number Key", each 
            List.Contains(
                #"Create Filter List",
                [#"Unit Number"])),
    // Remove columns added by folder table
    #"Removed Columns" = Table.RemoveColumns( 
        #"Filter Customers",
        Table.ColumnNames(#"Filtered Files")
        )
in
    #"Removed Columns"