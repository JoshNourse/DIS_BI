let
    // If parameter notes_include = No, just return a dummy table
    Source = if notes_include = "No"
        //then POS_Detail_Extract_Filter
        then Table.FromRows(
        {{"NoValue-WA11111", "No",10,"No Sales Code", "Would be some note text here"}},
        {"Key_Cust_Doc", "Detail: Line Sales code", "Detail: Line Number", "Detail: Line Sales code Description", "Detail: Note Line"})
        else POS_Detail_Extract_Filter/*,
    // Include only needed columns
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Key_Cust_Doc", "Detail: Line Sales code", "Detail: Line Number", "Detail: Line Sales code Description", "Detail: Note Line"}),
    // Filter out any rows with empty notes
    #"Filtered Empty Notes" = Table.SelectRows(#"Removed Other Columns", each 
            [#"Detail: Note Line"] <> null 
        and [#"Detail: Note Line"] <> ""),
    // Sort by "Key_Cust_Doc" and "Detail: Line Number" to concatenate notes in order
    #"Sort by ID and Line Number" = Table.Sort(#"Filtered Empty Notes",{
        {"Key_Cust_Doc", Order.Ascending}, 
        {"Detail: Line Number", Order.Ascending}
    }),
    // Creates a table as column of grouped records
    #"Grouped Rows" = Table.Group(#"Sort by ID and Line Number",
        {"Key_Cust_Doc"},
        {{"Note Concat Table", each _, type table 
            [Key_Cust_Doc=nullable text, #"Detail: Note Line"=nullable text]
        }}
    ),
    // Extract the note records of each grouped table into a list
    #"Create List of Notes" = Table.AddColumn(#"Grouped Rows", "Note Concat List", each Table.Column([Note Concat Table], "Detail: Note Line")),
    // Concatenace the list of notes
    #"Extracted List as Field" = Table.TransformColumns(#"Create List of Notes", {"Note Concat List", each Text.Combine(List.Transform(_, Text.From), ", "), type text}),
    // Returns just key and note
    #"Removed Columns" = Table.RemoveColumns(#"Extracted List as Field",{"Note Concat Table"})*/
in
    #"Source"